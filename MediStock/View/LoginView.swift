import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var session: SessionStore

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("MediStock")
                .font(.system(size: 40, weight: .bold))
                .padding(.top, 60)
            Text("Gestion de stock médical")
                .font(.subheadline)
                .foregroundColor(.secondary)  // S'adapte automatiquement
                .padding(.bottom, 40)
            
            VStack {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            .frame(maxWidth: 350)
            
            VStack(spacing: 15) {
                Button(action: {
                    session.signIn(email: email, password: password)
                }) {
                    Text("Login")
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.systemBackground))
                        .frame(maxWidth: 350)
                        .frame(height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    session.signUp(email: email, password: password)
                }) {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: 350)
                        .frame(height: 50)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))  // S'adapte automatiquement
        .edgesIgnoringSafeArea(.all)
        .alert(item: $session.error) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(SessionStore())
    }
}
