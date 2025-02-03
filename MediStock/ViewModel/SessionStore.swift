import Foundation
import Firebase



class SessionStore: ObservableObject {
    @Published var session: User?
    @Published var error: MedicError?

    func signUp(email: String, password: String) {
        guard !email.isEmpty else {
            self.error = .invalidEmail
            return
        }
        guard isPasswordValid(password) else {
            self.error = .weakPassword
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error as NSError? {   
                switch error.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    self?.error = .emailAlreadyInUse
                case AuthErrorCode.invalidEmail.rawValue:
                    self?.error = .invalidEmail
                default:
                    self?.error = .signUpFailed
                }
            } else {
                self?.error = nil
                self?.session = User(uid: result?.user.uid ?? "", email: result?.user.email ?? "")
            }
        }
    }
    
    private func isPasswordValid(_ password: String) -> Bool {
       let passwordRegex = NSPredicate(format: "SELF MATCHES %@",
           "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>])[A-Za-z\\d!@#$%^&*(),.?\":{}|<>]{10,}$"
       )
       return passwordRegex.evaluate(with: password)
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
}

struct User {
    var uid: String
    var email: String?
}
