// BookingManager.swift
import Foundation
import Combine

// NormalizedDateKey struct bleibt unverändert...
struct NormalizedDateKey: Codable, Hashable, Comparable {
    let year: Int
    let month: Int
    let day: Int

    init(date: Date) {
        let calendar = Calendar.current
        self.year = calendar.component(.year, from: date)
        self.month = calendar.component(.month, from: date)
        self.day = calendar.component(.day, from: date)
    }

    static func < (lhs: NormalizedDateKey, rhs: NormalizedDateKey) -> Bool {
        if lhs.year != rhs.year { return lhs.year < rhs.year }
        if lhs.month != rhs.month { return lhs.month < rhs.month }
        return lhs.day < rhs.day
    }
}

final class BookingManager: ObservableObject {
    @Published private(set) var bookingsByDateRoom: [NormalizedDateKey: [UUID: [UUID]?]] = [:]
    private let bookingsKey = "roomBookings"

    init() {
        loadBookings()
    }

    func loadBookings() {
        guard let data = UserDefaults.standard.data(forKey: bookingsKey),
              let decodedBookings = try? JSONDecoder().decode([NormalizedDateKey: [UUID: [UUID]?]].self, from: data)
        else {
            self.bookingsByDateRoom = [:]
            return
        }
        self.bookingsByDateRoom = decodedBookings
    }

    private func saveBookings() {
        if let data = try? JSONEncoder().encode(bookingsByDateRoom) {
            UserDefaults.standard.set(data, forKey: bookingsKey)
        }
    }

    func getBookedUserIDs(for roomID: UUID, on date: Date) -> [UUID] {
        let key = NormalizedDateKey(date: date)
        // bookingsByDateRoom[key] ist [UUID: [UUID]?]?
        // bookingsByDateRoom[key]?[roomID] ist [UUID]?? (Optional(Optional([UUID])))
        // default: nil im Subscript des Dictionaries gibt [UUID]? zurück, wenn der Raum-Key existiert.
        // Das äußere ?? [] behandelt den Fall, dass der `dateKey` nicht existiert.
        return bookingsByDateRoom[key]?[roomID, default: nil] ?? []
    }

    func bookRoom(room: Room, date: Date, userID: UUID) -> Bool {
        guard room.capacity > 0 else { return false }
        let key = NormalizedDateKey(date: date)
        
        // Hole oder erstelle das Dictionary für das Datum
        var bookingsForDate = bookingsByDateRoom[key, default: [:]] // bookingsForDate ist [UUID: [UUID]?]
        
        // Hole die aktuelle Liste der User-IDs für den Raum, oder eine leere Liste
        // bookingsForDate[room.id] ist [UUID]??
        // (bookingsForDate[room.id] ?? nil) entpackt eine Ebene zu [UUID]?
        // (... ?? []) entpackt die zweite Ebene zu [UUID]
        var currentUserList = (bookingsForDate[room.id] ?? nil) ?? [] // currentUserList ist jetzt [UUID]

        guard currentUserList.count < room.capacity else {
            return false // Raum ist voll
        }

        if !currentUserList.contains(userID) { // Operationen auf [UUID]
            currentUserList.append(userID) // Operationen auf [UUID]
            bookingsForDate[room.id] = currentUserList // [UUID] wird in den [UUID]?-Slot gespeichert (implizite Konvertierung)
            bookingsByDateRoom[key] = bookingsForDate
            saveBookings()
            return true
        }
        return false // User hat diesen Raum bereits gebucht
    }

    func cancelBooking(roomID: UUID, date: Date, userID: UUID) {
        let key = NormalizedDateKey(date: date)
        
        // 1. Stelle sicher, dass es ein Buchungs-Dictionary für dieses Datum gibt
        guard var bookingsForDate = bookingsByDateRoom[key] else { return }
        
        // 2. KORRIGIERT: Entpacke die Liste der User-IDs sicher.
        //    bookingsForDate[roomID] gibt [UUID]?? zurück (doppelt optional).
        //    Die 'guard'-Anweisung entpackt beide optionalen Ebenen.
        //    'userList' ist danach garantiert ein non-optional [UUID].
        guard let userListOptional = bookingsForDate[roomID], // Entpackt zu [UUID]?
              var userList = userListOptional               // Entpackt zu [UUID]
        else {
            // Dieser Block wird erreicht, wenn für den Raum an diesem Tag keine Buchungen existieren.
            return
        }

        // Ab hier ist 'userList' ein non-optionales, veränderbares Array vom Typ [UUID].
        // Die folgenden Operationen sind jetzt gültig:

        if let index = userList.firstIndex(of: userID) { // FEHLER 1 BEHOBEN: .firstIndex kann auf [UUID] aufgerufen werden.
            userList.remove(at: index) // FEHLER 2 BEHOBEN: .remove kann auf [UUID] aufgerufen werden.
            
            // Aktualisiere den Eintrag im Dictionary:
            // Setze den Wert auf 'nil', wenn die Liste jetzt leer ist, ansonsten auf die aktualisierte Liste.
            bookingsForDate[roomID] = userList.isEmpty ? nil : userList // FEHLER 3 BEHOBEN: .isEmpty kann auf [UUID] aufgerufen werden.
            
            // Wenn für dieses Datum keine Raumbuchungen mehr existieren, entferne den gesamten Datumseintrag
            if bookingsForDate.allSatisfy({ $0.value == nil }) {
                bookingsByDateRoom[key] = nil
            } else {
                bookingsByDateRoom[key] = bookingsForDate
            }
            saveBookings()
        }
    }

    func handleRoomDeleted(roomID: UUID) {
        for dateKey in bookingsByDateRoom.keys {
            // Hole eine kopie des Dictionaries für das Datum, falls es existiert
            if var bookingsOnDate = bookingsByDateRoom[dateKey] { // bookingsOnDate ist [UUID: [UUID]?]
                bookingsOnDate.removeValue(forKey: roomID) // Entferne den Raum aus der Kopie
                
                // Wenn das Dictionary für das Datum jetzt leer ist oder nur nil-Werte enthält
                if bookingsOnDate.isEmpty || bookingsOnDate.allSatisfy({ $0.value == nil }) {
                    bookingsByDateRoom[dateKey] = nil // Entferne den gesamten Datumseintrag
                } else {
                    bookingsByDateRoom[dateKey] = bookingsOnDate // Speichere das modifizierte Dictionary zurück
                }
            }
        }
        saveBookings()
    }
    
    func handleRoomCapacityChanged(room: Room) {
        for dateKey in bookingsByDateRoom.keys {
            // Hole eine Kopie des Dictionaries für das Datum, falls es existiert
            if var bookingsOnDate = bookingsByDateRoom[dateKey] { // bookingsOnDate ist [UUID: [UUID]?]
                
                // Prüfe, ob für diesen Raum überhaupt ein Eintrag (auch wenn nil) existiert
                if bookingsOnDate[room.id] != nil { // Zugriff auf [UUID]??, != nil prüft die erste Optionalebene
                    // Hole die aktuelle User-Liste für den Raum, falls vorhanden
                    if var currentUserIDs = bookingsOnDate[room.id] /* entpackt zu [UUID]? */ ?? nil /* stellt sicher, dass wir [UUID] haben, wenn nicht nil */ {
                        
                        if room.capacity == 0 { // Wenn Kapazität 0 ist, alle Buchungen für diesen Raum entfernen
                            currentUserIDs = []
                        } else if currentUserIDs.count > room.capacity {
                            let numberToRemove = currentUserIDs.count - room.capacity
                            if numberToRemove > 0 { // Sicherstellen, dass numberToRemove positiv ist
                                currentUserIDs.removeLast(numberToRemove)
                            }
                        }
                        
                        // Speichere die modifizierte Liste (oder nil, wenn leer)
                        bookingsOnDate[room.id] = currentUserIDs.isEmpty ? nil : currentUserIDs
                    }
                } else if room.capacity == 0 && bookingsOnDate.keys.contains(room.id) {
                    // Fall: Raum hatte vorher keine Buchungen (Value war nil), wird jetzt auf Kapazität 0 gesetzt.
                    // Sicherstellen, dass der Eintrag nil ist.
                     bookingsOnDate[room.id] = nil
                }


                // Wenn das Dictionary für das Datum jetzt leer ist oder nur nil-Werte enthält
                if bookingsOnDate.isEmpty || bookingsOnDate.allSatisfy({ $0.value == nil }) {
                    bookingsByDateRoom[dateKey] = nil
                } else {
                    bookingsByDateRoom[dateKey] = bookingsOnDate
                }
            }
        }
        saveBookings()
    }
}
