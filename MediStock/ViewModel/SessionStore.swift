import Foundation
import Firebase

class SessionStore: ObservableObject {
    @Published var session: User?
    @Published var error: MedicError?
//    var handle: AuthStateDidChangeListenerHandle?

//    func listen() {
//        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
//            if let user = user {
//                self.session = User(uid: user.uid, email: user.email)
//            } else {
//                self.session = nil
//            }
//        }
//    }

    func signUp(email: String, password: String) {
        guard !email.isEmpty else {
            self.error = .invalidEmail
            return
        }
        guard !password.isEmpty else {
            self.error = .invalidPassword
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error as NSError? {
                switch error.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    self?.error = .emailAlreadyInUse
                case AuthErrorCode.invalidEmail.rawValue:
                    self?.error = .invalidEmail
                case AuthErrorCode.weakPassword.rawValue:
                    self?.error = .weakPassword
                default:
                    self?.error = .signInFailed
                }
            } else {
                self?.error = nil
                self?.session = User(uid: result?.user.uid ?? "", email: result?.user.email ?? "")
            }
        }
    }

    func signIn(email: String, password: String) {
        guard !email.isEmpty else {
            self.error = .invalidEmail
            return
        }
        guard !password.isEmpty else {
            self.error = .invalidPassword
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            if error != nil {
                self?.error = .signInFailed
            } else {
                self?.error = nil
                self?.session = User(uid: result?.user.uid ?? "", email: result?.user.email ?? "")
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.session = nil
            self.error = nil
        } catch {
            self.error = .signOutFailed
        }
    }

//    func unbind() {
//        if let handle = handle {
//            Auth.auth().removeStateDidChangeListener(handle)
//        }
//    }
}

struct User {
    var uid: String
    var email: String?
}
