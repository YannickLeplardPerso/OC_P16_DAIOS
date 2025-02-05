//
//  MedicineStockViewModelTests.swift
//  MediStockTests
//
//  Created by Yannick LEPLARD on 04/02/2025.
//

import XCTest
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
@testable import MediStock



struct ValidTestMedicine {
   let name: String
   let stock: String
   let aisle: String
   
   static let aspirin = ValidTestMedicine(name: "Aspirine", stock: "10", aisle: "A1")
   static let paracetamol = ValidTestMedicine(name: "Paracétamol", stock: "20", aisle: "B1")
   static let ibuprofen = ValidTestMedicine(name: "Ibuprofène", stock: "15", aisle: "C1")
   static let stockTest = ValidTestMedicine(name: "Test Stock", stock: "10", aisle: "A1")
   
   static let allCases: [ValidTestMedicine] = [aspirin, paracetamol, ibuprofen, stockTest]
}

struct InvalidTestMedicine {
   let name: String
   let stock: String
   let aisle: String
   
   static let emptyName = InvalidTestMedicine(name: "", stock: "10", aisle: "A1")
   static let invalidStock = InvalidTestMedicine(name: "Test", stock: "-1", aisle: "A1")
   static let emptyAisle = InvalidTestMedicine(name: "Test", stock: "10", aisle: "")
}



class MedicineStockViewModelTests: XCTestCase {
   private let viewModel = MedicineStockViewModel()
   
   override func setUp() {
       super.setUp()
       print("INITIALISATION DES TESTS DE MEDICINESTOCKVIEWMODEL")
   }
   
   private func cleanupFirestore() async throws {
       let db = Firestore.firestore()
       for collection in ["medicines", "history"] {
           let documents = try await db.collection(collection).getDocuments()
           for doc in documents.documents {
               try await doc.reference.delete()
           }
       }
       try await Task.sleep(nanoseconds: 500_000_000)
   }
   
   func testEmulatorIsConnected() async throws {
       let db = Firestore.firestore()
       let host = db.settings.host
       XCTAssertEqual(host, "127.0.0.1:8090", "Firestore n'est pas configuré sur l'émulateur local")
       
       let testCollection = db.collection("test_emulator")
       let testId = UUID().uuidString
       let testDoc = testCollection.document(testId)
       
       try await testDoc.setData([
           "testField": "testValue",
           "timestamp": Date()
       ])
       
       let doc = try await testDoc.getDocument()
       let testField = doc.get("testField") as? String
       XCTAssertEqual(testField, "testValue", "Impossible de lire/écrire sur l'émulateur")
       
       try await testDoc.delete()
   }
   
   func testAddMedicine() async throws {
       try await cleanupFirestore()
       
       let medicine = ValidTestMedicine.aspirin
       let medicineId = viewModel.addMedicine(
           name: medicine.name,
           stockString: medicine.stock,
           aisle: medicine.aisle,
           user: "test@test.com"
       )
       
       try await Task.sleep(nanoseconds: 1_000_000_000)
       
       XCTAssertNotNil(medicineId, "L'ID devrait être retourné")
       XCTAssertNil(viewModel.error, "Aucune erreur ne devrait être présente")
       
       viewModel.fetchMedicines()
       try await Task.sleep(nanoseconds: 1_000_000_000)
       
       XCTAssertEqual(viewModel.medicines.count, 1, "Un seul médicament devrait être présent")
       let addedMedicine = viewModel.medicines.first
       XCTAssertEqual(addedMedicine?.name, medicine.name)
       XCTAssertEqual(addedMedicine?.stock, Int(medicine.stock))
       XCTAssertEqual(addedMedicine?.aisle, medicine.aisle)
   }
   
   func testUpdateStock() async throws {
       try await cleanupFirestore()
       
       let medicine = ValidTestMedicine.stockTest
       _ = viewModel.addMedicine(
           name: medicine.name,
           stockString: medicine.stock,
           aisle: medicine.aisle,
           user: "test@test.com"
       )
       
       try await Task.sleep(nanoseconds: 1_000_000_000)
       viewModel.fetchMedicines()
       try await Task.sleep(nanoseconds: 1_000_000_000)
       
       guard let dbMedicine = viewModel.medicines.first else {
           XCTFail("Le médicament devrait exister")
           return
       }
       
       viewModel.updateStock(dbMedicine, by: 5, user: "test@test.com")
       try await Task.sleep(nanoseconds: 1_000_000_000)
       viewModel.fetchMedicines()
       try await Task.sleep(nanoseconds: 1_000_000_000)
       
       XCTAssertEqual(viewModel.medicines.first?.stock, 15, "Le stock devrait être de 15")
       
       guard let updatedMedicine = viewModel.medicines.first else {
           XCTFail("Le médicament devrait exister")
           return
       }
       
       viewModel.updateStock(updatedMedicine, by: -3, user: "test@test.com")
       try await Task.sleep(nanoseconds: 1_000_000_000)
       viewModel.fetchMedicines()
       try await Task.sleep(nanoseconds: 1_000_000_000)
       
       XCTAssertEqual(viewModel.medicines.first?.stock, 12, "Le stock devrait être de 12")
       
       viewModel.fetchHistory(for: updatedMedicine)
       try await Task.sleep(nanoseconds: 1_000_000_000)
       
       XCTAssertEqual(viewModel.history.count, 3, "Il devrait y avoir 3 entrées d'historique")
   }
   
   func testSearchAndFilter() async throws {
       try await cleanupFirestore()
       
       for medicine in [ValidTestMedicine.aspirin, ValidTestMedicine.paracetamol, ValidTestMedicine.ibuprofen] {
           _ = viewModel.addMedicine(
               name: medicine.name,
               stockString: medicine.stock,
               aisle: medicine.aisle,
               user: "test@test.com"
           )
       }
       
       try await Task.sleep(nanoseconds: 1_000_000_000)
       viewModel.fetchMedicines()
       try await Task.sleep(nanoseconds: 1_000_000_000)
       
       viewModel.searchText = "asp"
       XCTAssertEqual(viewModel.filteredAndSortedMedicines.count, 1, "Devrait trouver un médicament")
       XCTAssertEqual(viewModel.filteredAndSortedMedicines.first?.name, ValidTestMedicine.aspirin.name)
       
       viewModel.searchText = ""
       viewModel.sortOption = .name
       let sortedByName = viewModel.filteredAndSortedMedicines
       XCTAssertEqual(sortedByName.first?.name, ValidTestMedicine.aspirin.name)
       
       viewModel.sortOption = .stock
       let sortedByStock = viewModel.filteredAndSortedMedicines
       XCTAssertEqual(sortedByStock.first?.stock, Int(ValidTestMedicine.aspirin.stock))
   }
   
   func testAddInvalidMedicines() async throws {
       try await cleanupFirestore()
       
       let emptyName = InvalidTestMedicine.emptyName
       let emptyNameId = viewModel.addMedicine(
           name: emptyName.name,
           stockString: emptyName.stock,
           aisle: emptyName.aisle,
           user: "test@test.com"
       )
       XCTAssertNil(emptyNameId)
       XCTAssertEqual(viewModel.error, .invalidMedicineName)
       
       let invalidStock = InvalidTestMedicine.invalidStock
       let invalidStockId = viewModel.addMedicine(
           name: invalidStock.name,
           stockString: invalidStock.stock,
           aisle: invalidStock.aisle,
           user: "test@test.com"
       )
       XCTAssertNil(invalidStockId)
       XCTAssertEqual(viewModel.error, .invalidStock)
       
       let emptyAisle = InvalidTestMedicine.emptyAisle
       let emptyAisleId = viewModel.addMedicine(
           name: emptyAisle.name,
           stockString: emptyAisle.stock,
           aisle: emptyAisle.aisle,
           user: "test@test.com"
       )
       XCTAssertNil(emptyAisleId)
       XCTAssertEqual(viewModel.error, .invalidAisle)
   }
}

//import Testing
//import FirebaseCore
//import FirebaseAuth
//import FirebaseFirestore
//@testable import MediStock
//
//
//
//struct ValidTestMedicine {
//    let name: String
//    let stock: String
//    let aisle: String
//    
//    static let aspirin = ValidTestMedicine(name: "Aspirine", stock: "10", aisle: "A1")
//    static let paracetamol = ValidTestMedicine(name: "Paracétamol", stock: "20", aisle: "B1")
//    static let ibuprofen = ValidTestMedicine(name: "Ibuprofène", stock: "15", aisle: "C1")
//    static let stockTest = ValidTestMedicine(name: "Test Stock", stock: "10", aisle: "A1")
//    
//    static let allCases: [ValidTestMedicine] = [aspirin, paracetamol, ibuprofen, stockTest]
//}
//
//struct InvalidTestMedicine {
//    let name: String
//    let stock: String
//    let aisle: String
//    
//    static let emptyName = InvalidTestMedicine(name: "", stock: "10", aisle: "A1")
//    static let invalidStock = InvalidTestMedicine(name: "Test", stock: "-1", aisle: "A1")
//    static let emptyAisle = InvalidTestMedicine(name: "Test", stock: "10", aisle: "")
//}
//
//
//
//struct MedicineStockViewModelTests {
//    private let viewModel = MedicineStockViewModel()
//    
//    init() {
//        print("INITIALISATION DES TESTS DE MEDICINESTOCKVIEWMODEL")
//    }
//    
//    private func cleanupFirestore() async throws {
//        let db = Firestore.firestore()
//        
//        for collection in ["medicines", "history"] {
//            let documents = try await db.collection(collection).getDocuments()
//            for doc in documents.documents {
//                try await doc.reference.delete()
//            }
//        }
//        
//        try await Task.sleep(nanoseconds: 500_000_000)
//    }
//    
//    @Test func testEmulatorIsConnected() async throws {
//        let db = Firestore.firestore()
//        let host = db.settings.host
//        #expect(host == "127.0.0.1:8090", "Firestore n'est pas configuré sur l'émulateur local")
//        
//        let testCollection = db.collection("test_emulator")
//        let testId = UUID().uuidString
//        let testDoc = testCollection.document(testId)
//        
//        try await testDoc.setData([
//            "testField": "testValue",
//            "timestamp": Date()
//        ])
//        
//        let doc = try await testDoc.getDocument()
//        let testField = doc.get("testField") as? String
//        #expect(testField == "testValue", "Impossible de lire/écrire sur l'émulateur")
//        
//        try await testDoc.delete()
//    }
//    
//    @Test func testAddMedicine() async throws {
//        try await cleanupFirestore()
//        
//        let medicine = ValidTestMedicine.aspirin
//        let medicineId = viewModel.addMedicine(
//            name: medicine.name,
//            stockString: medicine.stock,
//            aisle: medicine.aisle,
//            user: "test@test.com"
//        )
//        
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        
//        #expect(medicineId != nil, "L'ID devrait être retourné")
//        #expect(viewModel.error == nil, "Aucune erreur ne devrait être présente")
//        
//        viewModel.fetchMedicines()
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        
//        #expect(viewModel.medicines.count == 1, "Un seul médicament devrait être présent")
//        let addedMedicine = viewModel.medicines.first
//        #expect(addedMedicine?.name == medicine.name)
//        #expect(addedMedicine?.stock == Int(medicine.stock))
//        #expect(addedMedicine?.aisle == medicine.aisle)
//    }
//    
//    @Test func testUpdateStock() async throws {
//        try await cleanupFirestore()
//        
//        let medicine = ValidTestMedicine.stockTest
//        _ = viewModel.addMedicine(
//            name: medicine.name,
//            stockString: medicine.stock,
//            aisle: medicine.aisle,
//            user: "test@test.com"
//        )
//        
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        viewModel.fetchMedicines()
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        
//        guard let dbMedicine = viewModel.medicines.first else {
//            #expect(Bool(false), "Le médicament devrait exister")
//            return
//        }
//        
//        // Test augmentation stock
//        viewModel.updateStock(dbMedicine, by: 5, user: "test@test.com")
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        viewModel.fetchMedicines()
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        
//        #expect(viewModel.medicines.first?.stock == 15, "Le stock devrait être de 15")
//        
//        guard let updatedMedicine = viewModel.medicines.first else {
//            #expect(Bool(false), "Le médicament devrait exister")
//            return
//        }
//        
//        // Test diminution stock
//        viewModel.updateStock(updatedMedicine, by: -3, user: "test@test.com")
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        viewModel.fetchMedicines()
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        
//        #expect(viewModel.medicines.first?.stock == 12, "Le stock devrait être de 12")
//        
//        // Vérification historique
//        viewModel.fetchHistory(for: updatedMedicine)
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        
//        #expect(viewModel.history.count == 3, "Il devrait y avoir 3 entrées d'historique")
//    }
//    
//    @Test func testSearchAndFilter() async throws {
//        try await cleanupFirestore()
//        
//        // Ajout de plusieurs médicaments
//        for medicine in [ValidTestMedicine.aspirin, ValidTestMedicine.paracetamol, ValidTestMedicine.ibuprofen] {
//            _ = viewModel.addMedicine(
//                name: medicine.name,
//                stockString: medicine.stock,
//                aisle: medicine.aisle,
//                user: "test@test.com"
//            )
//        }
//        
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        viewModel.fetchMedicines()
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        
//        // Test recherche
//        viewModel.searchText = "asp"
//        #expect(viewModel.filteredAndSortedMedicines.count == 1, "Devrait trouver un médicament")
//        #expect(viewModel.filteredAndSortedMedicines.first?.name == ValidTestMedicine.aspirin.name, "Devrait trouver Aspirine")
//        
//        // Test tri par nom
//        viewModel.searchText = ""
//        viewModel.sortOption = .name
//        let sortedByName = viewModel.filteredAndSortedMedicines
//        #expect(sortedByName.first?.name == ValidTestMedicine.aspirin.name, "Devrait être trié par nom")
//        
//        // Test tri par stock
//        viewModel.sortOption = .stock
//        let sortedByStock = viewModel.filteredAndSortedMedicines
//        #expect(sortedByStock.first?.stock == Int(ValidTestMedicine.aspirin.stock), "Devrait être trié par stock")
//    }
//    
//    @Test func testAddInvalidMedicines() async throws {
//        try await cleanupFirestore()
//        
//        // Test nom vide
//        let emptyName = InvalidTestMedicine.emptyName
//        let emptyNameId = viewModel.addMedicine(
//            name: emptyName.name,
//            stockString: emptyName.stock,
//            aisle: emptyName.aisle,
//            user: "test@test.com"
//        )
//        #expect(emptyNameId == nil)
//        #expect(viewModel.error == .invalidMedicineName)
//        
//        // Test stock invalide
//        let invalidStock = InvalidTestMedicine.invalidStock
//        let invalidStockId = viewModel.addMedicine(
//            name: invalidStock.name,
//            stockString: invalidStock.stock,
//            aisle: invalidStock.aisle,
//            user: "test@test.com"
//        )
//        #expect(invalidStockId == nil)
//        #expect(viewModel.error == .invalidStock)
//        
//        // Test rayon vide
//        let emptyAisle = InvalidTestMedicine.emptyAisle
//        let emptyAisleId = viewModel.addMedicine(
//            name: emptyAisle.name,
//            stockString: emptyAisle.stock,
//            aisle: emptyAisle.aisle,
//            user: "test@test.com"
//        )
//        #expect(emptyAisleId == nil)
//        #expect(viewModel.error == .invalidAisle)
//    }
//}
