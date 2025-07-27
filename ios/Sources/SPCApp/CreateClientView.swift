import SwiftUI

struct CreateClientView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @Environment(\.dismiss) private var dismiss
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var validityDays = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Crea Nuovo Cliente")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("Inserisci i dati del nuovo cliente")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        CustomTextField(
                            text: $fullName,
                            placeholder: "Nome Completo",
                            icon: "person"
                        )
                        
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
                        
                        CustomTextField(
                            text: $validityDays,
                            placeholder: "Giorni di Validità (es: 30, 60, 90)",
                            icon: "calendar",
                            keyboardType: .numberPad
                        )
                    }
                    
                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: createClient) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(isLoading ? "Creazione..." : "Crea Cliente")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        }
                        .disabled(isLoading)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Annulla")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.clear)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                        .disabled(isLoading)
                    }
                    
                    // Error Message
                    if !authService.errorMessage.isEmpty {
                        Text(authService.errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .padding(24)
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Chiudi") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
        }
    }
    
    private func createClient() {
        guard !fullName.isEmpty && !email.isEmpty && !password.isEmpty && !validityDays.isEmpty else {
            authService.errorMessage = "Compila tutti i campi"
            return
        }
        
        guard let validityDaysInt = Int(validityDays), validityDaysInt > 0 else {
            authService.errorMessage = "Inserisci un numero valido di giorni"
            return
        }
        
        guard password.count >= 6 else {
            authService.errorMessage = "La password deve essere di almeno 6 caratteri"
            return
        }
        
        isLoading = true
        
        Task {
            let success = await authService.createClientAccount(
                name: fullName,
                email: email,
                password: password,
                validityDays: validityDaysInt
            )
            
            await MainActor.run {
                isLoading = false
                if success {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    CreateClientView()
        .environmentObject(FirebaseAuthService())
} 