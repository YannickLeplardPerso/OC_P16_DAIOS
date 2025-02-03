import SwiftUI



struct MedicineDetailView: View {
    let medicineId: String
    let sourceView: String
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navigationState: NavigationStateManager
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
//                            let isLastInAisle = viewModel.medicines.filter { $0.aisle == medicine.aisle }.count == 1
                            
                            viewModel.deleteMedicine(medicine, user: session.session?.uid ?? "")
                            dismiss()
//                            if isLastInAisle {
//                                dismiss()
//                            } else {
//                                dismiss()
//                            }
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
        .onAppear {
            if let medicine = medicine {
                viewModel.fetchHistory(for: medicine)
            }
            else {
                viewModel.error = .medicineNotFound
            }
        }
        .sheet(isPresented: $showingAddSheet) {
//            AddMedicineSheet()
            AddMedicineSheet(fromAisle: medicine?.aisle) { newId in
                print("Nouveau médicament créé avec l'ID: \(newId)")
                print("Création depuis l'aisle: \(medicine?.aisle ?? "aucun")")
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
