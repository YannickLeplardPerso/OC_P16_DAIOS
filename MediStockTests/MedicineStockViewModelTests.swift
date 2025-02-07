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



@MainActor
class MedicineStockViewModelTests: XCTestCase {
   private var viewModel: MedicineStockViewModel!
   
   override func setUp() async throws {
       viewModel = MedicineStockViewModel()
       try await cleanupFirestore()
   }
   
   private func cleanupFirestore() async throws {
       let db = Firestore.firestore()
       for collection in ["medicines", "history"] {
           let documents = try await db.collection(collection).getDocuments()
           for doc in documents.documents {
               try await doc.reference.delete()
           }
       }
   }
   
   func testEmulatorIsConnected() async throws {
       let db = Firestore.firestore()
       XCTAssertEqual(db.settings.host, "127.0.0.1:8090")
       
       let testCollection = db.collection("test_emulator")
       let testId = UUID().uuidString
       let testDoc = testCollection.document(testId)
       
       try await testDoc.setData([
           "testField": "testValue",
           "timestamp": Date()
       ])
       
       let doc = try await testDoc.getDocument()
       let testField = doc.get("testField") as? String
       XCTAssertEqual(testField, "testValue")
       
       try await testDoc.delete()
   }
   
   func testAddMedicine() async throws {
       let medicine = ValidTestMedicine.aspirin
       let medicineId = await viewModel.addMedicine(
           name: medicine.name,
           stockString: medicine.stock,
           aisle: medicine.aisle,
           user: "test@test.com"
       )
       
       XCTAssertNotNil(medicineId)
       XCTAssertNil(viewModel.error)
       
       await viewModel.fetchMedicines()
       
       XCTAssertEqual(viewModel.medicines.count, 1)
       let addedMedicine = viewModel.medicines.first
       XCTAssertEqual(addedMedicine?.name, medicine.name)
       XCTAssertEqual(addedMedicine?.stock, Int(medicine.stock))
       XCTAssertEqual(addedMedicine?.aisle, medicine.aisle)
   }
   
   func testUpdateStock() async throws {
       let medicine = ValidTestMedicine.stockTest
       _ = await viewModel.addMedicine(
           name: medicine.name,
           stockString: medicine.stock,
           aisle: medicine.aisle,
           user: "test@test.com"
       )
       
       await viewModel.fetchMedicines()
       
       guard let dbMedicine = viewModel.medicines.first else {
           XCTFail("Le médicament devrait exister")
           return
       }
       
       await viewModel.updateStock(dbMedicine, by: 5, user: "test@test.com")
       await viewModel.fetchMedicines()
       XCTAssertEqual(viewModel.medicines.first?.stock, 15)
       
       guard let updatedMedicine = viewModel.medicines.first else {
           XCTFail("Le médicament devrait exister")
           return
       }
       
       await viewModel.updateStock(updatedMedicine, by: -3, user: "test@test.com")
       await viewModel.fetchMedicines()
       XCTAssertEqual(viewModel.medicines.first?.stock, 12)
       
       await viewModel.fetchHistory(for: updatedMedicine)
       XCTAssertEqual(viewModel.history.count, 3)
   }
   
   func testSearchAndFilter() async throws {
       for medicine in [ValidTestMedicine.aspirin, ValidTestMedicine.paracetamol, ValidTestMedicine.ibuprofen] {
           _ = await viewModel.addMedicine(
               name: medicine.name,
               stockString: medicine.stock,
               aisle: medicine.aisle,
               user: "test@test.com"
           )
       }
       
       await viewModel.fetchMedicines()
       
       viewModel.searchText = "asp"
       XCTAssertEqual(viewModel.filteredAndSortedMedicines.count, 1)
       XCTAssertEqual(viewModel.filteredAndSortedMedicines.first?.name, ValidTestMedicine.aspirin.name)
       
       viewModel.searchText = ""
       viewModel.sortOption = .name
       XCTAssertEqual(viewModel.filteredAndSortedMedicines.first?.name, ValidTestMedicine.aspirin.name)
       
       viewModel.sortOption = .stock
       XCTAssertEqual(viewModel.filteredAndSortedMedicines.first?.stock, Int(ValidTestMedicine.aspirin.stock))
   }
   
   func testAddInvalidMedicines() async throws {
       let emptyName = InvalidTestMedicine.emptyName
       let emptyNameId = await viewModel.addMedicine(
           name: emptyName.name,
           stockString: emptyName.stock,
           aisle: emptyName.aisle,
           user: "test@test.com"
       )
       XCTAssertNil(emptyNameId)
       XCTAssertEqual(viewModel.error, .invalidMedicineName)
       
       let invalidStock = InvalidTestMedicine.invalidStock
       let invalidStockId = await viewModel.addMedicine(
           name: invalidStock.name,
           stockString: invalidStock.stock,
           aisle: invalidStock.aisle,
           user: "test@test.com"
       )
       XCTAssertNil(invalidStockId)
       XCTAssertEqual(viewModel.error, .invalidStock)
       
       let emptyAisle = InvalidTestMedicine.emptyAisle
       let emptyAisleId = await viewModel.addMedicine(
           name: emptyAisle.name,
           stockString: emptyAisle.stock,
           aisle: emptyAisle.aisle,
           user: "test@test.com"
       )
       XCTAssertNil(emptyAisleId)
       XCTAssertEqual(viewModel.error, .invalidAisle)
   }
}
