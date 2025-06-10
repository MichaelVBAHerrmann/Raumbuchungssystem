//
//  RoomStore.swift
//  Raumbuchungssystem
//
// MARK: - Fachliche Funktionalität
///
/// Dient als zentraler Daten-Manager für die Definitionen aller verfügbaren Räume.
/// Er ermöglicht das Anlegen, Auslesen, Aktualisieren und Löschen von Räumen (CRUD-Operationen)
/// und stellt die Liste aller Räume der Anwendung zur Verfügung.
///
// MARK: - Technische Funktionalität
///
/// Ein als `final class` deklarierter `ObservableObject`. Er publiziert Änderungen an seiner
/// `@Published` Property (`rooms`), wodurch SwiftUI-Views, die die Raumliste anzeigen,
/// bei Änderungen automatisch aktualisiert werden. Die Raumdefinitionen werden zur Persistenz
/// mittels `JSONEncoder` in `UserDefaults` als JSON gespeichert und beim Start geladen.
///
// MARK: - Besonderheiten
///
/// - **Standard-Daten:** Falls beim ersten App-Start keine gespeicherten Räume in den `UserDefaults`
///   gefunden werden, erstellt der `RoomStore` automatisch einen Satz von Standard-Räumen.
///   Dies stellt sicher, dass die Anwendung von Anfang an benutzbare Daten enthält.
///
// MARK: - Zusammenspiel und Abhängigkeiten
///
/// - **Wird initialisiert von:** `RaumbuchungssystemApp` und als `@EnvironmentObject` bereitgestellt.
/// - **Wird genutzt von:**
///   - `CalendarBookingView`: Liest die `rooms`-Liste, um alle Räume in den Tagespalten anzuzeigen.
///   - (Zukünftig) `RoomConfigurationView`: Würde die Methoden `addRoom`, `updateRoom` und `deleteRoom`
///     aufrufen, um die Raumliste zu verwalten.
/// - **Stellt Daten bereit für:** `BookingManager`, der die `id` und `capacity` eines Raumes für die
///   Buchungslogik benötigt.
///


// Room.swift
import Foundation
import FirebaseFirestore

// Das Room-Modell wird für Firestore vorbereitet.
struct Room: Identifiable, Codable, Hashable {
    @DocumentID var id: String? // Firestore-Dokumenten-ID
    var name: String
    var capacity: Int
}

// RoomStore.swift
import Foundation
import FirebaseFirestore

@MainActor
final class RoomStore: ObservableObject {
    @Published private(set) var rooms: [Room] = []
    private let db = Firestore.firestore()

    init() {
        fetchRooms()
    }

    func fetchRooms() {
        db.collection("rooms").order(by: "name").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "unknown error")")
                return
            }

            self.rooms = documents.compactMap { document in
                try? document.data(as: Room.self)
            }
        }
    }

    func addRoom(name: String, capacity: Int) {
        let newRoom = Room(name: name, capacity: capacity)
        do {
            _ = try db.collection("rooms").addDocument(from: newRoom)
        } catch {
            print("Error adding room: \(error.localizedDescription)")
        }
    }

    func updateRoom(_ room: Room) {
        guard let roomId = room.id else { return }
        do {
            try db.collection("rooms").document(roomId).setData(from: room)
        } catch {
            print("Error updating room: \(error.localizedDescription)")
        }
    }

    func deleteRoom(_ room: Room) {
        guard let roomId = room.id else { return }
        db.collection("rooms").document(roomId).delete { error in
            if let error = error {
                print("Error deleting room: \(error.localizedDescription)")
            }
        }
    }
}
