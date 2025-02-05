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
                        .accessibilityHint("Enter medicine name to filter list")
                        .accessibilityIdentifier(AccessID.searchMedicine)
                            
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
                        .accessibilityIdentifier(AccessID.noneSort)
                    Text("Name").tag(SortOption.name)
                        .accessibilityIdentifier(AccessID.nameSort)
                    Text("Stock").tag(SortOption.stock)
                        .accessibilityIdentifier(AccessID.stockSort)
                }
                .accessibilityIdentifier(AccessID.sortMedicines)
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
                    
                    if MedicConfig.loadingMedicineStrategy == .lazy && viewModel.hasMoreMedicines {
                        HStack {
                            Spacer()
                            if viewModel.isLoadingMore {
                                ProgressView()
                            } else {
                                Button("Load More") {
                                    viewModel.fetchMedicines(loadMore: true)
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .onAppear {
            viewModel.fetchMedicines()
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
