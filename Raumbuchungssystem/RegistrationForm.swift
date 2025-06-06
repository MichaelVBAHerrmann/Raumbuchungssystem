//
//  RegistrationForm.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 28.05.25.
//
// MARK: - Fachliche Funktionalität
///
/// Stellt eine Benutzeroberfläche zur Verfügung, über die sich neue Benutzer mit einem
/// Benutzernamen und einem Passwort im System registrieren können.
///
// MARK: - Technische Funktionalität
///
/// Eine SwiftUI `View`, die über `@Binding`-Variablen die Eingaben für `username` und `password`
/// von der übergeordneten `StartView` empfängt. Ein `onCancel` Callback wird genutzt,
/// um der `StartView` mitzuteilen, dass die Registrierungsansicht geschlossen werden soll.
/// Die eigentliche Speicherlogik der Registrierung ist nicht Teil dieses Moduls.
///
// MARK: - Besonderheiten
///
/// Das Design der Eingabefelder und Buttons ist an das der `LoginForm` angelehnt, um ein
/// konsistentes Erscheinungsbild zu gewährleisten. Der Button "Anmeldung abschließen" führt
/// aktuell dieselbe Aktion aus wie "Abbrechen". Die Logik zum Aufruf von `userStore.register`
/// muss in der übergeordneten View implementiert werden.
///
// MARK: - Zusammenspiel und Abhängigkeiten
///
/// - **Wird enthalten von:** `StartView`.
/// - **Kommuniziert mit `StartView`:** Empfängt Daten über `@Binding`s und sendet ein "Abbrechen"-Signal
///   über den `onCancel` Callback.
/// - **Indirekte Abhängigkeit:** Die hier erfassten Daten sind für den `UserStore` bestimmt,
///   aber es gibt keine direkte Verbindung von diesem Modul zum `UserStore`.
///

import SwiftUI
// MARK: - RegistrationForm
struct RegistrationForm: View {
    @Binding var username: String
    @Binding var password: String
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Registrieren")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 20)
                .foregroundColor(.black)

            // Benutzername‑Feld – gleicher Stil wie im LoginForm
            ZStack(alignment: .leading) {
                if username.isEmpty {
                    Text("Benutzername festlegen")
                        .foregroundColor(Color.gray.opacity(0.7))   // dunkles Grau für Placeholder
                        .padding(.leading, 16)
                }
                TextField("", text: $username)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .foregroundColor(.black)                       // eingegebener Text in Schwarz
            }
            .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1))

            // Passwort‑Feld – gleicher Stil wie im LoginForm
            ZStack(alignment: .leading) {
                if password.isEmpty {
                    Text("Passwort festlegen")
                        .foregroundColor(Color.gray.opacity(0.7))
                        .padding(.leading, 16)
                }
                SecureField("", text: $password)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .foregroundColor(.black)
            }
            .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1))

            // Aktionen
            HStack(spacing: 16) {
                Button {
                    onCancel()
                } label: {
                    Text("Abbrechen")
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

                Button {
                    // TODO: Persistieren und schließen
                    onCancel()
                } label: {
                    Text("Anmeldung abschließen")
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
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.9))
                .shadow(color: Color.black.opacity(0.1), radius: 10, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}


#Preview("RegistrationForm Preview") {
    RegistrationForm(
        username: .constant("DemoUser"),
        password: .constant("secret"),
        onCancel: {}
    )
    .frame(width: 400, height: 600)
}
