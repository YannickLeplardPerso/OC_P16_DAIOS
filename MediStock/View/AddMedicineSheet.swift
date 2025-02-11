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
    
    @State private var showingSuccessAlert = false
    
    init(fromAisle: String? = nil, onMedicineCreated: ((String) -> Void)? = nil) {
        self.fromAisle = fromAisle
        self._selectedAisle = State(initialValue: fromAisle ?? "")
        self._isNewAisle = State(initialValue: false) 
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Medicine Information")) {
                    TextField("Medicine name", text: $medicineName)
                        .accessibilityIdentifier(AccessID.medicineName)
                        .autocorrectionDisabled(true)
                    
                    TextField("Initial stock", text: $initialStock)
                        .accessibilityIdentifier(AccessID.initialStock)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Aisle")) {
                    Picker("Select storage method", selection: $isNewAisle) {
                        Text("Existing aisle").tag(false)
                            .accessibilityIdentifier(AccessID.existingAisleButton)
                        Text("New aisle").tag(true)
                            .accessibilityIdentifier(AccessID.newAisleButton)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if isNewAisle {
                        TextField("New aisle name", text: $newAisle)
                            .accessibilityIdentifier(AccessID.newAisle)
                            .autocorrectionDisabled(true)
                    } else {
                        Picker("Select aisle", selection: $selectedAisle) {
                            Text("Select an aisle").tag("")
                            ForEach(viewModel.aisles, id: \.self) { aisle in
                                Text(aisle).tag(aisle)
                            }
                        }
                        .accessibilityIdentifier(AccessID.existingAislePicker)
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
                        Task {
                            if await viewModel.addMedicine(
                                name: medicineName,
                                stockString: initialStock,
                                aisle: isNewAisle ? newAisle : selectedAisle,
                                user: session.session?.uid ?? ""
                            ) != nil    {
                                showingSuccessAlert = true
                                await viewModel.fetchMedicines()
                            }
                        }
                    }
                    .accessibilityIdentifier(AccessID.addMedicineConfirm)
                    .disabled(medicineName.isEmpty || initialStock.isEmpty ||
                            (isNewAisle ? newAisle.isEmpty : selectedAisle.isEmpty))
                }
            }
        }
        .alert("✅ Medicine added", isPresented: $showingSuccessAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("\(medicineName) has been placed in aisle \(isNewAisle ? newAisle : selectedAisle)")
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
