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
   private var viewModel: MedicineStockViewModel!
   
   override func setUp() async throws {
       viewModel = await MedicineStockViewModel()
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
       let error = await MainActor.run { viewModel.error }
       XCTAssertNil(error)
              
       await viewModel.fetchMedicines()
       
       let count = await MainActor.run { viewModel.medicines.count }
       XCTAssertEqual(count, 1)
       let addedMedicine = await MainActor.run { viewModel.medicines.first }
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
       let dbMedicine = await MainActor.run { viewModel.medicines.first }
       guard let dbMedicine else {
           XCTFail("Le médicament devrait exister")
           return
       }
       
       await viewModel.updateStock(dbMedicine, by: 5, user: "test@test.com")
       await viewModel.fetchMedicines()
       let first = await MainActor.run { viewModel.medicines.first?.stock }
       XCTAssertEqual(first, 15)
       
       let updatedMedicine = await MainActor.run { viewModel.medicines.first }
       guard let updatedMedicine else {
           XCTFail("Le médicament devrait exister")
           return
       }
       
       await viewModel.updateStock(updatedMedicine, by: -3, user: "test@test.com")
       await viewModel.fetchMedicines()
       let firstUpdate = await MainActor.run { viewModel.medicines.first?.stock }
       XCTAssertEqual(firstUpdate, 12)
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
       
       await MainActor.run { viewModel.searchText = "asp" }
       let count = await MainActor.run { viewModel.filteredAndSortedMedicines.count }
       XCTAssertEqual(count, 1)
       let name1 = await MainActor.run { viewModel.filteredAndSortedMedicines.first?.name }
       XCTAssertEqual(name1, ValidTestMedicine.aspirin.name)
       
       await MainActor.run { viewModel.searchText = "" }
       await MainActor.run { viewModel.sortOption = .name }
       let name2 = await MainActor.run { viewModel.filteredAndSortedMedicines.first?.name }
       XCTAssertEqual(name2, ValidTestMedicine.aspirin.name)
       
       await MainActor.run { viewModel.sortOption = .stock }
       let stock = await MainActor.run { viewModel.filteredAndSortedMedicines.first?.stock }
       XCTAssertEqual(stock, Int(ValidTestMedicine.aspirin.stock))
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
       let error1 = await MainActor.run { viewModel.error }
       XCTAssertEqual(error1, .invalidMedicineName)
       
       let invalidStock = InvalidTestMedicine.invalidStock
       let invalidStockId = await viewModel.addMedicine(
           name: invalidStock.name,
           stockString: invalidStock.stock,
           aisle: invalidStock.aisle,
           user: "test@test.com"
       )
       XCTAssertNil(invalidStockId)
       let error2 = await MainActor.run { viewModel.error }
       XCTAssertEqual(error2, .invalidStock)
       
       let emptyAisle = InvalidTestMedicine.emptyAisle
       let emptyAisleId = await viewModel.addMedicine(
           name: emptyAisle.name,
           stockString: emptyAisle.stock,
           aisle: emptyAisle.aisle,
           user: "test@test.com"
       )
       XCTAssertNil(emptyAisleId)
       let error3 = await MainActor.run { viewModel.error }
       XCTAssertEqual(error3, .invalidAisle)
   }
}
