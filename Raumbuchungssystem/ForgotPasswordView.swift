//
//  ForgotPasswordView.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 06.06.25.
//

// ForgotPasswordView.swift
import SwiftUI

struct ForgotPasswordView: View {
    // Environment-Variable, um die aktuelle Ansicht (den Sheet) zu schließen
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Das Bild des Esels aus den Assets
            // Stellen Sie sicher, dass Sie ein Bild namens "Esel" in Ihren Assets haben!
            Image("Esel")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300, maxHeight: 300)
                .padding()

            Text("Da hast du Pech!")
                .font(.title)
                .fontWeight(.bold)

            Spacer()

            // Button, um zum Startformular zurückzukehren
            Button {
                dismiss() // Schließt diese Ansicht
            } label: {
                Text("Zurück zum Login")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.8))
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
        }
        // Eine Mindestgröße für den Sheet festlegen
        .frame(minWidth: 400, minHeight: 500)
    }
}

#Preview {
    ForgotPasswordView()
}
