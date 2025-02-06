//
//  SessionStoreTests.swift
//  MediStockTests
//
//  Created by Yannick LEPLARD on 04/02/2025.
//

import XCTest
import FirebaseCore
import FirebaseAuth
@testable import MediStock

struct ValidTestUser {
    let email: String
    let password: String
    
    static let standard = ValidTestUser(email: "test@test.com", password: "Test123456!")
    static let signup = ValidTestUser(email: "test123@test.com", password: "Test234567!")
    static let signout = ValidTestUser(email: "testout@test.com", password: "Test345678!")
    
    static let all: [ValidTestUser] = [standard, signup, signout]
}

struct InvalidTestUser {
    let email: String
    let password: String
    
    static let emptyEmail = InvalidTestUser(email: "", password: "Test123456!")
    static let weakPassword = InvalidTestUser(email: "test@test.com", password: "weak")
}

class SessionStoreTests: XCTestCase {
    private let sessionStore = SessionStore()
    private let maxAttempts = 10
    private let pollingInterval = UInt64(100_000_000) // 100ms
    
    private func waitForCondition(_ condition: @escaping () -> Bool) async throws {
        var attempts = 0
        while !condition() && attempts < maxAttempts {
            attempts += 1
            try await Task.sleep(nanoseconds: pollingInterval)
        }
    }
    
    private func cleanupAuth() async throws {
        for user in ValidTestUser.all {
            _ = try? await Auth.auth().signIn(withEmail: user.email, password: user.password)
            if let currentUser = Auth.auth().currentUser {
                try await currentUser.delete()
            }
        }
    }
    
    func testSignUpValidCredentials() async throws {
        try await cleanupAuth()
        let user = ValidTestUser.signup
        sessionStore.signUp(email: user.email, password: user.password)
        
        try await waitForCondition { self.sessionStore.session != nil }
        XCTAssertNotNil(sessionStore.session, "La session devrait être créée")
        XCTAssertNil(sessionStore.error, "Il ne devrait pas y avoir d'erreur")
    }
    
    func testSignInValidCredentials() async throws {
        try await cleanupAuth()
        let user = ValidTestUser.standard
        
        try await Auth.auth().createUser(withEmail: user.email, password: user.password)
        try await waitForCondition { Auth.auth().currentUser != nil }
        
        sessionStore.signIn(email: user.email, password: user.password)
        try await waitForCondition { self.sessionStore.session != nil }
        
        XCTAssertNotNil(sessionStore.session, "La session devrait être créée")
        XCTAssertNil(sessionStore.error, "Il ne devrait pas y avoir d'erreur")
    }
    
    func testSignUpInvalidEmail() async throws {
        try await cleanupAuth()
        let user = InvalidTestUser.emptyEmail
        
        sessionStore.signUp(email: user.email, password: user.password)
        try await waitForCondition { self.sessionStore.error != nil }
        XCTAssertEqual(sessionStore.error, .invalidEmail)
    }
    
    func testSignUpWeakPassword() async throws {
        try await cleanupAuth()
        let user = InvalidTestUser.weakPassword
        
        sessionStore.signUp(email: user.email, password: user.password)
        try await waitForCondition { self.sessionStore.error != nil }
        XCTAssertEqual(sessionStore.error, .weakPassword)
    }
    
    func testSignOut() async throws {
        try await cleanupAuth()
        let user = ValidTestUser.signout
        
        sessionStore.signUp(email: user.email, password: user.password)
        try await waitForCondition { self.sessionStore.session != nil }
        
        sessionStore.signOut()
        XCTAssertNil(sessionStore.session)
        XCTAssertNil(sessionStore.error)
    }
}

//import XCTest
//import FirebaseCore
//import FirebaseAuth
//@testable import MediStock
//
//
//
//struct ValidTestUser {
//   let email: String
//   let password: String
//   
//   static let standard = ValidTestUser(email: "test@test.com", password: "Test123456!")
//   static let signup = ValidTestUser(email: "test123@test.com", password: "Test234567!")
//   static let signout = ValidTestUser(email: "testout@test.com", password: "Test345678!")
//   
//   static let all: [ValidTestUser] = [standard, signup, signout]
//}
//
//struct InvalidTestUser {
//   let email: String
//   let password: String
//   
//   static let emptyEmail = InvalidTestUser(email: "", password: "Test123456!")
//   static let weakPassword = InvalidTestUser(email: "test@test.com", password: "weak")
//}
//
//
//
//class SessionStoreTests: XCTestCase {
//   private let sessionStore = SessionStore()
//   
//   override func setUp() {
//       super.setUp()
//   }
//   
//   private func cleanupAuth() async throws {
//       for user in ValidTestUser.all {
//           _ = try? await Auth.auth().signIn(withEmail: user.email, password: user.password)
//           if let currentUser = Auth.auth().currentUser {
//               try await currentUser.delete()
//           }
//       }
//       try await Task.sleep(nanoseconds: 500_000_000)
//   }
//   
//   func testSignUpValidCredentials() async throws {
//       try await cleanupAuth()
//       let user = ValidTestUser.signup
//       sessionStore.signUp(email: user.email, password: user.password)
//       try await Task.sleep(nanoseconds: 500_000_000)
//       
//       XCTAssertNotNil(sessionStore.session, "La session devrait être créée")
//       XCTAssertNil(sessionStore.error, "Il ne devrait pas y avoir d'erreur")
//   }
//   
//   func testSignInValidCredentials() async throws {
//       try await cleanupAuth()
//       let user = ValidTestUser.standard
//       
//       try await Auth.auth().createUser(withEmail: user.email, password: user.password)
//       try await Task.sleep(nanoseconds: 500_000_000)
//       
//       sessionStore.signIn(email: user.email, password: user.password)
//       try await Task.sleep(nanoseconds: 500_000_000)
//       
//       XCTAssertNotNil(sessionStore.session, "La session devrait être créée")
//       XCTAssertNil(sessionStore.error, "Il ne devrait pas y avoir d'erreur")
//   }
//   
//   func testSignUpInvalidEmail() async throws {
//       try await cleanupAuth()
//       let user = InvalidTestUser.emptyEmail
//       
//       sessionStore.signUp(email: user.email, password: user.password)
//       XCTAssertEqual(sessionStore.error, .invalidEmail)
//   }
//   
//   func testSignUpWeakPassword() async throws {
//       try await cleanupAuth()
//       let user = InvalidTestUser.weakPassword
//       
//       sessionStore.signUp(email: user.email, password: user.password)
//       XCTAssertEqual(sessionStore.error, .weakPassword)
//   }
//   
//   func testSignOut() async throws {
//       try await cleanupAuth()
//       let user = ValidTestUser.signout
//       
//       sessionStore.signUp(email: user.email, password: user.password)
//       try await Task.sleep(nanoseconds: 500_000_000)
//       
//       sessionStore.signOut()
//       XCTAssertNil(sessionStore.session)
//       XCTAssertNil(sessionStore.error)
//   }
//}
