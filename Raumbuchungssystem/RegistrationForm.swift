//
//  RegistrationForm.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 28.05.25.
//
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
