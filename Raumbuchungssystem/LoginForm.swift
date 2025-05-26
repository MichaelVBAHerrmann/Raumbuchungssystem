// LoginForm.swift
import SwiftUI

struct LoginForm: View {
    @Binding var username: String
    @Binding var password: String
    @EnvironmentObject private var userStore: UserStore
    // Kein onLogin Callback mehr direkt hier, da wir Alerts verwenden
    var onRegister: () -> Void // Callback, um isRegistering in StartView zu setzen

    // Für Alerts
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""


    var body: some View {
        VStack(spacing: 15) { // Etwas mehr Platz
            Text("Willkommen!") // Titel
                .font(.largeTitle)
                .fontWeight(.thin)
                .padding(.bottom, 20)
                .foregroundColor(Color.primary.opacity(0.8))


            TextField("Benutzername", text: $username)
                .textFieldStyle(.plain)
                .padding(12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10)) // Moderner Look
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4), lineWidth: 1))

            SecureField("Passwort", text: $password)
                .textFieldStyle(.plain)
                .padding(12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4), lineWidth: 1))

            Button {
                performLogin()
            } label: {
                Text("Login")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14) // Etwas höherer Button
                    .background(Color.accentColor.opacity(0.8)) // Verwendung der Akzentfarbe
                    .foregroundColor(.white)
                    .cornerRadius(10) // Konsistente Eckradien
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1), lineWidth: 1))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 10) // Abstand nach oben

            // Registrieren-Button
            Button {
                onRegister() // Ruft die onRegister Closure auf, die in StartView isRegistering = true setzt
            } label: {
                Text("Neuen Account erstellen")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.7)) // Grüne Farbe
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1), lineWidth: 1))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 8)


            Button {
                // TODO: Reset-Logik implementieren
                alertTitle = "Info"
                alertMessage = "Die Funktion 'Passwort vergessen' ist noch nicht implementiert."
                showingAlert = true
            } label: {
                Text("Passwort vergessen?")
                    .font(.footnote)
                    .foregroundColor(Color.accentColor) // Akzentfarbe für den Link
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 15)
        }
        .padding(20) // Gesamt-Padding für das Formular
        // Kein eigener Hintergrund für LoginForm, da es im DeviceFrameView platziert wird,
        // welches screenBackgroundColor hat.
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func performLogin() {
        // UserDefaults direkt abfragen, da UserStore.login bereits die Prüfung macht
        // und wir hier nur das Pop-up steuern wollen.
        // Die userStore.login Methode gibt true oder false zurück.
        let loginSuccess = userStore.login(username: username, password: password) //

        if loginSuccess {
            alertTitle = "Login erfolgreich"
            alertMessage = "Passwort korrekt."
        } else {
            // Prüfen, ob überhaupt Benutzer registriert sind, um eine bessere Fehlermeldung zu geben.
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
