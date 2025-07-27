import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseAuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var userRole: UserRole = .none
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    private let COACH_CODE = "COACHSPC1"
    
    enum UserRole {
        case none, coach, client
    }
    
    init() {
        checkAuthState()
    }
    
    func checkAuthState() {
        if let user = Auth.auth().currentUser {
            self.currentUser = user
            checkUserRole(userId: user.uid)
        }
    }
    
    private func checkUserRole(userId: String) {
        // Check if user is a coach
        db.collection("coaches").document(userId).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                DispatchQueue.main.async {
                    self?.userRole = .coach
                    self?.isAuthenticated = true
                }
                return
            }
            
            // Check if user is a client
            self?.db.collection("users").document(userId).getDocument { [weak self] document, error in
                DispatchQueue.main.async {
                    if let document = document, document.exists {
                        let data = document.data()
                        let isActive = data?["isActive"] as? Bool ?? true
                        let expiresAt = data?["expiresAt"] as? Timestamp
                        
                        if !isActive {
                            self?.signOut()
                            self?.errorMessage = "Account disattivato. Contatta il tuo coach."
                            return
                        }
                        
                        if let expiresAt = expiresAt, expiresAt.dateValue() < Date() {
                            self?.signOut()
                            self?.errorMessage = "Account scaduto. Contatta il tuo coach per il rinnovo."
                            return
                        }
                        
                        self?.userRole = .client
                        self?.isAuthenticated = true
                    } else {
                        self?.signOut()
                        self?.errorMessage = "Utente non trovato nel database."
                    }
                }
            }
        }
    }
    
    // MARK: - Coach Functions
    
    func createCoachAccount(name: String, email: String, password: String, coachCode: String) async -> Bool {
        guard coachCode == COACH_CODE else {
            await MainActor.run {
                self.errorMessage = "Codice coach non valido"
            }
            return false
        }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = result.user
            
            let coachData: [String: Any] = [
                "email": email,
                "fullName": name,
                "role": "coach",
                "isActive": true,
                "createdAt": Timestamp(),
                "lastLogin": Timestamp()
            ]
            
            try await db.collection("coaches").document(user.uid).setData(coachData)
            
            await MainActor.run {
                self.currentUser = user
                self.userRole = .coach
                self.isAuthenticated = true
                self.errorMessage = ""
            }
            
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func signInCoach(email: String, password: String) async -> Bool {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = result.user
            
            let coachDoc = try await db.collection("coaches").document(user.uid).getDocument()
            
            if coachDoc.exists {
                let data = coachDoc.data()
                let isActive = data?["isActive"] as? Bool ?? true
                
                if !isActive {
                    await MainActor.run {
                        self.errorMessage = "Account coach disattivato"
                    }
                    return false
                }
                
                try await db.collection("coaches").document(user.uid).updateData([
                    "lastLogin": Timestamp()
                ])
                
                await MainActor.run {
                    self.currentUser = user
                    self.userRole = .coach
                    self.isAuthenticated = true
                    self.errorMessage = ""
                }
                
                return true
            } else {
                await MainActor.run {
                    self.errorMessage = "Utente non è un coach autorizzato"
                }
                return false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Client Functions
    
    func signInClient(email: String, password: String) async -> Bool {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = result.user
            
            let clientDoc = try await db.collection("users").document(user.uid).getDocument()
            
            if clientDoc.exists {
                let data = clientDoc.data()
                let isActive = data?["isActive"] as? Bool ?? true
                let expiresAt = data?["expiresAt"] as? Timestamp
                
                if !isActive {
                    await MainActor.run {
                        self.errorMessage = "Account disattivato. Contatta il tuo coach."
                    }
                    return false
                }
                
                if let expiresAt = expiresAt, expiresAt.dateValue() < Date() {
                    await MainActor.run {
                        self.errorMessage = "Account scaduto. Contatta il tuo coach per il rinnovo."
                    }
                    return false
                }
                
                try await db.collection("users").document(user.uid).updateData([
                    "lastLogin": Timestamp()
                ])
                
                await MainActor.run {
                    self.currentUser = user
                    self.userRole = .client
                    self.isAuthenticated = true
                    self.errorMessage = ""
                }
                
                return true
            } else {
                await MainActor.run {
                    self.errorMessage = "Utente non trovato nel database."
                }
                return false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Coach Management Functions
    
    func createClientAccount(name: String, email: String, password: String, validityDays: Int) async -> Bool {
        guard let currentUser = Auth.auth().currentUser else {
            await MainActor.run {
                self.errorMessage = "Coach non autenticato"
            }
            return false
        }
        
        // Verify current user is a coach
        let coachDoc = try? await db.collection("coaches").document(currentUser.uid).getDocument()
        guard coachDoc?.exists == true else {
            await MainActor.run {
                self.errorMessage = "Solo i coach possono creare account clienti"
            }
            return false
        }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = result.user
            
            let expirationDate = Date().addingTimeInterval(TimeInterval(validityDays * 24 * 60 * 60))
            
            let clientData: [String: Any] = [
                "email": email,
                "fullName": name,
                "role": "client",
                "coachId": currentUser.uid,
                "coachEmail": currentUser.email ?? "",
                "isActive": true,
                "createdAt": Timestamp(),
                "expiresAt": Timestamp(date: expirationDate),
                "validityDays": validityDays,
                "lastLogin": Timestamp()
            ]
            
            try await db.collection("users").document(user.uid).setData(clientData)
            
            await MainActor.run {
                self.errorMessage = ""
            }
            
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func getCoachClients() async -> [[String: Any]] {
        guard let currentUser = Auth.auth().currentUser else {
            return []
        }
        
        do {
            let snapshot = try await db.collection("users")
                .whereField("coachId", isEqualTo: currentUser.uid)
                .getDocuments()
            
            return snapshot.documents.map { doc in
                var data = doc.data()
                data["id"] = doc.documentID
                return data
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return []
        }
    }
    
    // MARK: - General Functions
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.userRole = .none
                self.isAuthenticated = false
                self.errorMessage = ""
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func clearError() {
        errorMessage = ""
    }
}
