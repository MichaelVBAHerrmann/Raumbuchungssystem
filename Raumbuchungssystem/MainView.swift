//
//  MainView.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 02.06.25.
//
//
//  MainView.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 02.06.25.
//
// MARK: - Fachliche Funktionalität
///
/// Dient als zentrale Weiche oder "Router" der Anwendung. Basierend auf dem Anmeldestatus des Benutzers
/// entscheidet diese Ansicht, ob die Login-Seite (`StartView`) oder die Hauptansicht zur Raumbuchung
/// (`CalendarBookingView`) angezeigt wird.
///
// MARK: - Technische Funktionalität
///
/// Eine SwiftUI `View`, die den `UserStore` aus der Umgebung (`@EnvironmentObject`) beobachtet.
/// Sie enthält eine `if`-Abfrage, die den Wert von `userStore.currentUser` prüft. Ist dieser `nil`,
/// wird die `StartView` gerendert, andernfalls die `CalendarBookingView`.
///
// MARK: - Besonderheiten
///
/// Dieses Modul ist bewusst sehr einfach gehalten. Seine einzige Aufgabe ist die Steuerung
/// des Haupt-Navigationsflusses der App, was die Logik klar und wartbar hält.
///
// MARK: - Zusammenspiel und Abhängigkeiten
///
/// - **Abhängigkeiten:** Hängt direkt vom `UserStore` ab, um den Login-Status zu prüfen.
/// - **Zeigt an:** Entweder `StartView` oder `CalendarBookingView` als untergeordnete Hauptansicht.
/// - **Wird aufgerufen von:** `RaumbuchungssystemApp` als erste und einzige direkte View.
///

import SwiftUI

struct MainView: View {
    @EnvironmentObject var userStore: UserStore

    var body: some View {
        if userStore.currentUser == nil {
            StartView() // Deine bestehende StartView für Login/Registrierung
        } else {
            CalendarBookingView() // Die neue Hauptansicht für die Raumbuchung
        }
    }
}
