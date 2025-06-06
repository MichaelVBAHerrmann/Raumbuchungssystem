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


import Foundation
import Combine

final class RoomStore: ObservableObject {
    @Published private(set) var rooms: [Room] = []

    private let roomsKey = "roomDefinitions"

    init() {
        loadRooms()
    }

    func loadRooms() {
        guard let data = UserDefaults.standard.data(forKey: roomsKey),
              let decodedRooms = try? JSONDecoder().decode([Room].self, from: data)
        else {
            // Standardräume laden, falls keine gespeichert sind (optional)
            self.rooms = [
                Room(name: "Konferenzraum Alpha", capacity: 3),
                Room(name: "Meetingraum Beta", capacity: 2),
                Room(name: "Projektraum Gamma", capacity: 5)
            ]
            saveRooms()
            return
        }
        self.rooms = decodedRooms
    }

    private func saveRooms() {
        if let data = try? JSONEncoder().encode(rooms) {
            UserDefaults.standard.set(data, forKey: roomsKey)
        }
    }

    func addRoom(name: String, capacity: Int) {
        let newRoom = Room(name: name, capacity: capacity)
        rooms.append(newRoom)
        saveRooms()
    }

    func updateRoom(room: Room, newName: String, newCapacity: Int) {
        if let index = rooms.firstIndex(where: { $0.id == room.id }) {
            rooms[index].name = newName
            rooms[index].capacity = newCapacity
            saveRooms()
        }
    }

    func deleteRoom(room: Room) {
        rooms.removeAll { $0.id == room.id }
        saveRooms()
    }
    
    func deleteRoom(at offsets: IndexSet) {
        rooms.remove(atOffsets: offsets)
        saveRooms()
    }
}
