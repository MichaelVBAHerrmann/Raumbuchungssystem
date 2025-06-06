//
//  StartView.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 26.05.25.
//
// MARK: - Fachliche Funktionalität
///
/// Dies ist die Start-Ansicht, die einem nicht angemeldeten Benutzer präsentiert wird. Sie dient als
/// Einstiegspunkt für die Authentifizierung und zeigt entweder ein Login-Formular oder, nach
/// Auswahl, ein Registrierungs-Formular an.
///
// MARK: - Technische Funktionalität
///
/// Die `View` nutzt einen `GeometryReader`, um sich an die verfügbare Fenstergröße anzupassen.
/// Ein `@State`-Property `isRegistering` steuert per `if`-Abfrage, ob die `LoginForm` oder die
/// `RegistrationForm` angezeigt wird. Das Login-Formular ist zusätzlich in eine rein dekorative
/// `DeviceFrameView` eingebettet.
///
// MARK: - Besonderheiten
///
/// - **Hintergrundbild:** Ein vollflächiges Hintergrundbild sorgt für eine ansprechende Optik.
/// - **Responsives Design:** Die Größe des `DeviceFrameView` passt sich dynamisch an, hat aber eine
///   feste Mindestbreite, um bei sehr kleinen Fenstern nicht unbrauchbar klein zu werden.
///
// MARK: - Zusammenspiel und Abhängigkeiten
///
/// - **Enthält:** `LoginForm` und `RegistrationForm`.
/// - **Nutzt:** `DeviceFrameView` zur Dekoration.
/// - **Wird aufgerufen von:** `MainView`, wenn kein Benutzer angemeldet ist (`userStore.currentUser == nil`).
/// - **Interaktion:** Leitet Benutzeraktionen (Login, Registrierung) an die enthaltenen Formulare weiter,
///   welche dann mit dem `UserStore` interagieren.
///

import SwiftUI

struct StartView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isRegistering = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Hintergrundbild füllt alles
                Image("Startseite")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width,
                           height: geo.size.height)
                    .ignoresSafeArea()

                // Inhaltsschicht
                if isRegistering {
                    // Registrierungsmaske in der Mitte
                    RegistrationForm(username: $username,
                                     password: $password,
                                     onCancel: { isRegistering = false })
                        .frame(maxWidth: geo.size.width * 0.3)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                } else {
                    // iPhone in der Mitte
                    DeviceFrameView {
                        LoginForm(username: $username,
                                  password: $password,
                                  onRegister: { isRegistering = true })
                            .padding()
                    }
                    // MODIFIZIERTE ZEILE:
                    // Wir nehmen 35 % der Fensterbreite, aber nicht weniger als 280 Pixel.
                    // Dies verhindert, dass das iPhone bei sehr kleinen Fenstern unbrauchbar klein wird.
                    .frame(maxWidth: max(geo.size.width * 0.35, 280))
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }
        }
    }
}

// MARK: - Previews (bleiben unverändert)
#Preview("Mac / Großer Bildschirm (13-Zoll-Fenster)") {
    StartView()
        .frame(width: 1440, height: 900)
}

#Preview("iPad Pro (11-inch) Portrait") {
    StartView()
        .frame(width: 834, height: 1194)
}

#Preview("iPad Pro (11-inch) Landscape") {
    StartView()
        .frame(width: 1194, height: 834)
}

#Preview("iPhone 15 Pro Max Portrait") {
    StartView()
        .frame(width: 430, height: 932)
}

#Preview("iPhone SE (3rd gen) Portrait") {
    StartView()
        .frame(width: 375, height: 667)
}

#Preview("Benutzerdefiniert Klein (400 × 300)") {
    StartView()
        .frame(width: 400, height: 300)
}

#Preview("Benutzerdefiniert Mittel (900 × 600)") {
    StartView()
        .frame(width: 900, height: 600)
}
