//
//  MedicError.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 18/01/2025.
//

import SwiftUI
//import FirebaseAuth



//enum MedicError: LocalizedError, Identifiable, Hashable {
enum MedicError: LocalizedError, Identifiable {
    case invalidEmail
    case invalidPassword
    case signInFailed
    case emailAlreadyInUse
    case weakPassword
    case signUpFailed
    case signOutFailed
//    case userNotFound
    
    
    var id: String { localizedDescription }  // pour les alertes
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .invalidPassword:
            return "Please enter a valid password"
        case .signInFailed:
            return "sign in failed"
        case .emailAlreadyInUse:
            return "An account already exists with this email"
        case .weakPassword:
            return "Password is too weak"
        case .signUpFailed:
            return "sign up failed"
        case .signOutFailed:
            return "sign out failed"
        }
    }
}
