//
//  HistorySection.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 22/01/2025.
//

import SwiftUI



struct HistorySection: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel
    let medicine: Medicine
    
    var body: some View {
        Section(header: Text("History")) {
            if viewModel.history.isEmpty {
                Text("No history available")
                    .foregroundColor(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color(.systemGroupedBackground))
            } else {
                ForEach(viewModel.history.sorted(by: { $0.timestamp > $1.timestamp })) { entry in
                    HistoryEntryRow(entry: entry)
                }
                
                if viewModel.hasMoreHistoryToLoad{
                    Button("Load More") {
                        viewModel.fetchHistoryPaged(for: medicine, loadMore: true)
                    }
                }
            }
        }
    }
}

