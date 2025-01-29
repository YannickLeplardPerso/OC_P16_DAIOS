//
//  MediStockTests.swift
//  MediStockTests
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

//import Foundation
//import Testing
//import Firebase
//@testable import MediStock
//
//
//
//struct MedicineStockViewModelTests {
//    
//    private static let originalMedicineStrategy = MedicConfig.loadingMedicineStrategy
//    private static let originalHistoryStrategy = MedicConfig.loadingHistoryStrategy
//    
//    static func configureEmulator() {
//        Auth.auth().useEmulator(withHost: "localhost", port: 9099)
//        
//        let settings = Firestore.firestore().settings
//        settings.host = "localhost:8090"
//        settings.cacheSettings = MemoryCacheSettings()
//        settings.isSSLEnabled = false
//        Firestore.firestore().settings = settings
//    }
//    
//    static func setUp() async {
//        configureEmulator()
//    }
//    
//    static func tearDown() async {
//        MedicConfig.loadingMedicineStrategy = originalMedicineStrategy
//        MedicConfig.loadingHistoryStrategy = originalHistoryStrategy
//    }
//    
//    private func checkEmulatorConnection() async -> Bool {
//        do {
//            _ = try await Firestore.firestore().collection("test").document("test").getDocument()
//            return true
//        } catch {
//            return false
//        }
//    }
//    
//    private func initializeEmulator() async -> MedicineStockViewModel? {
//        guard await checkEmulatorConnection() else { return nil }
//        return MedicineStockViewModel()
//    }
//    
//    private func cleanupFirestore() async throws {
//        let db = Firestore.firestore()
//        
//        // 1. Récupérer et supprimer tous les documents de medicines
//        let medicines = try await db.collection("medicines").getDocuments()
//        for document in medicines.documents {
//            try await document.reference.delete()
//        }
//        try await Task.sleep(nanoseconds: 2_000_000_000)
//        
//        // 2. Récupérer et supprimer tous les documents d'history
//        let history = try await db.collection("history").getDocuments()
//        for document in history.documents {
//            try await document.reference.delete()
//        }
//        try await Task.sleep(nanoseconds: 2_000_000_000)
//        
//        // 3. Vérifier que tout est bien supprimé
//        let verifyMedicines = try await db.collection("medicines").getDocuments()
//        let verifyHistory = try await db.collection("history").getDocuments()
//        
//        if !verifyMedicines.documents.isEmpty || !verifyHistory.documents.isEmpty {
//            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "La base n'a pas été correctement nettoyée"])
//        }
//    }
//    
//    private func runTestWithStrategy(_ strategy: LoadingStrategy, test: (MedicineStockViewModel) async throws -> Void) async {
//        do {
//            MedicConfig.loadingMedicineStrategy = strategy
//            MedicConfig.loadingHistoryStrategy = strategy
//            
//            let viewModel = await initializeEmulator()
//            #expect(viewModel != nil, "L'émulateur Firebase n'est pas disponible")
//            guard let viewModel else { return }
//            
//            try await cleanupFirestore()
//            
//            // Vérifier que la base est vide
//            let verifyEmpty = try await Firestore.firestore().collection("medicines").getDocuments()
//            #expect(verifyEmpty.documents.isEmpty, "La base n'est pas vide après le nettoyage")
//            
//            // Seulement exécuter le test si la base est vide
//            if verifyEmpty.documents.isEmpty {
//                try await test(viewModel)
//            }
//        } catch {
//            #expect(Bool(false), "Erreur pendant l'exécution du test: \(error.localizedDescription)")
//        }
//    }
//    
//    // MARK: - Add Medicine Tests
//    @Test func testAddMedicineWithValidInput() async {
//        for strategy in [LoadingStrategy.eager, .lazy] {
//            await runTestWithStrategy(strategy) { viewModel in
//                let medicine = viewModel.addMedicine(
//                    name: "Test Medicine",
//                    stockString: "10",
//                    aisle: "A1",
//                    user: "testUser"
//                )
//                
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                #expect(medicine != nil)
//                #expect(medicine?.name == "Test Medicine")
//                #expect(medicine?.stock == 10)
//                #expect(medicine?.aisle == "A1")
//                #expect(viewModel.error == nil)
//                
//                viewModel.fetchMedicines()
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                #expect(viewModel.medicines.count == 1)
//            }
//        }
//    }
//    
//    @Test func testAddMedicineWithEmptyName() async {
//        await runTestWithStrategy(.lazy) { viewModel in
//            let medicine = viewModel.addMedicine(
//                name: "",
//                stockString: "10",
//                aisle: "A1",
//                user: "testUser"
//            )
//            
//            #expect(medicine == nil)
//            #expect(viewModel.error == .invalidMedicineName)
//        }
//    }
//    
//    @Test func testAddMedicineWithInvalidStock() async {
//        await runTestWithStrategy(.lazy) { viewModel in
//            let medicine = viewModel.addMedicine(
//                name: "Test Medicine",
//                stockString: "-5",
//                aisle: "A1",
//                user: "testUser"
//            )
//            
//            #expect(medicine == nil)
//            #expect(viewModel.error == .invalidStock)
//        }
//    }
//
//        @Test func testAddMedicineWithEmptyAisle() async {
//        await runTestWithStrategy(.lazy) { viewModel in
//            let medicine = viewModel.addMedicine(
//                name: "Test Medicine",
//                stockString: "10",
//                aisle: "",
//                user: "testUser"
//            )
//            
//            #expect(medicine == nil)
//            #expect(viewModel.error == .invalidAisle)
//        }
//    }
//    
//    // MARK: - Update Stock Tests
//    @Test func testUpdateStock() async {
//        for strategy in [LoadingStrategy.eager, .lazy] {
//            await runTestWithStrategy(strategy) { viewModel in
//                let medicine = viewModel.addMedicine(
//                    name: "Update Test",
//                    stockString: "5",
//                    aisle: "B2",
//                    user: "testUser"
//                )
//                
//                #expect(medicine != nil)
//                guard let validMedicine = medicine else { return }
//                
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                viewModel.fetchMedicines()
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                let initialMeds = viewModel.medicines
//                #expect(initialMeds.count == 1, "Un seul médicament devrait être présent")
//                #expect(initialMeds.first?.stock == 5, "Le stock initial devrait être 5")
//                
//                viewModel.updateStock(validMedicine, by: 3, user: "testUser")
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                viewModel.fetchMedicines()
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                let updatedMedicine = viewModel.medicines.first
//                #expect(updatedMedicine != nil, "Le médicament devrait exister")
//                #expect(updatedMedicine?.stock == 8, "Le stock devrait être 5 + 3 = 8")
//                #expect(viewModel.error == nil)
//            }
//        }
//    }
    
//    @Test func testUpdateStockBelowZero() async {
//        for strategy in [LoadingStrategy.eager, .lazy] {
//            await runTestWithStrategy(strategy) { viewModel in
//                let medicine = viewModel.addMedicine(
//                    name: "Low Stock Test",
//                    stockString: "2",
//                    aisle: "B2",
//                    user: "testUser"
//                )
//                
//                #expect(medicine != nil)
//                guard let validMedicine = medicine else { return }
//                
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                viewModel.fetchMedicines()
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                #expect(viewModel.medicines.count == 1)
//                #expect(viewModel.medicines.first?.stock == 2)
//                
//                viewModel.updateStock(validMedicine, by: -3, user: "testUser")
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                viewModel.fetchMedicines()
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                let unchangedMedicine = viewModel.medicines.first
//                #expect(unchangedMedicine != nil)
//                #expect(unchangedMedicine?.stock == 2, "Le stock ne devrait pas descendre en dessous de 0")
//            }
//        }
//    }
//    
//    // MARK: - Fetch and Filter Tests
//    @Test func testSearchMedicine() async {
//        for strategy in [LoadingStrategy.eager, .lazy] {
//            await runTestWithStrategy(strategy) { viewModel in
//                let med1 = viewModel.addMedicine(name: "Aspirin", stockString: "10", aisle: "A1", user: "testUser")
//                let med2 = viewModel.addMedicine(name: "Paracetamol", stockString: "20", aisle: "B2", user: "testUser")
//                
//                #expect(med1 != nil)
//                #expect(med2 != nil)
//                
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                viewModel.fetchMedicines()
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                #expect(viewModel.medicines.count == 2, "Devrait avoir exactement 2 médicaments")
//                
//                viewModel.searchText = "asp"
//                
//                let filteredMeds = viewModel.filteredAndSortedMedicines
//                #expect(filteredMeds.count == 1, "Devrait trouver exactement un médicament")
//                #expect(filteredMeds.first?.name == "Aspirin", "Devrait trouver Aspirin")
//            }
//        }
//    }
//    
//    // MARK: - History Tests
//    @Test func testFetchHistory() async {
//        for strategy in [LoadingStrategy.eager, .lazy] {
//            await runTestWithStrategy(strategy) { viewModel in
//                let medicine = viewModel.addMedicine(
//                    name: "History Test",
//                    stockString: "10",
//                    aisle: "A1",
//                    user: "testUser"
//                )
//                
//                #expect(medicine != nil)
//                guard let validMedicine = medicine else { return }
//                
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                viewModel.fetchMedicines()
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                #expect(viewModel.medicines.count == 1)
//                
//                viewModel.updateStock(validMedicine, by: 5, user: "testUser")
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                viewModel.fetchHistory(for: validMedicine)
//                try await Task.sleep(nanoseconds: 2_000_000_000)
//                
//                #expect(viewModel.history.isEmpty == false, "L'historique devrait contenir au moins une entrée")
//                #expect(viewModel.history.count == 2, "Devrait avoir 2 entrées : création et mise à jour")
//                #expect(viewModel.error == nil)
//            }
//        }
//    }


//}
