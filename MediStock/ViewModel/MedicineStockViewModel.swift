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
            print("Error: no medicine id")
            return
        }
        let newStock = medicine.stock + amount
        print("Updating stock: current=\(medicine.stock), amount=\(amount), new=\(newStock)")  // Debug
        
        if newStock >= 0 {
            let oldStock = medicine.stock
            // Mise à jour optimiste
            if let index = self.medicines.firstIndex(where: { $0.id == id }) {
                self.medicines[index].stock = newStock
                print("Updated local stock to: \(self.medicines[index].stock)")  // Debug
            }
            
            print("Starting Firebase update...")
            db.collection("medicines").document(id).updateData([
                "stock": newStock
            ]) { [weak self] error in
                DispatchQueue.main.async {
                    print("Firebase callback with error: \(String(describing: error))")
                    if let error = error {
                        print("Error updating stock: \(error.localizedDescription)")
                        // Retour à l'ancienne valeur en cas d'erreur
                        if let index = self?.medicines.firstIndex(where: { $0.id == id }) {
                            self?.medicines[index].stock = oldStock
                        }
                        self?.error = .updateStockError
                    } else {
                        print("Successfully updated stock in Firebase")  // Debug
                        self?.addHistory(action: "\(amount > 0 ? "Increased" : "Decreased") stock of \(medicine.name) by \(amount)",
                                         user: user,
                                         medicineId: id,
                                         details: "Stock changed from \(oldStock) to \(newStock)")
                    }
                }
            }
        }
    }


    func fetchMedicines() {
        db.collection("medicines").addSnapshotListener { [weak self] (querySnapshot, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error getting documents: \(error)")
                    self?.error = .fetchMedicinesError
                } else {
                    self?.medicines = querySnapshot?.documents.compactMap { document in
                        do {
                            return try document.data(as: Medicine.self)
                        } catch {
                            print("Error decoding medicine: \(error)")
                            self?.error = .fetchMedicinesError
                            return nil
                        }
                    } ?? []
                }
            }
        }
    }
//    func fetchMedicines() {
//        db.collection("medicines").addSnapshotListener { (querySnapshot, error) in
//            if let error = error {
//                print("Error getting documents: \(error)")
//            } else {
//                self.medicines = querySnapshot?.documents.compactMap { document in
//                    try? document.data(as: Medicine.self)
//                } ?? []
//            }
//        }
//    }

    func fetchAisles() {
        db.collection("medicines").addSnapshotListener { [weak self] (querySnapshot, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error getting documents: \(error)")
                    self?.error = .fetchAislesError
                } else {
                    let medicines: [Medicine] = querySnapshot?.documents.compactMap { document in
                        do {
                            return try document.data(as: Medicine.self)
                        } catch {
                            print("Error decoding medicine: \(error)")
                            self?.error = .fetchAislesError
                            return nil
                        }
                    } ?? []
                    
                    self?.medicines = medicines
                    self?.aisles = Array(Set(medicines.map { $0.aisle })).sorted()
                }
            }
        }
    }
//    func fetchAisles() {
//        print("Fetching aisles...")
//        db.collection("medicines").addSnapshotListener { (querySnapshot, error) in
//            if let error = error {
//                print("Error getting documents: \(error)")
//            } else {
//                let allMedicines = querySnapshot?.documents.compactMap { document in
//                    try? document.data(as: Medicine.self)
//                } ?? []
//                print("Found \(allMedicines.count) medicines")
//                self.aisles = Array(Set(allMedicines.map { $0.aisle })).sorted()
//                // new
//                self.medicines = allMedicines
//            }
//        }
//    }
    
    func addRandomMedicine(user: String) {
        let medicine = Medicine(
            name: "Medicine \(Int.random(in: 1...100))",
            stock: Int.random(in: 1...100),
            aisle: "Aisle \(Int.random(in: 1...10))"
        )
        
        let id = medicine.id ?? UUID().uuidString
        
        do {
            try db.collection("medicines").document(id).setData(from: medicine)
            addHistory(
                action: "Added \(medicine.name)",
                user: user,
                medicineId: id,
                details: "Added new medicine"
            )
        } catch {
            print("Error adding document: \(error)")
            self.error = .addMedicineError
        }
    }
//    func addRandomMedicine(user: String) {
//        let medicine = Medicine(name: "Medicine \(Int.random(in: 1...100))", stock: Int.random(in: 1...100), aisle: "Aisle \(Int.random(in: 1...10))")
//        do {
//            try db.collection("medicines").document(medicine.id ?? UUID().uuidString).setData(from: medicine)
//            addHistory(action: "Added \(medicine.name)", user: user, medicineId: medicine.id ?? "", details: "Added new medicine")
//        } catch let error {
//            print("Error adding document: \(error)")
//        }
//    }

    
    
    
    func deleteMedicines(at offsets: IndexSet) {
        offsets.map { medicines[$0] }.forEach { medicine in
            guard let id = medicine.id else {
                self.error = .invalidMedicineId
                return
            }
            
            db.collection("medicines").document(id).delete { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error removing document: \(error)")
                        self?.error = .deleteMedicineError
                    }
                }
            }
        }
    }
//    func deleteMedicines(at offsets: IndexSet) {
//        offsets.map { medicines[$0] }.forEach { medicine in
//            if let id = medicine.id {
//                db.collection("medicines").document(id).delete { error in
//                    if let error = error {
//                        print("Error removing document: \(error)")
//                    }
//                }
//            }
//        }
//    }
    
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
            print("Error updating document: \(error)")
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
            print("Error adding history: \(error)")
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
                    if let error = error {
                        print("Error getting history: \(error)")
                        self?.error = .fetchHistoryError
                    } else {
                        self?.history = querySnapshot?.documents.compactMap { document in
                            do {
                                return try document.data(as: HistoryEntry.self)
                            } catch {
                                print("Error decoding history entry: \(error)")
                                self?.error = .fetchHistoryError
                                return nil
                            }
                        } ?? []
                    }
                }
            }
    }
//    func fetchHistory(for medicine: Medicine) {
//        guard let medicineId = medicine.id else { return }
//        db.collection("history").whereField("medicineId", isEqualTo: medicineId).addSnapshotListener { (querySnapshot, error) in
//            if let error = error {
//                print("Error getting history: \(error)")
//            } else {
//                self.history = querySnapshot?.documents.compactMap { document in
//                    try? document.data(as: HistoryEntry.self)
//                } ?? []
//            }
//        }
//    }
}
