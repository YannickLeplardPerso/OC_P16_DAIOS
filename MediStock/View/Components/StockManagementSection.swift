//
//  StockManagementSection.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 22/01/2025.
//

import SwiftUI



struct StockManagementSection: View {
    let medicine: Medicine
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        Section(header: Text("Stock Management")) {
            HStack(spacing: 20) {
                Button(action: {
                    Task {
                        await viewModel.updateStock(medicine, by: -1, user: session.session?.uid ?? "")
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                }
                .accessibilityIdentifier(AccessID.decreaseStock)
                .accessibilityLabel("Decrease stock by one")
                .buttonStyle(BorderlessButtonStyle())
                .disabled(medicine.stock == 0)
                
                Spacer()
                Text("\(medicine.stock)")
                    .accessibilityIdentifier(AccessID.currentStock)
                    .font(.headline)
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.updateStock(medicine, by: 1, user: session.session?.uid ?? "")
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                }
                .accessibilityIdentifier(AccessID.increaseStock)
                .accessibilityLabel("Increase stock by one")
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.vertical, 8)
        }
    }
}
