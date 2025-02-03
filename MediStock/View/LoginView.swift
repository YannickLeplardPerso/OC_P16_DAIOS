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
//            Text("Gestion de stock médical")
                .accessibilityIdentifier(AccessID.appTitle)
                .accessibilityAddTraits(.isHeader)
            Text("Medical inventory management")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 40)
            
            if MedicConfig.useEmulatorFirebase {
//                Text("⚠️ FIREBASE est en mode test\n(émulateur local) ⚠️")
                Text("⚠️ FIREBASE is in test mode\n(local emulator) ⚠️")
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(UIColor.systemOrange))
            }
            
            VStack {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .accessibilityHint("Enter your email address")
                    .accessibilityIdentifier(AccessID.authEmail)
                    .padding()
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .accessibilityHint("Enter your password. Must be at least 10 characters with one uppercase letter, one lowercase letter, one number and one special character.")
                    .accessibilityIdentifier(AccessID.authPassword)
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
                .accessibilityHint("Sign in with your email and password")
                .accessibilityIdentifier(AccessID.authSignIn)
                
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
                .accessibilityHint("Sign up with email and password")
                .accessibilityIdentifier(AccessID.authSignUp)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground)) 
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
        LoginView()
            .environmentObject(SessionStore())
    }
}
