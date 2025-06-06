//
//  RaumbuchungssystemApp.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 26.05.25.
//
// MARK: - Fachliche Funktionalität
///
/// Haupt-Einstiegspunkt der Anwendung.
/// Initialisiert die gesamte App-Umgebung, lädt die zentralen Daten-Manager (Stores)
/// und entscheidet, welche Hauptansicht dem Benutzer zuerst gezeigt wird.
///
// MARK: - Technische Funktionalität
///
/// Nutzt das `@main` Attribut, um sich als Startpunkt der App zu deklarieren.
/// Erstellt Instanzen der zentralen Daten-Manager (`UserStore`, `RoomStore`, `BookingManager`)
/// als `@StateObject`. Dies stellt sicher, dass sie nur einmal während des gesamten App-Lebenszyklus
/// erstellt und nicht zerstört werden, solange die App läuft.
///
// MARK: - Besonderheiten
///
/// Das Modul injiziert alle drei "Stores" als `@EnvironmentObject` in die SwiftUI-View-Hierarchie.
/// Dadurch kann jede untergeordnete View (wie z.B. `MainView` oder `CalendarBookingView`)
/// einfach auf diese globalen Daten-Manager zugreifen, ohne sie manuell durch alle Ebenen
/// weiterreichen zu müssen.
///
// MARK: - Zusammenspiel und Abhängigkeiten
///
/// - **Initialisiert:** `UserStore`, `RoomStore`, `BookingManager`.
/// - **Stellt bereit für:** Die gesamte SwiftUI-View-Hierarchie, beginnend mit `MainView`.
/// - **Abhängigkeiten:** Ist das Wurzel-Modul und hat keine Abhängigkeiten zu anderen Modulen,
///   initialisiert diese aber.
///

import SwiftUI

@main
struct RaumBuchungssystemApp: App {
    @StateObject private var userStore = UserStore()
    @StateObject private var roomStore = RoomStore() // Neu
    @StateObject private var bookingManager = BookingManager() // Neu

    var body: some Scene {
        WindowGroup {
            MainView() // Wir erstellen eine neue MainView
                .environmentObject(userStore)
                .environmentObject(roomStore) // Neu
                .environmentObject(bookingManager) // Neu
        }
    }
}
