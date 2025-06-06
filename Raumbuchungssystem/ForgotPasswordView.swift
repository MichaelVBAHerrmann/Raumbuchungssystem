//
//  ForgotPasswordView.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 06.06.25.
//
// MARK: - Fachliche Funktionalität
///
/// Eine Ansicht, die angezeigt wird, wenn der Benutzer auf "Passwort vergessen?" klickt.
/// Sie informiert den Benutzer auf humorvolle Weise darüber, dass diese Funktion nicht
/// implementiert ist, und zeigt dabei ein Bild an.
///
// MARK: - Technische Funktionalität
///
/// Eine einfache SwiftUI `View`. Sie verwendet die `@Environment`-Variable `dismiss`,
/// um sich selbst zu schließen (da sie als modaler Sheet präsentiert wird).
/// Sie zeigt ein `Image`-Element an, das aus den App-Assets geladen wird.
///
// MARK: - Besonderheiten
///
/// - **Benutzerdefinierter Button-Stil:** Der Button verwendet `.buttonStyle(PlainButtonStyle())`,
///   um den standardmäßigen blauen Fokus-Rahmen von macOS zu entfernen und ein vollständig
///   individuelles Aussehen zu ermöglichen.
/// - **Asset-Abhängigkeit:** Die Ansicht setzt voraus, dass ein Bild mit dem Namen "Esel"
///   im `Assets.xcassets`-Katalog des Projekts vorhanden ist.
///
// MARK: - Zusammenspiel und Abhängigkeiten
///
/// - **Wird aufgerufen von:** `LoginForm`, die diese Ansicht als Sheet präsentiert.
/// - **Abhängigkeiten:** Hat keine direkten Abhängigkeiten zu Daten-Managern oder anderen
///   logischen Modulen. Benötigt lediglich ein Bild-Asset.
///

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
