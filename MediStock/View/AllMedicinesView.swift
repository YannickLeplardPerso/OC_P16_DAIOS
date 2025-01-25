import SwiftUI



struct AllMedicinesView: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Barre de recherche et tri
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search medicine", text: $viewModel.searchText)
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                
                Picker("Sort by", selection: $viewModel.sortOption) {
                    Text("None").tag(SortOption.none)
                    Text("Name").tag(SortOption.name)
                    Text("Stock").tag(SortOption.stock)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color(.systemGroupedBackground))
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.filteredAndSortedMedicines, id: \.id) { medicine in
                        NavigationLink(destination: MedicineDetailView(medicineId: medicine.id ?? "", sourceView: "Medicines")) {
                            MedicineRowView(medicine: medicine, showAisle: true)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .onAppear {
            viewModel.getMedicines()
//            viewModel.fetchMedicinesAndAisles()
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



struct AllMedicinesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AllMedicinesView()
                .environmentObject(MedicineStockViewModel())
        }
    }
}
