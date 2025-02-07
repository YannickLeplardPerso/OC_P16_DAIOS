import SwiftUI



struct MedicineListView: View {
    var aisle: String
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @State private var showingAddSheet = false
    
    var aisleStillExists: Bool {
        viewModel.aisles.contains(aisle)
    }

    var body: some View {
        List {
            ForEach(viewModel.medicines.filter { $0.aisle == aisle }, id: \.id) { medicine in
                NavigationLink(destination: MedicineDetailView(medicineId: medicine.id ?? "", sourceView: aisle)) {
                    MedicineRowView(medicine: medicine, showAisle: false)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            MedicNavigationToolbar(title: aisle, backText: "Aisles")
            MedicActionsToolbar(showingAddSheet: $showingAddSheet)
        }
        .onChange(of: aisleStillExists) { oldValue, newValue in
            if !newValue {
                dismiss()
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddMedicineSheet(fromAisle: aisle)
        }
        .background(Color(.systemGroupedBackground))
        .alert(item: $viewModel.error) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}



struct MedicineListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MedicineListView(aisle: "Aisle 1")
                .environmentObject(MedicineStockViewModel())
        }
    }
}
