import Foundation
import Firebase



@MainActor
class MedicineStockViewModel: ObservableObject {
    @Published var medicines: [Medicine] = []
    @Published var aisles: [String] = []
    @Published var history: [HistoryEntry] = []
    @Published var error: MedicError?
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var sortOption: SortOption = .none
    
    @Published var isLoadingMore = false
    private var lastHistoryDocument: DocumentSnapshot?
    var hasMoreHistoryToLoad: Bool {
        lastHistoryDocument != nil
    }
    private var lastMedicineDocument: DocumentSnapshot?
    var hasMoreMedicines: Bool {
        lastMedicineDocument != nil
    }
    
    private var db = Firestore.firestore()
    
    func fetchMedicines(loadMore: Bool = false) async {
        switch MedicConfig.loadingMedicineStrategy {
        case .eager:
            await fetchMedicinesAndAisles()
        case .lazy:
            await fetchMedicinesPaged(loadMore: loadMore)
        }
    }
    
    private func fetchMedicinesAndAisles() async {
        isLoading = true
        do {
            let snapshot = try await db.collection("medicines").getDocuments()
            processMedicinesSnapshot(snapshot, error: nil)
            isLoading = false
        } catch {
            self.error = .fetchDataError
            isLoading = false
        }
    }
    
    private func fetchMedicinesPaged(loadMore: Bool = false) async {
        if !loadMore {
            medicines = []
        } else {
            isLoadingMore = true
        }
        
        var query = db.collection("medicines").limit(to: MedicConfig.pageSize + 1)
        
        if MedicConfig.useFirebaseFiltering {
            if !searchText.isEmpty {
                let upperBound = searchText.appending("\u{f8ff}")
                query = query.whereField("name", isGreaterThanOrEqualTo: searchText)
                    .whereField("name", isLessThan: upperBound)
            }
            
            switch sortOption {
            case .name: query = query.order(by: "name")
            case .stock: query = query.order(by: "stock")
            case .none: break
            }
        }
        
        do {
            let snapshot = try await query.getDocuments()
            processMedicinesSnapshot(snapshot, error: nil, loadMore: loadMore)
            if loadMore {
                isLoadingMore = false
            } else {
                isLoading = false
            }
        } catch {
            self.error = .fetchDataError
            isLoadingMore = false
            isLoading = false
        }
    }
    
    func addMedicine(name: String, stockString: String, aisle: String, user: String) async -> String? {
        guard !name.isEmpty else {
            error = .invalidMedicineName
            return nil
        }
        
        guard let stock = Int(stockString), stock >= 0 else {
            error = .invalidStock
            return nil
        }
        
        guard !aisle.isEmpty else {
            error = .invalidAisle
            return nil
        }
        
        let id = UUID().uuidString
        let medicine = Medicine(id: nil, name: name, stock: stock, aisle: aisle)
        
        do {
            try db.collection("medicines").document(id).setData(from: medicine)
            await addHistory(
                action: "Added \(medicine.name)",
                medicineId: id,
                details: "Added new medicine"
            )
            return id
        } catch {
            self.error = .addMedicineError
            return nil
        }
    }
    
    func updateStock(_ medicine: Medicine, by amount: Int, user: String) async {
        guard let id = medicine.id else {
            error = .invalidMedicineId
            return
        }
        
        let newStock = medicine.stock + amount
        guard newStock >= 0 else { return }
        
        let oldStock = medicine.stock
        if let index = medicines.firstIndex(where: { $0.id == id }) {
            medicines[index].stock = newStock
        }
        
        do {
            try await db.collection("medicines").document(id).updateData([
                "stock": newStock as NSNumber
            ] as [String : Any])
            
            await addHistory(
                action: "\(amount > 0 ? "Increased" : "Decreased") stock of \(medicine.name) by \(amount)",
                medicineId: id,
                details: "Stock changed from \(oldStock) to \(newStock)"
            )
            
            await fetchHistory(for: medicine)
            
        } catch {
            if let index = medicines.firstIndex(where: { $0.id == id }) {
                medicines[index].stock = oldStock
            }
            self.error = .updateStockError
        }
    }
    
    func deleteMedicine(_ medicine: Medicine, user: String) async {
        guard let id = medicine.id else {
            error = .invalidMedicineId
            return
        }
        
        do {
            try await db.collection("medicines").document(id).delete()
            
            await addHistory(
                action: "Deleted \(medicine.name)",
                medicineId: id,
                details: "Medicine removed from inventory"
            )
        } catch {
            self.error = .deleteMedicineError
        }
    }
    
    private func addHistory(action: String, medicineId: String, details: String) async {
        
        guard let currentUser = Auth.auth().currentUser, let userEmail = currentUser.email else { return }
        
        let history = HistoryEntry(
            medicineId: medicineId,
            userId: currentUser.uid,
            user: userEmail,
            action: action,
            details: details
        )
           
        do {
            try db.collection("history").addDocument(from: history)
        } catch {
            self.error = .addHistoryError
        }
    }
    
    func fetchHistory(for medicine: Medicine, loadMore: Bool = false) async {
        guard let medicineId = medicine.id else {
            error = .invalidMedicineId
            return
        }
        
        if !loadMore {
            history = []
            lastHistoryDocument = nil
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        var query = db.collection("history")
            .whereField("medicineId", isEqualTo: medicineId)
            .order(by: "timestamp", descending: true)
            .limit(to: MedicConfig.pageSize + 1)
        
        if loadMore, let last = lastHistoryDocument {
            query = query.start(afterDocument: last)
        }
        
        do {
            let snapshot = try await query.getDocuments()
            lastHistoryDocument = snapshot.documents.count > MedicConfig.pageSize ? snapshot.documents[MedicConfig.pageSize - 1] : nil

            _ = Array(snapshot.documents.prefix(MedicConfig.pageSize))
            processHistorySnapshot(snapshot, error: nil, loadMore: loadMore)
            
            isLoading = false
            if loadMore {
                isLoadingMore = false
            } else {
                isLoading = false
            }
        } catch {
            self.error = .fetchHistoryError
            isLoading = false
            isLoadingMore = false
        }
    }
    
    private func processHistorySnapshot(_ snapshot: QuerySnapshot?, error: Error?, loadMore: Bool = false) {
        guard error == nil else {
            self.error = .fetchHistoryError
            return
        }
        
        let entries = snapshot?.documents.prefix(MedicConfig.pageSize).compactMap { document in
            try? document.data(as: HistoryEntry.self)
        } ?? []
        
        if loadMore {
            history.append(contentsOf: entries)
        } else {
            history = entries
        }
    }
    
    private func processMedicinesSnapshot(_ snapshot: QuerySnapshot?, error: Error?, loadMore: Bool = false) {
        guard error == nil else {
            self.error = .fetchDataError
            return
        }
        
        let entries = snapshot?.documents.compactMap { document in
            try? document.data(as: Medicine.self)
        } ?? []
        
        if loadMore {
            medicines.append(contentsOf: entries)
        } else {
            medicines = entries
        }
        
        aisles = Array(Set(medicines.map { $0.aisle })).sorted()
    }
    
    var filteredAndSortedMedicines: [Medicine] {
        var filteredMedicines = medicines
        
        if !searchText.isEmpty {
            filteredMedicines = filteredMedicines.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
        
        switch sortOption {
        case .name:
            filteredMedicines.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .stock:
            filteredMedicines.sort { $0.stock < $1.stock }
        case .none:
            break
        }
        
        return filteredMedicines
    }
}
