//___FILEHEADER___

import SwiftUI
import Firebase

@main
struct SPCApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(FirebaseAuthService())
                .preferredColorScheme(.dark)
        }
    }
}
