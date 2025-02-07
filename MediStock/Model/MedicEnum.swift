//
//  MedicEnum.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 25/01/2025.
//

import Foundation



enum SortOption: String, CaseIterable, Identifiable {
    case none
    case name
    case stock

    var id: String { self.rawValue }
}

enum LoadingStrategy {
    case eager
    case lazy
}
