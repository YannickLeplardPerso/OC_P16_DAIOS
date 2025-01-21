import SwiftUI



struct AllMedicinesView: View {
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @State private var filterText: String = ""
    @State private var sortOption: SortOption = .none

    var body: some View {
        VStack(spacing: 0) {
            // Barre de recherche et tri
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search medicine", text: $filterText)
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                
                Picker("Sort by", selection: $sortOption) {
                    Text("None").tag(SortOption.none)
                    Text("Name").tag(SortOption.name)
                    Text("Stock").tag(SortOption.stock)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color(.systemGroupedBackground))
            
            List {
                ForEach(filteredAndSortedMedicines, id: \.id) { medicine in
                    NavigationLink(destination: MedicineDetailView(medicineId: medicine.id ?? "")) {
                        HStack {
                            Image(systemName: "pills.fill")
                                .foregroundColor(.accentColor)
                                .font(.title2)
                                .padding(.trailing, 10)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(medicine.name)
                                    .font(.headline)
                                HStack {
                                    Text("Stock: \(medicine.stock)")
                                        .foregroundColor(.secondary)
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text(medicine.aisle)
                                        .foregroundColor(.secondary)
                                }
                                .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationTitle("Médicaments")
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
    
    var filteredAndSortedMedicines: [Medicine] {
        var medicines = viewModel.medicines
        
        // Filtrage
        if !filterText.isEmpty {
            medicines = medicines.filter { $0.name.lowercased().contains(filterText.lowercased()) }
        }
        
        // Tri
        switch sortOption {
        case .name:
            medicines.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .stock:
            medicines.sort { $0.stock < $1.stock }
        case .none:
            break
        }
        
        return medicines
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case none
    case name
    case stock

    var id: String { self.rawValue }
}



struct AllMedicinesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AllMedicinesView()
                .environmentObject(MedicineStockViewModel())
        }
    }
}
