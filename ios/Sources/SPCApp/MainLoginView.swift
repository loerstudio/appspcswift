import SwiftUI

struct MainLoginView: View {
    @State private var showingCoachLogin = false
    @State private var showingClientLogin = false
    
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
                        
                        Text("Scegli il tipo di accesso")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Login Options
                    VStack(spacing: 16) {
                        Button(action: {
                            showingCoachLogin = true
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Accesso Coach")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("Gestisci i tuoi clienti")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding()
                            .background(Color.black)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        }
                        
                        Button(action: {
                            showingClientLogin = true
                        }) {
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Accesso Cliente")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("Accedi con le tue credenziali")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding()
                            .background(Color.black)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        }
                    }
                    
                    // Info Text
                    VStack(spacing: 8) {
                        Text("Coach")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("• Crea e gestisci account clienti")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("• Imposta periodi di validità")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("• Monitora l'attività dei clienti")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(32)
            }
            .background(Color.black)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCoachLogin) {
            CoachLoginView()
                .environmentObject(FirebaseAuthService())
        }
        .sheet(isPresented: $showingClientLogin) {
            ClientLoginView()
                .environmentObject(FirebaseAuthService())
        }
    }
}

#Preview {
    MainLoginView()
} 