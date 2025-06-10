// User.swift
import Foundation

// Das User-Modell repräsentiert nun den angemeldeten Benutzer.
// Das Passwort wird nicht mehr hier gespeichert.
struct User: Identifiable, Equatable {
    let id: String // Firebase UID ist ein String
    let email: String
}

// UserStore.swift
import Foundation
import FirebaseAuth

final class UserStore: ObservableObject {
    @Published var currentUser: User?
    @Published var authError: String?
    @Published var isLoading = false

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        // Lausche auf Änderungen des Anmeldestatus
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            
            self.isLoading = true
            defer { self.isLoading = false }

            if let firebaseUser = firebaseUser {
                self.currentUser = User(id: firebaseUser.uid, email: firebaseUser.email ?? "")
            } else {
                self.currentUser = nil
            }
        }
    }

    deinit {
        // Listener entfernen, wenn der Store zerstört wird
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func register(email: String, password: String) async {
        await MainActor.run {
            self.isLoading = true
            self.authError = nil
        }
        
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
            // Der StateDidChangeListener wird automatisch den currentUser setzen
        } catch {
            await MainActor.run {
                self.authError = error.localizedDescription
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }

    func login(email: String, password: String) async {
        await MainActor.run {
            self.isLoading = true
            self.authError = nil
        }
        
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            // Der StateDidChangeListener wird automatisch den currentUser setzen
        } catch {
            await MainActor.run {
                self.authError = error.localizedDescription
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            self.authError = error.localizedDescription
        }
    }
    
    // Diese Funktion wird nicht mehr benötigt, da die User-Infos direkt im currentUser sind.
    // Man könnte sie erweitern, um User-Profile aus Firestore zu laden.
}
