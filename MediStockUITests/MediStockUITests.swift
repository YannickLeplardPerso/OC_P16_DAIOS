//
//  MediStockUITests.swift
//  MediStockUITests
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

import XCTest
//import FirebaseCore
//import FirebaseAuth



struct UITestUser {
    static var randEmail: String {
        "test\(UUID().uuidString)@test.com"
    }
    static let standardEmail = "test@test.com"
    static let password = "Test123456!"
}



final class MediStockUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        app.launch()
    }
    
    //    override func tearDown() {
    //        super.tearDown()
    //    }
    
    private func loginAsStandardUser() throws {
        let emailField = app.textFields[AccessID.authEmail]
        let passwordField = app.secureTextFields[AccessID.authPassword]
        let signUpButton = app.buttons["auth-sign-up-button"]
        let loginButton = app.buttons["auth-sign-in-button"]
        let okButton = app.buttons["OK"]
        
        // Essayer de se connecter d'abord
        emailField.tap()
        emailField.typeText(UITestUser.standardEmail)
        passwordField.tap()
        passwordField.typeText(UITestUser.password)
        app.keyboards.buttons["Return"].tap()
        loginButton.tap()
        
        // Si la connexion échoue (popup d'erreur), cliquer sur OK puis faire un signup
        if okButton.waitForExistence(timeout: 2) {
            okButton.tap()
            
            // effacement des champs email/password
            emailField.tap()
            emailField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: UITestUser.standardEmail.count))
            
            passwordField.tap()
            passwordField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: UITestUser.password.count))
            
            emailField.tap()
            emailField.typeText (UITestUser.standardEmail)
            passwordField.tap()
            passwordField.typeText(UITestUser.password)
            app.keyboards.buttons["Return"].tap()
            signUpButton.tap()
        }
        
        // Vérifier qu'on est bien connecté
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
    }
    
    // sign up - sign out - sign in
    func testAuthenticationFlow() throws {
        let testEmail = UITestUser.randEmail
        
        let emailField = app.textFields[AccessID.authEmail]
        let passwordField = app.secureTextFields[AccessID.authPassword]
        let loginButton = app.buttons[AccessID.authSignIn]
        let signUpButton = app.buttons[AccessID.authSignUp]
        // Sign up
        emailField.tap()
        emailField.typeText(testEmail)
        passwordField.tap()
        passwordField.typeText(UITestUser.password)
        app.keyboards.buttons["Return"].tap()
        signUpButton.tap()
        
        // Logout
        let logoutButton = app.buttons[AccessID.signOut]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()
        
        // Sign in
        emailField.tap()
        emailField.typeText(testEmail)
        
        passwordField.tap()
        passwordField.typeText(UITestUser.password)
        app.keyboards.buttons["Return"].tap()
        loginButton.tap()
        
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
    }
    
    func testAddMedicineInNewAisleAndVerify() throws {
        try loginAsStandardUser()
        
        app.buttons[AccessID.addMedicine].tap()
        
        let nameField = app.textFields[AccessID.medicineName]
        let stockField = app.textFields[AccessID.initialStock]
        XCTAssertTrue(nameField.exists)
        XCTAssertTrue(stockField.exists)
        
        let uniqueId = UUID().uuidString
        let medicineName = "MEDICINE \(uniqueId)"
        let aisleName = "AISLE \(uniqueId)"
        
        app.segmentedControls.buttons[AccessID.newAisleButton].tap()
        let aisleField = app.textFields[AccessID.newAisle]
        aisleField.tap()
        aisleField.typeText(aisleName)
        
        nameField.tap()
        nameField.typeText(medicineName)
        stockField.tap()
        stockField.typeText("10")
        
        app.buttons[AccessID.addMedicineConfirm].tap()
        
        let okButton = app.buttons["OK"]
        XCTAssertTrue(okButton.waitForExistence(timeout: 5))
        okButton.tap()
        
        let aisleButton = app.buttons["\(AccessID.aisleRow)-\(aisleName)"]
        XCTAssertTrue(aisleButton.waitForExistence(timeout: 5))
        aisleButton.tap()
        
        let medicineCell = app.staticTexts[medicineName]
        XCTAssertTrue(medicineCell.waitForExistence(timeout: 5))
    }
    
    func testStockManagement() throws {
        try loginAsStandardUser()
        
        // Créer un médicament avec un nom unique
        let uniqueId = UUID().uuidString
        let medicineName = "STOCKMEDIC \(uniqueId)"
        let aisleName = "STOCKAISLE \(uniqueId)"
        
        app.buttons[AccessID.addMedicine].tap()
        app.segmentedControls.buttons[AccessID.newAisleButton].tap()
        
        let aisleField = app.textFields[AccessID.newAisle]
        let nameField = app.textFields[AccessID.medicineName]
        let stockField = app.textFields[AccessID.initialStock]
        
        aisleField.tap()
        aisleField.typeText(aisleName)
        nameField.tap()
        nameField.typeText(medicineName)
        stockField.tap()
        stockField.typeText("10")
        
        app.buttons[AccessID.addMedicineConfirm].tap()
        
        let okButton = app.buttons["OK"]
        XCTAssertTrue(okButton.waitForExistence(timeout: 5))
        okButton.tap()
        
        let aisleButton = app.buttons["\(AccessID.aisleRow)-\(aisleName)"]
        XCTAssertTrue(aisleButton.waitForExistence(timeout: 5))
        aisleButton.tap()
        
        let medicineCell = app.staticTexts[medicineName]
        XCTAssertTrue(medicineCell.waitForExistence(timeout: 5))
        medicineCell.tap()
        
        let increaseButton = app.buttons[AccessID.increaseStock]
        let decreaseButton = app.buttons[AccessID.decreaseStock]
        let stockLabel = app.staticTexts[AccessID.currentStock]
        
        increaseButton.tap()
        XCTAssertEqual(stockLabel.label, "11")
        
        decreaseButton.tap()
        XCTAssertEqual(stockLabel.label, "10")
    }
    
    func testSearchAndSort() throws {
        try loginAsStandardUser()
        
        // Créer plusieurs médicaments avec des noms uniques mais préfixes fixes
        let uniqueId = UUID().uuidString
        let medicines = [
            "Tonnapex \(uniqueId)",
            "Aavigan \(uniqueId)",
            "Eternyl \(uniqueId)"
        ]
        
        for medicine in medicines {
            app.buttons[AccessID.addMedicine].tap()
            
            let nameField = app.textFields[AccessID.medicineName]
            let stockField = app.textFields[AccessID.initialStock]
            let aisleField = app.textFields[AccessID.newAisle]
            
            app.segmentedControls.buttons[AccessID.newAisleButton].tap()
            aisleField.tap()
            aisleField.typeText("AISLE \(medicine)")
            
            nameField.tap()
            nameField.typeText(medicine)
            stockField.tap()
            stockField.typeText("10")
            
            app.buttons[AccessID.addMedicineConfirm].tap()
            
            let okButton = app.buttons["OK"]
            XCTAssertTrue(okButton.waitForExistence(timeout: 5))
            okButton.tap()
        }
                
        let allMedicinesTab = app.buttons[AccessID.tabAllMedicines]
        allMedicinesTab.tap()
        
        // Tester la recherche
        let searchField = app.textFields[AccessID.searchMedicine]
        searchField.tap()
        searchField.typeText("iga")
        
        XCTAssertTrue(app.staticTexts["Aavigan \(uniqueId)"].exists)
        XCTAssertFalse(app.staticTexts["Tonnapex \(uniqueId)"].exists)
        XCTAssertFalse(app.staticTexts["Eternyl \(uniqueId)"].exists)
        
        // Tester le tri
        searchField.tap()
        searchField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 3))
        
        let sortPicker = app.segmentedControls[AccessID.sortMedicines]
        XCTAssertTrue(sortPicker.exists)
        
        sortPicker.buttons[AccessID.nameSort].tap()
        let firstCell = app.staticTexts["Aavigan \(uniqueId)"]
        XCTAssertTrue(firstCell.exists)
    }
}
   
   
   

//   func testSearchAndSort() throws {
//       try loginWithTestUser()
//       
//       // Ajouter plusieurs médicaments
//       let medicines = ["Aspirine", "Paracétamol", "Ibuprofène"]
//       for medicine in medicines {
//           app.buttons["add-medicine-button"].tap()
//           
//           let nameField = app.textFields["medicine-name-input"]
//           let stockField = app.textFields["initial-stock-input"]
//           
//           nameField.tap()
//           nameField.typeText(medicine)
//           stockField.tap()
//           stockField.typeText("10")
//           
//           app.buttons["add"].tap()
//           XCTAssertTrue(app.staticTexts[medicine].waitForExistence(timeout: 5))
//       }
//       
//       // Tester la recherche
//       let searchField = app.textFields["search-medicine"]
//       searchField.tap()
//       searchField.typeText("Asp")
//       
//       XCTAssertTrue(app.staticTexts["Aspirine"].exists)
//       XCTAssertFalse(app.staticTexts["Paracétamol"].exists)
//       XCTAssertFalse(app.staticTexts["Ibuprofène"].exists)
//       
//       // Tester le tri
//       searchField.tap()
//       searchField.clearText()
//       
//       let sortPicker = app.segmentedControls["sort-medicines"]
//       XCTAssertTrue(sortPicker.exists)
//       
//       sortPicker.buttons["Name"].tap()
//       let cells = app.cells.allElementsBoundByIndex
//       XCTAssertEqual(cells[0].staticTexts["Aspirine"].exists, true)
//   }




//extension XCUIElement {
//    func clearText() {
//        guard let stringValue = self.value as? String else {
//            return
//        }
//        
//        self.tap()
//        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
//        self.typeText(deleteString)
//    }
//}
