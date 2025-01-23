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
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { session.signOut() }) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.red)
            }
        }
    }
}
