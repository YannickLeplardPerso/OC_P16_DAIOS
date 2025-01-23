import SwiftUI



struct MedicineListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @State private var showingAddSheet = false
    var aisle: String

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
        .sheet(isPresented: $showingAddSheet) {
            AddMedicineSheet()
        }
        .background(Color(.systemGroupedBackground))
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
