import Foundation
import Firebase



@MainActor
class SessionStore: ObservableObject {
    @Published var session: User?
    @Published var error: MedicError?

//    func signUp(email: String, password: String) {
    func signUp(email: String, password: String) async {
        guard !email.isEmpty else {
            self.error = .invalidEmail
            return
        }
        guard isPasswordValid(password) else {
            self.error = .weakPassword
            return
        }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            error = nil
            session = User(uid: result.user.uid, email: result.user.email)
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                self.error = .emailAlreadyInUse
            case AuthErrorCode.invalidEmail.rawValue:
                self.error = .invalidEmail
            default:
                self.error = .signUpFailed
            }
        }
    }
    
    private func isPasswordValid(_ password: String) -> Bool {
       let passwordRegex = NSPredicate(format: "SELF MATCHES %@",
           "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>])[A-Za-z\\d!@#$%^&*(),.?\":{}|<>]{10,}$"
       )
       return passwordRegex.evaluate(with: password)
    }

    func signIn(email: String, password: String) async {
        guard !email.isEmpty else {
            error = .invalidEmail
            return
        }
        guard !password.isEmpty else {
            error = .invalidPassword
            return
        }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            error = nil
            session = User(uid: result.user.uid, email: result.user.email)
        } catch {
            self.error = .signInFailed
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
}

struct User {
    var uid: String
    var email: String?
}
