import SwiftUI

struct ClientLoginView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @State private var email = ""
    @State private var password = ""
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
                        
                        Text("Accesso Cliente")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        CustomTextField(
                            text: $email,
                            placeholder: "Email",
                            icon: "envelope",
                            keyboardType: .emailAddress
                        )
                        
                        CustomSecureField(
                            text: $password,
                            placeholder: "Password",
                            icon: "lock"
                        )
                    }
                    
                    // Login Button
                    Button(action: signInClient) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Accesso in corso..." : "Accedi")
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
                    
                    // Switch to Coach
                    Button(action: {
                        // Switch to coach login
                    }) {
                        Text("Accedi come Coach")
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
    
    private func signInClient() {
        guard !email.isEmpty && !password.isEmpty else {
            authService.errorMessage = "Inserisci email e password"
            return
        }
        
        isLoading = true
        
        Task {
            let success = await authService.signInClient(email: email, password: password)
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

#Preview {
    ClientLoginView()
        .environmentObject(FirebaseAuthService())
} 