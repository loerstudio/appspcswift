import SwiftUI

struct CoachLoginView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var coachCode = ""
    @State private var isCreatingAccount = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        Text("SIMOPAGNO COACHING")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Accesso Coach")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        if isCreatingAccount {
                            CustomTextField(
                                text: $fullName,
                                placeholder: "Nome Completo",
                                icon: "person"
                            )
                            
                            CustomTextField(
                                text: $coachCode,
                                placeholder: "Codice Coach",
                                icon: "key"
                            )
                        }
                        
                        CustomTextField(
                            text: $email,
                            placeholder: "Email Coach",
                            icon: "envelope",
                            keyboardType: .emailAddress
                        )
                        
                        CustomSecureField(
                            text: $password,
                            placeholder: "Password",
                            icon: "lock"
                        )
                    }
                    
                    // Buttons
                    VStack(spacing: 16) {
                        if isCreatingAccount {
                            Button(action: createCoachAccount) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    }
                                    Text(isLoading ? "Creazione..." : "Crea Account Coach")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                            }
                            .disabled(isLoading)
                        } else {
                            Button(action: signInCoach) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    }
                                    Text(isLoading ? "Accesso in corso..." : "Accedi Coach")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                            }
                            .disabled(isLoading)
                        }
                        
                        Button(action: {
                            isCreatingAccount.toggle()
                            authService.clearError()
                        }) {
                            Text(isCreatingAccount ? "Hai già un account? Accedi" : "Crea nuovo account coach")
                                .foregroundColor(.white.opacity(0.8))
                                .underline()
                        }
                    }
                    
                    // Switch to Client
                    Button(action: {
                        // Switch to client login
                    }) {
                        Text("Accedi come Cliente")
                            .foregroundColor(.white.opacity(0.8))
                            .underline()
                    }
                    
                    // Error Message
                    if !authService.errorMessage.isEmpty {
                        Text(authService.errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .padding(32)
            }
            .background(Color.black)
            .navigationBarHidden(true)
        }
    }
    
    private func createCoachAccount() {
        guard !fullName.isEmpty && !email.isEmpty && !password.isEmpty && !coachCode.isEmpty else {
            authService.errorMessage = "Compila tutti i campi"
            return
        }
        
        guard password.count >= 6 else {
            authService.errorMessage = "La password deve essere di almeno 6 caratteri"
            return
        }
        
        isLoading = true
        
        Task {
            let success = await authService.createCoachAccount(
                name: fullName,
                email: email,
                password: password,
                coachCode: coachCode
            )
            
            await MainActor.run {
                isLoading = false
                if success {
                    isCreatingAccount = false
                }
            }
        }
    }
    
    private func signInCoach() {
        guard !email.isEmpty && !password.isEmpty else {
            authService.errorMessage = "Inserisci email e password"
            return
        }
        
        isLoading = true
        
        Task {
            let success = await authService.signInCoach(email: email, password: password)
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.black)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    @State private var isSecured = true
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.black)
                .frame(width: 20)
            
            if isSecured {
                SecureField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: isSecured ? "eye.slash" : "eye")
                    .foregroundColor(.black)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

#Preview {
    CoachLoginView()
        .environmentObject(FirebaseAuthService())
} 