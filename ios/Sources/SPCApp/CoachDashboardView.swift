import SwiftUI
import FirebaseFirestore

struct CoachDashboardView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @State private var clients: [[String: Any]] = []
    @State private var showingCreateClient = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Benvenuto, Coach")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(authService.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            authService.signOut()
                        }) {
                            Text("Logout")
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.black)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
                .background(Color.black)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Create Client Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Gestione Clienti")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            Button(action: {
                                showingCreateClient = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.white)
                                    Text("Crea Nuovo Cliente")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.black)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        
                        // Clients List Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("I Tuoi Clienti")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            if isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    Spacer()
                                }
                                .frame(height: 100)
                            } else if clients.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "person.3.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    
                                    Text("Nessun cliente ancora")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    
                                    Text("Crea il tuo primo cliente per iniziare")
                                        .font(.subheadline)
                                        .foregroundColor(.gray.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 150)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(clients.indices, id: \.self) { index in
                                        let client = clients[index]
                                        ClientRowView(client: client)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    }
                    .padding()
                }
                .background(Color.gray.opacity(0.1))
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCreateClient) {
            CreateClientView()
                .environmentObject(authService)
        }
        .onAppear {
            loadClients()
        }
    }
    
    private func loadClients() {
        isLoading = true
        
        Task {
            let fetchedClients = await authService.getCoachClients()
            
            await MainActor.run {
                self.clients = fetchedClients
                self.isLoading = false
            }
        }
    }
}

struct ClientRowView: View {
    let client: [String: Any]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(client["fullName"] as? String ?? "Nome non disponibile")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(client["email"] as? String ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let validityDays = client["validityDays"] as? Int {
                    Text("Validità: \(validityDays) giorni")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                let isActive = client["isActive"] as? Bool ?? true
                Text(isActive ? "Attivo" : "Inattivo")
                    .font(.caption)
                    .foregroundColor(isActive ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isActive ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .cornerRadius(8)
                
                if let expiresAt = client["expiresAt"] as? Timestamp {
                    Text(expiresAt.dateValue(), style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

#Preview {
    CoachDashboardView()
        .environmentObject(FirebaseAuthService())
} 