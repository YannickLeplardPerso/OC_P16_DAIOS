import SwiftUI



struct MedicineDetailView: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var session: SessionStore
    @State private var showingAddSheet = false
    let medicineId: String
    let sourceView: String
    
    var medicine: Medicine? {
        viewModel.medicines.first { $0.id == medicineId }
    }
    
    var body: some View {
        List {
            if let medicine = medicine {
                MedicineInformationSection(medicine: medicine)
                StockManagementSection(medicine: medicine)
                HistorySection(history: viewModel.history)
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
        .sheet(isPresented: $showingAddSheet) {
            AddMedicineSheet()
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
