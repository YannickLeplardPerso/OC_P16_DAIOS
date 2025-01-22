import SwiftUI



struct MedicineDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var session: SessionStore
    
    let medicineId: String
    let sourceView: String
    
    var medicine: Medicine? {
        viewModel.medicines.first { $0.id == medicineId }
    }
    
    var body: some View {
        List {
            if let medicine = medicine {
                
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
                
                Section(header: Text("Stock Management")) {
                    HStack(spacing: 20) {
                        Button(action: {
                            print("Minus button tapped")
                            viewModel.updateStock(medicine, by: -1, user: session.session?.uid ?? "")
                        })  {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(medicine.stock == 0)
                        
                        Spacer()
                        
                        Text("\(medicine.stock)")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            print("Plus button tapped")
                            viewModel.updateStock(medicine, by: 1, user: session.session?.uid ?? "")
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.green)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.vertical, 4)
                }
                
                if medicine.stock == 0 {
                    Section {
                        Button(action: {
                            viewModel.deleteMedicine(medicine, user: session.session?.uid ?? "")
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Medicine")
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("History")) {
                    if viewModel.history.isEmpty {
                        Text("No history available")
                            .foregroundColor(.secondary)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color(.systemGroupedBackground))
                    } else {
                        ForEach(viewModel.history.sorted(by: { $0.timestamp > $1.timestamp })) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.action)
                                    .font(.headline)
                                Text(entry.details)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(formatDate(entry.timestamp))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
//        .navigationTitle("Details")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Details")
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(sourceView)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
//                    showingAddSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
//                    session.signOut()
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
        }
        .onAppear {
            if let medicine = medicine {
                viewModel.fetchHistory(for: medicine)
            } else {
                viewModel.error = .medicineNotFound
            }
        }
        .alert(item: $viewModel.error) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}



struct MedicineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMedicine = Medicine(id: "preview-id", name: "Sample", stock: 10, aisle: "Aisle 1")
        let viewModel = MedicineStockViewModel()
        // On ajoute le sample medicine dans le viewModel
        viewModel.medicines.append(sampleMedicine)
        
        return NavigationView {
            MedicineDetailView(medicineId: sampleMedicine.id!, sourceView: "SourceView")
        }
    }
}
