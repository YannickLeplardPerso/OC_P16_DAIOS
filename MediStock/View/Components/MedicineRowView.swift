//
//  MedicineRowView.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 22/01/2025.
//

import SwiftUI



struct MedicineRowView: View {
    let medicine: Medicine
    let showAisle: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "pills.fill")
                .foregroundColor(.accentColor)
                .font(.title2)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(medicine.name)
                    .font(.headline)
//                    .accessibilityIdentifier("\(AccessID.medicineRow)-\(medicine)")
                
                if showAisle {
                    HStack {
                        Text("Stock: \(medicine.stock)")
                            .foregroundColor(.secondary)
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(medicine.aisle)
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                } else {
                    Text("Stock: \(medicine.stock)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
