import Foundation
import Firebase



class MedicineStockViewModel: ObservableObject {
    @Published var medicines: [Medicine] = []
    @Published var aisles: [String] = []
    @Published var history: [HistoryEntry] = []
    @Published var error: MedicError?
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var sortOption: SortOption = .none
    @Published var currentQuery: Query?
    
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
    
//    func getMedicines() {
//        if MedicConfig.useFirebaseFiltering {
//            fetchMedicinesWithFilters()
//        } else {
//            fetchMedicinesAndAisles()
//            // puis filteredAndSortedMedicines s'applique sur les résultats
//        }
//    }
    
    func fetchMedicines(loadMore: Bool = false) {
        switch MedicConfig.loadingMedicineStrategy {
        case .eager:
            fetchMedicinesAndAisles()
        case .lazy:
            fetchMedicinesPaged(loadMore: loadMore)
        }
    }

    func fetchMedicinesAndAisles() {
        isLoading = true
        // Chargement initial
        db.collection("medicines").getDocuments { [weak self] (snapshot, error) in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.processMedicinesSnapshot(snapshot, error: error)
            }
        }
        // Écoute des changements
        db.collection("medicines").addSnapshotListener { [weak self] (snapshot, error) in
            DispatchQueue.main.async {
                self?.processMedicinesSnapshot(snapshot, error: error)
            }
        }
    }
    
    private func fetchMedicinesPaged(loadMore: Bool = false) {
        if !loadMore {
            medicines = []
//            isLoading = true
        }
        else {
            isLoadingMore = true
        }
        
        var query = db.collection("medicines")
            .limit(to: MedicConfig.pageSize + 1)
        
        // Ajouter filtrage si activé
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
        
        if loadMore, let last = lastMedicineDocument {
            query = query.start(afterDocument: last)
        }
        
        query.getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if loadMore {
                    self?.isLoadingMore = false
                } else {
                    self?.isLoading = false
                }
//                self?.isLoading = false
                self?.processMedicinesSnapshot(snapshot, error: error, loadMore: loadMore)
            }
        }
    }
    
    private func processMedicinesSnapshot(_ snapshot: QuerySnapshot?, error: Error?, loadMore: Bool = false) {
        if error != nil {
            self.error = .fetchDataError
            return
        }
        
        let entries: [Medicine] = snapshot?.documents.compactMap { document in
            do {
                return try document.data(as: Medicine.self)
            } catch {
                self.error = .fetchDataError
                return nil
            }
        } ?? []

        if MedicConfig.loadingMedicineStrategy == .lazy {
            if loadMore {
                medicines.append(contentsOf: entries.prefix(MedicConfig.pageSize))
            } else {
                medicines = Array(entries.prefix(MedicConfig.pageSize))
            }
            lastMedicineDocument = entries.count > MedicConfig.pageSize ?
                snapshot?.documents[MedicConfig.pageSize - 1] : nil
        } else {
            medicines = entries
        }
        
        aisles = Array(Set(medicines.map { $0.aisle })).sorted()
    }
    
    
    
    
    
    // Recherche et tri
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
    
    func fetchMedicinesWithFilters() {
        isLoading = true
        var query = db.collection("medicines") as Query
        
        if !searchText.isEmpty {
            let upperBound = searchText.appending("\u{f8ff}")
            query = query.whereField("name", isGreaterThanOrEqualTo: searchText)
                        .whereField("name", isLessThan: upperBound)
        }
        
        switch sortOption {
        case .name:
            query = query.order(by: "name")
        case .stock:
            query = query.order(by: "stock")
        case .none:
            break
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            query.getDocuments { [weak self] (snapshot, error) in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if error != nil {
                        self?.error = .fetchDataError
                        return
                    }
                    
                    self?.medicines = snapshot?.documents.compactMap { document in
                        try? document.data(as: Medicine.self)
                    } ?? []
                    self?.aisles = Array(Set(self?.medicines.map { $0.aisle } ?? [])).sorted()
                }
            }
        }
    }
    
    private func processMedicinesSnapshot(_ snapshot: QuerySnapshot?, error: Error?) {
        guard error == nil else {
            self.error = .fetchDataError
            return
        }
        
        let medicines: [Medicine] = snapshot?.documents.compactMap { document in
            do {
                return try document.data(as: Medicine.self)
            } catch {
                self.error = .decodingError
                return nil
            }
        } ?? []
        
        self.medicines = medicines
        self.aisles = Array(Set(medicines.map { $0.aisle })).sorted()
    }
    
    
    
    
    func addMedicine(name: String, stockString: String, aisle: String, user: String) -> Medicine? {
        guard !name.isEmpty else {
            self.error = .invalidMedicineName
            return nil
        }
        
        guard let stock = Int(stockString), stock >= 0 else {
            self.error = .invalidStock
            return nil
        }
        
        guard !aisle.isEmpty else {
            self.error = .invalidAisle
            return nil
        }
        
        let id = UUID().uuidString
        
        let medicine = Medicine(
            id: id,
            name: name,
            stock: stock,
            aisle: aisle
        )
        
        do {
            let id = UUID().uuidString
            try db.collection("medicines").document(id).setData(from: medicine)
            addHistory(
                action: "Added \(medicine.name)",
                user: user,
                medicineId: id,
                details: "Added new medicine"
            )
            return medicine
        } catch {
            self.error = .addMedicineError
            return nil
        }
    }
    
    func updateMedicine(_ medicine: Medicine, user: String) {
        guard let id = medicine.id else {
            self.error = .invalidMedicineId
            return
        }
        
        do {
            try db.collection("medicines").document(id).setData(from: medicine)
            addHistory(
                action: "Updated \(medicine.name)",
                user: user,
                medicineId: id,
                details: "Updated medicine details"
            )
        } catch {
            self.error = .updateMedicineError
        }
    }
    
    func deleteMedicine(_ medicine: Medicine, user: String) {
        guard let id = medicine.id else {
            self.error = .invalidMedicineId
            return
        }
        
        db.collection("medicines").document(id).delete { [weak self] error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.error = .deleteMedicineError
                } else {
                    self?.addHistory(
                        action: "Deleted \(medicine.name)",
                        user: user,
                        medicineId: id,
                        details: "Medicine removed from inventory"
                    )
                }
            }
        }
    }
    
    // rfu : suppression dans une liste par "swipe"
//    func deleteMedicines(at offsets: IndexSet) {
//        offsets.map { medicines[$0] }.forEach { medicine in
//            guard let id = medicine.id else {
//                self.error = .invalidMedicineId
//                return
//            }
//
//            db.collection("medicines").document(id).delete { [weak self] error in
//                DispatchQueue.main.async {
//                    if error != nil {
//                        self?.error = .deleteMedicineError
//                    }
//                }
//            }
//        }
//    }
    
    func updateStock(_ medicine: Medicine, by amount: Int, user: String) {
        guard let id = medicine.id else {
            error = .invalidMedicineId
            return
        }
        let newStock = medicine.stock + amount
        
        if newStock >= 0 {
            let oldStock = medicine.stock
            if let index = self.medicines.firstIndex(where: { $0.id == id }) {
                self.medicines[index].stock = newStock
            }
            
            db.collection("medicines").document(id).updateData([
                "stock": newStock
            ]) { [weak self] error in
                DispatchQueue.main.async {
                    if error != nil {
                        // Retour à l'ancienne valeur en cas d'erreur
                        if let index = self?.medicines.firstIndex(where: { $0.id == id }) {
                            self?.medicines[index].stock = oldStock
                        }
                        self?.error = .updateStockError
                    } else {
                        self?.addHistory(action: "\(amount > 0 ? "Increased" : "Decreased") stock of \(medicine.name) by \(amount)",
                                         user: user,
                                         medicineId: id,
                                         details: "Stock changed from \(oldStock) to \(newStock)")
                    }
                }
            }
        }
    }
    
    func fetchHistory(for medicine: Medicine, loadMore: Bool = false) {
        switch MedicConfig.loadingHistoryStrategy {
        case .eager:
            fetchHistoryEager(for: medicine)
        case .lazy:
            fetchHistoryPaged(for: medicine)
        }
    }
    
    func fetchHistoryEager(for medicine: Medicine) {
        guard let medicineId = medicine.id else {
            self.error = .invalidMedicineId
            return
        }
        
        isLoading = true
        
        // Chargement initial
        self.db.collection("history")
            .whereField("medicineId", isEqualTo: medicineId)
            .getDocuments { [weak self] (snapshot, error) in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.processHistorySnapshot(snapshot, error: error)
                }
            }
        // Listener pour les mises à jour
        db.collection("history")
            .whereField("medicineId", isEqualTo: medicineId)
            .addSnapshotListener { [weak self] (snapshot, error) in
                DispatchQueue.main.async {
                    self?.processHistorySnapshot(snapshot, error: error)
                }
            }
    }

    func fetchHistoryPaged(for medicine: Medicine, loadMore: Bool = false) {
        guard let medicineId = medicine.id else {
            self.error = .invalidMedicineId
            return
        }
        
        if !loadMore {
            history = []
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        var query = db.collection("history")
            .whereField("medicineId", isEqualTo: medicineId)
            .order(by: "timestamp", descending: true)
            .limit(to: MedicConfig.pageSize + 1) // pour ne pas afficher le bouton si il n'y a plus de données
        
        if loadMore, let last = lastHistoryDocument {
            query = query.start(afterDocument: last)
        }
        
        query.getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if loadMore {
                    self?.isLoadingMore = false
                } else {
                    self?.isLoading = false
                }
                self?.processHistorySnapshot(snapshot, error: error, loadMore: loadMore)
            }
        }
    }
    
    private func processHistorySnapshot(_ snapshot: QuerySnapshot?, error: Error?, loadMore: Bool = false) {
        if error != nil {
            self.error = .fetchHistoryError
            return
        }
        
        let entries: [HistoryEntry] = snapshot?.documents.compactMap { document in
            do {
                return try document.data(as: HistoryEntry.self)
            } catch {
                self.error = .fetchHistoryError
                return nil
            }
        } ?? []

        if MedicConfig.loadingHistoryStrategy == .lazy {
            if loadMore {
                history.append(contentsOf: entries.prefix(MedicConfig.pageSize))
            } else {
                history = Array(entries.prefix(MedicConfig.pageSize))
            }
            
            if entries.count > MedicConfig.pageSize {
                lastHistoryDocument = snapshot?.documents[MedicConfig.pageSize - 1]
            } else {
                lastHistoryDocument = nil
            }
//            lastHistoryDocument = entries.count > MedicConfig.pageSize ?
//            snapshot?.documents[MedicConfig.pageSize - 1] : nil
        } else {
            history = entries
        }
    }
    
    private func addHistory(action: String, user: String, medicineId: String, details: String) {
        let history = HistoryEntry(
            medicineId: medicineId,
            user: user,
            action: action,
            details: details
        )
        
        do {
            try db.collection("history").document(history.id ?? UUID().uuidString).setData(from: history)
        } catch {
            self.error = .addHistoryError
        }
    }
}
