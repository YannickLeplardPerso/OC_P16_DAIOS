import SwiftUI



struct MedicineListView: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel
    var aisle: String

    var body: some View {
        Text("")
        List {
            ForEach(viewModel.medicines.filter { $0.aisle == aisle }, id: \.id) { medicine in
                NavigationLink(destination: MedicineDetailView(medicineId: medicine.id ?? "")) {
                    HStack {
                        Image(systemName: "pills.fill")
                            .foregroundColor(.accentColor)
                            .font(.title2)
                            .padding(.trailing, 10)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(medicine.name)
                                .font(.headline)
                            Text("Stock: \(medicine.stock)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle(aisle)
        .onAppear {
            viewModel.fetchMedicines()
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
