//
//  HistorySection.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 22/01/2025.
//

import SwiftUI



struct HistorySection: View {
    let history: [HistoryEntry]
    
    var body: some View {
        Section(header: Text("History")) {
            if history.isEmpty {
                Text("No history available")
                    .foregroundColor(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color(.systemGroupedBackground))
            } else {
                ForEach(history.sorted(by: { $0.timestamp > $1.timestamp })) { entry in
                    HistoryEntryRow(entry: entry)
                }
            }
        }
    }
}
