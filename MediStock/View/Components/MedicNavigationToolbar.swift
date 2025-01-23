//
//  MedicNavigationToolbar.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 22/01/2025.
//

import SwiftUI



struct MedicNavigationToolbar: ToolbarContent {
    let title: String
    let backText: String
    @Environment(\.dismiss) private var dismiss

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { dismiss() }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text(backText)
                }
            }
        }
    }
}
