//
//  MediStockApp.swift
//  MediStock
//
//  Created by Vincent Saluzzo on 28/05/2024.
//
import SwiftUI
import Firebase

@main
struct MediStockApp: App {
    @StateObject var sessionStore = SessionStore()
    @StateObject var medicineStore = MedicineStockViewModel()
        
    init() {
        FirebaseApp.configure()
        if MedicConfig.useEmulatorFirebase {
            print("✅ FIREBASE_EMULATOR est actif")
            let settings = FirestoreSettings()
            settings.host = "127.0.0.1:8090"
            settings.isSSLEnabled = false
            settings.cacheSettings = MemoryCacheSettings()
            Firestore.firestore().settings = settings
            Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)
        }

        try? Auth.auth().signOut()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if sessionStore.session != nil {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(sessionStore)
            .environmentObject(medicineStore)
        }
    }
}
