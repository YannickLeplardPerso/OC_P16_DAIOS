//
//  AddMedicineSheet.swift
//  MediStock
//
//  Created by Yannick LEPLARD on 21/01/2025.
//

import SwiftUI

struct AddMedicineSheet: View {
    let fromAisle: String?
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var session: SessionStore
    @State private var medicineName = ""
    @State private var initialStock = ""
    @State private var selectedAisle = ""
    @State private var newAisle = ""
    @State private var isNewAisle = false
    
    init(fromAisle: String? = nil) {
        self.fromAisle = fromAisle
        self._selectedAisle = State(initialValue: fromAisle ?? "")
        self._isNewAisle = State(initialValue: false) 
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Medicine Information")) {
                    TextField("Medicine name", text: $medicineName)
                        .autocorrectionDisabled(true)
                    
                    TextField("Initial stock", text: $initialStock)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Aisle")) {
                    Picker("Select storage method", selection: $isNewAisle) {
                        Text("Existing aisle").tag(false)
                        Text("New aisle").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if isNewAisle {
                        TextField("New aisle name", text: $newAisle)
                            .autocorrectionDisabled(true)
                    } else {
                        Picker("Select aisle", selection: $selectedAisle) {
                            Text("Select an aisle").tag("")
                            ForEach(viewModel.aisles, id: \.self) { aisle in
                                Text(aisle).tag(aisle)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Medicine")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if viewModel.addMedicine(
                            name: medicineName,
                            stockString: initialStock,
                            aisle: isNewAisle ? newAisle : selectedAisle,
                            user: session.session?.uid ?? ""
                        ) != nil {
                            dismiss()
                        }
                    }
                    .disabled(medicineName.isEmpty || initialStock.isEmpty ||
                            (isNewAisle ? newAisle.isEmpty : selectedAisle.isEmpty))
                }
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



#Preview {
    AddMedicineSheet()
}
