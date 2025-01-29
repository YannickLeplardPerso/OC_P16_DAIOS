//
//  MedicConfig.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 25/01/2025.
//

import Foundation



struct MedicConfig {
    static var useFirebaseFiltering = false
    
    static var loadingMedicineStrategy: LoadingStrategy = .eager
    
    static var loadingHistoryStrategy: LoadingStrategy = .lazy
    static var pageSize = 2 //20
}
