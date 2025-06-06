// LoginForm.swift
import SwiftUI

struct LoginForm: View {
    @Binding var username: String
    @Binding var password: String
    @EnvironmentObject private var userStore: UserStore
    var onRegister: () -> Void

    // Alter Alert-State wird nicht mehr für "Passwort vergessen" benötigt
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // Neuer State, um den ForgotPassword-Sheet anzuzeigen
    @State private var showingForgotPasswordSheet = false

    var body: some View {
        VStack(spacing: 15) {
            Text("Willkommen!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
                .foregroundColor(.black)

            ZStack(alignment: .leading) {
                if username.isEmpty {
                    Text("Benutzername")
                        .foregroundColor(Color.gray.opacity(0.7))
                        .padding(.leading, 16)
                }
                TextField("", text: $username)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .foregroundColor(.black)
            }
            .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4), lineWidth: 1))

            ZStack(alignment: .leading) {
                if password.isEmpty {
                    Text("Passwort")
                        .foregroundColor(Color.gray.opacity(0.7))
                        .padding(.leading, 16)
                }
                SecureField("", text: $password)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .foregroundColor(.black)
            }
            .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4), lineWidth: 1))

            Button {
                performLogin()
            } label: {
                Text("Login")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.4),
                            radius: 4, x: 0, y: 3)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 10)

            Button {
                onRegister()
            } label: {
                Text("Registrieren")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.4),
                            radius: 4, x: 0, y: 3)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 8)

            // GEÄNDERTER BUTTON: Ruft jetzt den Sheet auf
            Button {
                showingForgotPasswordSheet = true // Setzt den State, um den Sheet zu öffnen
            } label: {
                Text("Passwort vergessen?")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.4),
                            radius: 4, x: 0, y: 3)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 15)
        }
        .padding(20)
        // Der Alert für Login-Fehler bleibt erhalten
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        // NEUER MODIFIER: Präsentiert die ForgotPasswordView als Sheet
        .sheet(isPresented: $showingForgotPasswordSheet) {
            ForgotPasswordView()
        }
    }

    func performLogin() {
        let loginSuccess = userStore.login(username: username, password: password)

        if loginSuccess {
            alertTitle = "Login erfolgreich"
            alertMessage = "Passwort korrekt."
        } else {
            if userStore.users.isEmpty {
                alertTitle = "Fehler"
                alertMessage = "Keine Benutzer registriert. Bitte erstellen Sie zuerst einen Account."
            } else if !userStore.users.contains(where: { $0.username == username }) {
                alertTitle = "Fehler"
                alertMessage = "Benutzername nicht gefunden."
            }
            else {
                alertTitle = "Login fehlgeschlagen"
                alertMessage = "Das Passwort ist falsch."
            }
        }
        showingAlert = true
    }
}

#Preview("LoginForm Preview") {
    LoginForm(
        username: .constant(""),
        password: .constant(""),
        onRegister: {}
    )
    .environmentObject(UserStore())
    .padding()
    .background(Color.gray.opacity(0.1))
}
