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
            Text("Registrierenn")
                .font(.title2)
                .bold()

            TextField("Benutzername festlegen", text: $username)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 1))

            SecureField("Passwort festlegen", text: $password)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 1))

            // Aktionen
            HStack(spacing: 16) {
                Button {
                    onCancel()
                } label: {
                    Text("Abbrechen")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())

                Button {
                    // TODO: Persistieren und schließen
                    onCancel()
                } label: {
                    Text("Anmeldung abschließen")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
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
