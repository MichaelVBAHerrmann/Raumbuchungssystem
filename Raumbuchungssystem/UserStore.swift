//
//  UserStore.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 29.05.25.
//

import Foundation
import Combine

/// Einfaches User-Modell
struct User: Codable, Identifiable, Equatable {
    let id: UUID
    let username: String
    let password: String   // Achtung: im echten Produkt hier besser gehasht oder in Keychain!
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
        currentUser = newUser
        return true
    }

    /// Prüft Login-Daten: true, wenn username+passwort stimmen.
    func login(username: String, password: String) -> Bool {
        guard let u = users.first(where: { $0.username == username && $0.password == password })
        else {
            return false
        }
        currentUser = u
        return true
    }

    /// Abmelden
    func logout() {
        currentUser = nil
    }
}
