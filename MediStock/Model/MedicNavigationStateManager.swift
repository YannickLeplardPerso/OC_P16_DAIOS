//
//  MedicNavigationStateManager.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 29/01/2025.
//

import Foundation
import SwiftUI



class NavigationStateManager: ObservableObject {
    @Published var path = NavigationPath()
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}
