//
//  MedicConfig.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 25/01/2025.
//

import Foundation



struct MedicConfig {
    // Utilisation de l'émulateur local Firebase pour les tests
    static var useEmulatorFirebase = false
    
    static var useFirebaseFiltering = false
    
    static var loadingMedicineStrategy: LoadingStrategy = .eager
    
    static var loadingHistoryStrategy: LoadingStrategy = .eager
    static var pageSize = 20
}
