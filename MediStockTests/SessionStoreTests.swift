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



@MainActor
class SessionStoreTests: XCTestCase {
    private var sessionStore: SessionStore!
    
    override func setUp() async throws {
        print("SETUP")
        sessionStore = SessionStore()
        try await cleanupAuth()
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
        let user = ValidTestUser.signup
        await sessionStore.signUp(email: user.email, password: user.password)
        
        let session = sessionStore.session
        let error = sessionStore.error
        
        XCTAssertNotNil(session, "La session devrait être créée")
        XCTAssertNil(error, "Il ne devrait pas y avoir d'erreur")
    }
    
    func testSignInValidCredentials() async throws {
        let user = ValidTestUser.standard
        
        try await Auth.auth().createUser(withEmail: user.email, password: user.password)
        await sessionStore.signIn(email: user.email, password: user.password)
        
        print(sessionStore.error ?? "nil")
        
        let session = sessionStore.session
        print(session ?? "nil")
        let error = sessionStore.error
        print(error ?? "nil")
        
        XCTAssertNotNil(session, "La session devrait être créée")
        XCTAssertNil(error, "Il ne devrait pas y avoir d'erreur")
    }
    
    func testSignUpInvalidEmail() async throws {
        let user = InvalidTestUser.emptyEmail
        
        await sessionStore.signUp(email: user.email, password: user.password)
        let error = sessionStore.error
        
        XCTAssertEqual(error, .invalidEmail)
    }
    
    func testSignUpWeakPassword() async throws {
        let user = InvalidTestUser.weakPassword
        
        await sessionStore.signUp(email: user.email, password: user.password)
        let error = sessionStore.error
        
        XCTAssertEqual(error, .weakPassword)
    }
    
    func testSignOut() async throws {
        let user = ValidTestUser.signout
        
        await sessionStore.signUp(email: user.email, password: user.password)
        sessionStore.signOut()
        
        let session = sessionStore.session
        let error = sessionStore.error
        
        XCTAssertNil(session)
        XCTAssertNil(error)
    }
}
