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
