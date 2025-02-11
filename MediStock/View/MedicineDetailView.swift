import SwiftUI



struct MedicineDetailView: View {
    let medicineId: String
    let sourceView: String
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var session: SessionStore
    @State private var showingAddSheet = false
    
    var medicine: Medicine? {
        viewModel.medicines.first { $0.id == medicineId }
    }

    var body: some View {
        List {
            if let medicine = medicine {
                MedicineInformationSection(medicine: medicine)
                StockManagementSection(medicine: medicine)

                if medicine.stock == 0 {
                    Section {
                        Button(action: {
                            Task {
                                await viewModel.deleteMedicine(medicine, user: session.session?.uid ?? "")
                                await viewModel.fetchMedicines()
                                dismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Medicine")
                            }
                            .foregroundColor(.red)
                        }
                    }
                }

                if viewModel.isLoading {
                    Section(header: Text("History")) {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color(.systemGroupedBackground))
                    }
                } else {
                    HistorySection(medicine: medicine)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            MedicNavigationToolbar(title: "Details", backText: sourceView)
            MedicActionsToolbar(showingAddSheet: $showingAddSheet)
        }
        .task {
            if let medicine = medicine {
                await viewModel.fetchHistory(for: medicine)
            }
            else {
                viewModel.error = .medicineNotFound
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddMedicineSheet(fromAisle: medicine?.aisle)
        }
        .alert(item: $viewModel.error) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}



struct MedicineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMedicine = Medicine(id: "preview-id", name: "Sample", stock: 10, aisle: "Aisle 1")
        let viewModel = MedicineStockViewModel()
        viewModel.medicines.append(sampleMedicine)
        
        return NavigationView {
            MedicineDetailView(medicineId: sampleMedicine.id!, sourceView: "SourceView")
        }
    }
}
