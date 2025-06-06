//
//  RoomStore.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 02.06.25.
//

// RoomStore.swift
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
