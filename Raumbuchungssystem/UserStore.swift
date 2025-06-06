// UserStore.swift
// MARK: - Fachliche Funktionalität
///
/// Dient als zentraler Daten-Manager für alle benutzerbezogenen Informationen und Aktionen.
/// Er verwaltet die Liste aller registrierten Benutzer, kümmert sich um die Logik für
/// Registrierung, Login und Logout und hält den aktuell angemeldeten Benutzer als
/// "Source of Truth" (alleinige Wahrheitsquelle) für die gesamte App vor.
///
// MARK: - Technische Funktionalität
///
/// Ein als `final class` deklarierter `ObservableObject`. Er publiziert Änderungen an seinen
/// `@Published` Properties (`users`, `currentUser`), wodurch SwiftUI-Views, die ihn beobachten,
/// automatisch neu gerendert werden (z.B. bei Login/Logout).
/// Benutzerdaten werden zur Persistenz mittels `JSONEncoder` in `UserDefaults` als JSON gespeichert
/// und beim App-Start mit `JSONDecoder` wieder geladen.
///
// MARK: - Besonderheiten
///
/// - **Sicherheitshinweis:** In dieser Implementierung werden Passwörter zur Vereinfachung als
///   Klartext-Strings in den `UserDefaults` gespeichert. In einer produktiven Anwendung ist dies
///   ein Sicherheitsrisiko. Passwörter sollten stattdessen sicher gehasht (z.B. mit Argon2, bcrypt)
///   und idealerweise im `Keychain` des Systems gespeichert werden.
///
// MARK: - Zusammenspiel und Abhängigkeiten
///
/// - **Wird initialisiert von:** `RaumbuchungssystemApp` und als `@EnvironmentObject` bereitgestellt.
/// - **Wird genutzt von:**
///   - `MainView`: Um basierend auf `currentUser` die korrekte Ansicht (Login vs. Haupt-App) anzuzeigen.
///   - `LoginForm`: Ruft `login()` auf, um die Anmeldedaten zu überprüfen.
///   - `CalendarBookingView`: Liest den `currentUser` für Anzeigenamen und Buchungs-IDs und ruft `getUsername(by:)` auf.
///   - `RegistrationForm` (indirekt): Die in der `RegistrationForm` erfassten Daten werden verwendet, um `register()` aufzurufen.
///



import Foundation
import Combine

/// Einfaches User-Modell
struct User: Codable, Identifiable, Equatable { // Codable, Identifiable, Equatable sind bereits vorhanden
    let id: UUID
    let username: String
    // Das Passwort sollte im echten Produkt sicher gehasht und in der Keychain gespeichert werden.
    // Für dieses Beispiel belassen wir es als String, wie in deiner Originaldatei.
    let password: String
}

/// Verantwortlich für Registrieren, Login und Speichern
final class UserStore: ObservableObject {
    @Published private(set) var users: [User] = []
    @Published var currentUser: User? = nil

    private let key = "registeredUsers"

    init() {
        load()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([User].self, from: data)
        else { return }
        users = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    /// Registriert einen neuen User. Gibt false zurück, wenn der Username schon existiert.
    func register(username: String, password: String) -> Bool {
        guard !users.contains(where: { $0.username == username }) else {
            return false
        }
        let newUser = User(id: UUID(), username: username, password: password)
        users.append(newUser)
        save()
        currentUser = newUser // Optional: Nach Registrierung direkt einloggen
        return true
    }

    /// Prüft Login-Daten: true, wenn username+passwort stimmen.
    func login(username: String, password: String) -> Bool {
        guard let u = users.first(where: { $0.username == username && $0.password == password })
        else {
            currentUser = nil // Sicherstellen, dass currentUser bei Fehlversuch nil ist
            return false
        }
        currentUser = u
        return true
    }

    /// Abmelden
    func logout() {
        currentUser = nil
        // Hier könnten weitere Aufräumarbeiten stattfinden, falls nötig
    }

    // KORRIGIERT: Funktion ist jetzt korrekt innerhalb der Klasse platziert
    /// Gibt den Benutzernamen für eine gegebene User-ID zurück.
    func getUsername(by id: UUID) -> String? {
        return users.first(where: { $0.id == id })?.username
    }
}
