import SwiftUI



struct MedicineListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: MedicineStockViewModel
    var aisle: String

    var body: some View {
        List {
            ForEach(viewModel.medicines.filter { $0.aisle == aisle }, id: \.id) { medicine in
                NavigationLink(destination: MedicineDetailView(medicineId: medicine.id ?? "", sourceView: aisle)) {
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                    Text("Aisles")
                }
            }
            ToolbarItem(placement: .principal) {
                Text(aisle)
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
