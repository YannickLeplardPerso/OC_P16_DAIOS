//
//  MedicConfig.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 25/01/2025.
//

import Foundation



struct MedicConfig {
    static let useFirebaseFiltering = true
    
    static let loadingMedicineStrategy: LoadingStrategy = .eager
    static let loadingHistoryStrategy: LoadingStrategy = .eager
}
