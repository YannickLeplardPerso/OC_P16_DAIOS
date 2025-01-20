import SwiftUI



struct MedicineDetailView: View {
   let medicineId: String
   @EnvironmentObject var viewModel: MedicineStockViewModel
   @EnvironmentObject var session: SessionStore
   
   var medicine: Medicine? {
       viewModel.medicines.first { $0.id == medicineId }
   }
   
   var body: some View {
       List {
           if let medicine = medicine {
               // Information Section
               Section(header: Text("Information")) {
                   HStack {
                       Label("Name", systemImage: "character.cursor.ibeam")
                       Spacer()
                       Text(medicine.name)
                           .foregroundColor(.secondary)
                   }
                   
                   HStack {
                       Label("Aisle", systemImage: "folder")
                       Spacer()
                       Text(medicine.aisle)
                           .foregroundColor(.secondary)
                   }
               }
               
               // Stock Management Section
               Section(header: Text("Stock Management")) {
                   HStack(spacing: 20) {
                       Button(action: {
                           print("Minus button tapped")
                           viewModel.updateStock(medicine, by: -1, user: session.session?.uid ?? "")
                       })  {
                           Image(systemName: "minus.circle.fill")
                               .font(.title)
                               .foregroundColor(.red)
                       }
                       .buttonStyle(BorderlessButtonStyle())
                       
                       Spacer()
                       
                       Text("\(medicine.stock)")
                           .font(.headline)
                       
                       Spacer()
                       
                       Button(action: {
                           print("Plus button tapped")
                           viewModel.updateStock(medicine, by: 1, user: session.session?.uid ?? "")
                       }) {
                           Image(systemName: "plus.circle.fill")
                               .font(.title)
                               .foregroundColor(.green)
                       }
                       .buttonStyle(BorderlessButtonStyle())
                   }
                   .padding(.vertical, 4)
               }
               
               // History Section
               Section(header: Text("History")) {
                   if viewModel.history.isEmpty {
                       Text("No history available")
                           .foregroundColor(.secondary)
                           .italic()
                           .frame(maxWidth: .infinity, alignment: .center)
                           .listRowBackground(Color(.systemGroupedBackground))
                   } else {
                       ForEach(viewModel.history.sorted(by: { $0.timestamp > $1.timestamp })) { entry in
                           VStack(alignment: .leading, spacing: 4) {
                               Text(entry.action)
                                   .font(.headline)
                               Text(entry.details)
                                   .font(.subheadline)
                                   .foregroundColor(.secondary)
                               Text(formatDate(entry.timestamp))
                                   .font(.caption)
                                   .foregroundColor(.secondary)
                           }
                           .padding(.vertical, 4)
                       }
                   }
               }
           }
       }
       .listStyle(InsetGroupedListStyle())
       .navigationTitle("Details")
       .onAppear {
           if let medicine = medicine {
               viewModel.fetchHistory(for: medicine)
           } else {
               viewModel.error = .medicineNotFound
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
   
   private func formatDate(_ date: Date) -> String {
       let formatter = DateFormatter()
       formatter.dateStyle = .medium
       formatter.timeStyle = .short
       formatter.locale = Locale(identifier: "en_US")
       return formatter.string(from: date)
   }
}


    
struct MedicineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMedicine = Medicine(id: "preview-id", name: "Sample", stock: 10, aisle: "Aisle 1")
        let viewModel = MedicineStockViewModel()
        // On ajoute le sample medicine dans le viewModel
        viewModel.medicines.append(sampleMedicine)
        
        return NavigationView {
            MedicineDetailView(medicineId: sampleMedicine.id!)
                .environmentObject(viewModel)
                .environmentObject(SessionStore())
        }
    }
}
