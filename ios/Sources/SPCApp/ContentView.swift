import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                if authService.userRole == .coach {
                    CoachDashboardView()
                        .environmentObject(authService)
                } else {
                    DashboardView()
                        .environmentObject(authService)
                }
            } else {
                MainLoginView()
            }
        }
        .onAppear {
            // Check authentication state when app launches
            authService.checkAuthState()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FirebaseAuthService())
}
