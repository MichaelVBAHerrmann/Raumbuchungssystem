// UserStore.swift
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
