//
//  MedicineInformationSection.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 22/01/2025.
//

import SwiftUI



struct MedicineInformationSection: View {
    let medicine: Medicine
    
    var body: some View {
        Section(header: Text("Information")) {
            HStack {
                Label("Name", systemImage: "character.cursor.ibeam")
                Spacer()
                Text(medicine.name)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("Aisle", systemImage: "folder")
                Spacer()
                Text(medicine.aisle)
                    .foregroundColor(.secondary)
            }
        }
    }
}
