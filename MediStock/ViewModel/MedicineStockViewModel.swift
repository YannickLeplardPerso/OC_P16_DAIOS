import Foundation
import Firebase



class MedicineStockViewModel: ObservableObject {
    @Published var medicines: [Medicine] = []
    @Published var aisles: [String] = []
    @Published var history: [HistoryEntry] = []
    @Published var error: MedicError?
    private var db = Firestore.firestore()

//    func increaseStock(_ medicine: Medicine, user: String) {
//        updateStock(medicine, by: 1, user: user)
//    }
//
//    func decreaseStock(_ medicine: Medicine, user: String) {
//        updateStock(medicine, by: -1, user: user)
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


    func fetchMedicinesAndAisles() {
        db.collection("medicines").addSnapshotListener { [weak self] (querySnapshot, error) in
            DispatchQueue.main.async {
                if error != nil {
                    self?.error = .fetchDataError
                } else {
                    let medicines: [Medicine] = querySnapshot?.documents.compactMap { document in
                        do {
                            return try document.data(as: Medicine.self)
                        } catch {
                            self?.error = .decodingError
                            return nil
                        }
                    } ?? []
                    
                    self?.medicines = medicines
                    self?.aisles = Array(Set(medicines.map { $0.aisle })).sorted()
                    print("Found \(medicines.count) medicines in \(self?.aisles.count ?? 0) aisles")
                }
            }
        }
    }
//    func fetchMedicines() {
//        db.collection("medicines").addSnapshotListener { [weak self] (querySnapshot, error) in
//            DispatchQueue.main.async {
//                if error != nil {
//                    self?.error = .fetchMedicinesError
//                } else {
//                    self?.medicines = querySnapshot?.documents.compactMap { document in
//                        do {
//                            return try document.data(as: Medicine.self)
//                        } catch {
//                            self?.error = .fetchMedicinesError
//                            return nil
//                        }
//                    } ?? []
//                }
//            }
//        }
//    }
//
//    func fetchAisles() {
//        db.collection("medicines").addSnapshotListener { [weak self] (querySnapshot, error) in
//            DispatchQueue.main.async {
//                if error != nil {
//                    self?.error = .fetchAislesError
//                } else {
//                    let medicines: [Medicine] = querySnapshot?.documents.compactMap { document in
//                        do {
//                            return try document.data(as: Medicine.self)
//                        } catch {
//                            self?.error = .fetchAislesError
//                            return nil
//                        }
//                    } ?? []
//                    
//                    self?.medicines = medicines
//                    self?.aisles = Array(Set(medicines.map { $0.aisle })).sorted()
//                }
//            }
//        }
//    }
    
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
    
//    func addRandomMedicine(user: String) {
//        let medicine = Medicine(
//            name: "Medicine \(Int.random(in: 1...100))",
//            stock: Int.random(in: 1...100),
//            aisle: "Aisle \(Int.random(in: 1...10))"
//        )
//        
//        let id = medicine.id ?? UUID().uuidString
//        
//        do {
//            try db.collection("medicines").document(id).setData(from: medicine)
//            addHistory(
//                action: "Added \(medicine.name)",
//                user: user,
//                medicineId: id,
//                details: "Added new medicine"
//            )
//        } catch {
//            self.error = .addMedicineError
//        }
//    }
    
    func deleteMedicine(_ medicine: Medicine, user: String) {
        guard let id = medicine.id else {
            self.error = .invalidMedicineId
            return
        }
        
        db.collection("medicines").document(id).delete { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error deleting medicine: \(error)")
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
    func deleteMedicines(at offsets: IndexSet) {
        offsets.map { medicines[$0] }.forEach { medicine in
            guard let id = medicine.id else {
                self.error = .invalidMedicineId
                return
            }
            
            db.collection("medicines").document(id).delete { [weak self] error in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.error = .deleteMedicineError
                    }
                }
            }
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
//    func updateMedicine(_ medicine: Medicine, user: String) {
//        guard let id = medicine.id else { return }
//        do {
//            try db.collection("medicines").document(id).setData(from: medicine)
//            addHistory(action: "Updated \(medicine.name)", user: user, medicineId: id, details: "Updated medicine details")
//        } catch let error {
//            print("Error updating document: \(error)")
//        }
//    }

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
//    private func addHistory(action: String, user: String, medicineId: String, details: String) {
//        let history = HistoryEntry(medicineId: medicineId, user: user, action: action, details: details)
//        do {
//            try db.collection("history").document(history.id ?? UUID().uuidString).setData(from: history)
//        } catch let error {
//            print("Error adding history: \(error)")
//        }
//    }

    
    func fetchHistory(for medicine: Medicine) {
        guard let medicineId = medicine.id else {
            self.error = .invalidMedicineId
            return
        }
        
        db.collection("history")
            .whereField("medicineId", isEqualTo: medicineId)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.error = .fetchHistoryError
                    } else {
                        self?.history = querySnapshot?.documents.compactMap { document in
                            do {
                                return try document.data(as: HistoryEntry.self)
                            } catch {
                                self?.error = .fetchHistoryError
                                return nil
                            }
                        } ?? []
                    }
                }
            }
    }
}
