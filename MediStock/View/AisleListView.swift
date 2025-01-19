import SwiftUI



struct AisleListView: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.aisles, id: \.self) { aisle in
                NavigationLink(destination: MedicineListView(aisle: aisle)) {
                    HStack {
                        Image(systemName: "tray.full")
                            .foregroundColor(.accentColor)
                            .font(.title2)
                            .padding(.trailing, 10)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(aisle)
                                .font(.headline)
                            Text("\(viewModel.medicines.filter { $0.aisle == aisle }.count) medicines")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Rayons")
        .onAppear {
            viewModel.fetchAisles()
        }
        .background(Color(.systemGroupedBackground))
    }
}



struct AisleListView_Previews: PreviewProvider {
    static var previews: some View {
        AisleListView()
            .environmentObject(MedicineStockViewModel())
    }
}
