//
//  HistoryEntryRow.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 22/01/2025.
//

import SwiftUI



struct HistoryEntryRow: View {
    @EnvironmentObject var session: SessionStore
    let entry: HistoryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.action)
                .font(.headline)
            Text(entry.details)
                .font(.subheadline)
                .foregroundColor(.secondary)
//            Text(session.session?.email ?? entry.user)
            Text(entry.user)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(formatDate(entry.timestamp))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}
