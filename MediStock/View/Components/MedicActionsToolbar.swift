//
//  MedicActionsToolbar.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 22/01/2025.
//

import SwiftUI

struct MedicActionsToolbar: ToolbarContent {
    @EnvironmentObject var session: SessionStore
    @Binding var showingAddSheet: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { showingAddSheet = true }) {
                Image(systemName: "plus")
            }
            .accessibilityIdentifier(AccessID.addMedicine)
            .accessibilityLabel("Add new medicine")
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { session.signOut() }) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.red)
            }
            .accessibilityIdentifier(AccessID.signOut)
            .accessibilityLabel("Sign out")
        }
    }
}
