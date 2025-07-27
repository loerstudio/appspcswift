import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SIMOPAGNO COACHING")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Dashboard")
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
                        // Welcome Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.black)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Benvenuto!")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Text(authService.currentUser?.email ?? "")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            
                            Text("Accedi alle funzionalità dell'app per gestire i tuoi allenamenti e obiettivi.")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        
                        // Features Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            FeatureCard(
                                title: "Allenamenti",
                                icon: "dumbbell.fill",
                                color: .blue
                            )
                            
                            FeatureCard(
                                title: "Nutrizione",
                                icon: "leaf.fill",
                                color: .green
                            )
                            
                            FeatureCard(
                                title: "Obiettivi",
                                icon: "target",
                                color: .orange
                            )
                            
                            FeatureCard(
                                title: "Chat",
                                icon: "message.fill",
                                color: .purple
                            )
                        }
                        
                        // Account Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Informazioni Account")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            
                            VStack(spacing: 12) {
                                InfoRow(title: "Tipo Account", value: authService.userRole == .coach ? "Coach" : "Cliente")
                                InfoRow(title: "Email", value: authService.currentUser?.email ?? "")
                                InfoRow(title: "Stato", value: "Attivo")
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
    }
}

struct FeatureCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.black)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DashboardView()
        .environmentObject(FirebaseAuthService())
} 