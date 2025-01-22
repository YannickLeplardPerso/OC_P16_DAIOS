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
    case updateStockError
    case fetchMedicinesError
    case fetchAislesError
    case fetchHistoryError
    case addMedicineError
    case deleteMedicineError
    case updateMedicineError
    case addHistoryError
    case medicineNotFound
    case invalidMedicineId
    case invalidMedicineName
    case invalidStock
    case invalidAisle
    
    
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
        case .updateStockError:
            return "Failed to update stock. Please try again."
        case .fetchMedicinesError:
            return "Failed to fetch medicines"
        case .fetchAislesError:
            return "Failed to fetch aisles"
        case .fetchHistoryError:
            return "Failed to fetch history"
        case .addMedicineError:
            return "Failed to add medicine"
        case .deleteMedicineError:
            return "Failed to delete medicine"
        case .updateMedicineError:
            return "Failed to update medicine"
        case .addHistoryError:
            return "Failed to add history entry"
        case .medicineNotFound:
            return "Medicine not found"
        case .invalidMedicineId:
            return "Invalid medicine ID"
        case .invalidMedicineName:
            return "Medicine name cannot be empty"
        case .invalidStock:
            return "Stock must be a valid number"
        case .invalidAisle:
            return "Aisle must be selected or created"
        }
    }
}
