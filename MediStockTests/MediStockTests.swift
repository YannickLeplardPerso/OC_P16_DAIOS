//
//  MediStockTests.swift
//  MediStockTests
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

import Testing
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
@testable import MediStock



protocol FirebaseTestable {
    func resetEmulatorData() async throws
}

struct MedicineStockViewModelTests: FirebaseTestable {
    static func setUp() async throws {
        MedicConfig.useEmulatorFirebase = true
        
        do {
            try await Auth.auth().createUser(withEmail: "test@test.com", password: "Test123456!")
        }
        
        try await Auth.auth().signIn(withEmail: "test@test.com", password: "Test123456!")
    }
    
    func resetEmulatorData() async throws {
        let db = Firestore.firestore()
        
        for collection in ["medicines", "history"] {
            let documents = try await db.collection(collection).getDocuments()
            for doc in documents.documents {
                try await doc.reference.delete()
            }
        }
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    @Test func testEmulatorIsConnected() async throws {
        let db = Firestore.firestore()
        let host = db.settings.host
        #expect(host == "127.0.0.1:8090", "Firestore n'est pas configuré sur l'émulateur local")
        
        // 2. Test d'écriture/lecture
        let testCollection = db.collection("test_emulator")
        let testId = UUID().uuidString
        let testDoc = testCollection.document(testId)
        
        try await testDoc.setData([
            "testField": "testValue",
            "timestamp": Date()
        ])
        
        let doc = try await testDoc.getDocument()
        let testField = doc.get("testField") as? String
        #expect(testField == "testValue", "Impossible de lire/écrire sur l'émulateur")
        
        try await testDoc.delete()
    }
    
    @Test func testAddMedicine() async throws {
        try await resetEmulatorData()
        
        let viewModel = MedicineStockViewModel()
        let medicineId = viewModel.addMedicine(
            name: "Aspirine",
            stockString: "10",
            aisle: "A1",
            user: "test@test.com"
        )
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Vérifie que l'ajout a réussi
        #expect(medicineId != nil, "L'ID devrait être retourné")
        #expect(viewModel.error == nil, "Aucune erreur ne devrait être présente")
        
        // Vérifie que le médicament est récupérable
        viewModel.fetchMedicines()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        #expect(viewModel.medicines.count == 1, "Un seul médicament devrait être présent")
        let addedMedicine = viewModel.medicines.first
        #expect(addedMedicine?.name == "Aspirine")
        #expect(addedMedicine?.stock == 10)
        #expect(addedMedicine?.aisle == "A1")
    }
    
//    @Test func testUpdateStock() async throws {
//        try await resetEmulatorData()
//        
//        let viewModel = MedicineStockViewModel()
//        
//        // Ajout initial
//        _ = viewModel.addMedicine(
//            name: "Test Stock",
//            stockString: "10",
//            aisle: "A1",
//            user: "test@test.com"
//        )
//        
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        viewModel.fetchMedicines()
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        
//        guard let medicine = viewModel.medicines.first else {
//            #expect(Bool(false), "Le médicament devrait exister")
//            return
//        }
//        
//        // Test augmentation stock
//        viewModel.updateStock(medicine, by: 5, user: "test@test.com")
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        viewModel.fetchMedicines()
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        
//        #expect(viewModel.medicines.first?.stock == 15, "Le stock devrait être de 15")
//        
//        // Test diminution stock
//        viewModel.updateStock(medicine, by: -3, user: "test@test.com")
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        viewModel.fetchMedicines()
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        
//        #expect(viewModel.medicines.first?.stock == 12, "Le stock devrait être de 12")
//        
//        // Vérification historique
//        viewModel.fetchHistory(for: medicine)
//        try await Task.sleep(nanoseconds: 1_000_000_000)
//        
//        #expect(viewModel.history.count == 3, "Il devrait y avoir 3 entrées d'historique")
//    }
    
    @Test func testSearchAndFilter() async throws {
        try await resetEmulatorData()
        
        let viewModel = MedicineStockViewModel()
        
        // Ajout de plusieurs médicaments
        _ = viewModel.addMedicine(name: "Aspirine", stockString: "10", aisle: "A1", user: "test@test.com")
        _ = viewModel.addMedicine(name: "Paracétamol", stockString: "20", aisle: "B1", user: "test@test.com")
        _ = viewModel.addMedicine(name: "Ibuprofène", stockString: "15", aisle: "C1", user: "test@test.com")
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        viewModel.fetchMedicines()
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Test recherche
        viewModel.searchText = "asp"
        #expect(viewModel.filteredAndSortedMedicines.count == 1, "Devrait trouver un médicament")
        #expect(viewModel.filteredAndSortedMedicines.first?.name == "Aspirine", "Devrait trouver Aspirine")
        
        // Test tri par nom
        viewModel.searchText = ""
        viewModel.sortOption = .name
        let sortedByName = viewModel.filteredAndSortedMedicines
        #expect(sortedByName.first?.name == "Aspirine", "Devrait être trié par nom")
        
        // Test tri par stock
        viewModel.sortOption = .stock
        let sortedByStock = viewModel.filteredAndSortedMedicines
        #expect(sortedByStock.first?.stock == 10, "Devrait être trié par stock")
    }
}



struct SessionStoreTests: FirebaseTestable {
    func resetEmulatorData() async throws {
        try Auth.auth().signOut()
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    static func setUp() async throws {
        MedicConfig.useEmulatorFirebase = true
    }
    
    @Test func testSignUpValidCredentials() async throws {
        let sessionStore = SessionStore()
        sessionStore.signUp(email: "test123@test.com", password: "Test123456!")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        #expect(sessionStore.session != nil)
        #expect(sessionStore.error == nil)
    }
    
    @Test func testSignInValidCredentials() async throws {
        let sessionStore = SessionStore()
        
        try await Auth.auth().createUser(withEmail: "test@test.com", password: "Test123456!")
        
        sessionStore.signIn(email: "test@test.com", password: "Test123456!")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        #expect(sessionStore.session != nil)
        #expect(sessionStore.error == nil)
    }

    @Test func testSignUpInvalidEmail() async throws {
        let sessionStore = SessionStore()
        sessionStore.signUp(email: "", password: "Test123456!")
        #expect(sessionStore.error == .invalidEmail)
    }

    @Test func testSignUpWeakPassword() async throws {
        let sessionStore = SessionStore()
        sessionStore.signUp(email: "test@test.com", password: "weak")
        #expect(sessionStore.error == .weakPassword)
    }

    @Test func testSignOut() async throws {
        let sessionStore = SessionStore()
        sessionStore.signUp(email: "testout@test.com", password: "Test123456!")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        sessionStore.signOut()
        #expect(sessionStore.session == nil)
        #expect(sessionStore.error == nil)
    }
}
