// BookingManager.swift
import Foundation
import Combine

// MARK: - Fachliche Funktionalität
///
/// Verwaltet die gesamte Logik für Raumbuchungen. Dies umfasst das Erstellen und Stornieren
/// von Buchungen sowie das Abrufen von Informationen darüber, welche Benutzer einen bestimmten
/// Raum an einem bestimmten Datum gebucht haben. Er setzt dabei Geschäftsregeln durch, wie z.B.
/// das Verhindern von Überbuchungen (mehr Buchungen als Kapazität vorhanden).
///
// MARK: - Technische Funktionalität
///
/// Ein als `final class` deklarierter `ObservableObject`. Er speichert alle Buchungen in einem
/// Dictionary, das zur Persistenz in `UserDefaults` als JSON serialisiert wird.
/// Änderungen an den Buchungen werden über das `@Published`-Property `bookingsByDateRoom`
/// an die Beobachter (Views) weitergegeben, was zu einer Aktualisierung der UI führt.
///
// MARK: - Besonderheiten
///
/// - **Normalisierter Datumsschlüssel:** Verwendet eine benutzerdefinierte `NormalizedDateKey`-Struct,
///   um sicherzustellen, dass Buchungen immer nur dem Kalendertag (ohne Uhrzeit) zugeordnet werden.
///   Dies vereinfacht Datumsvergleiche erheblich.
/// - **Komplexe Datenstruktur:** Die Buchungen werden in einer verschachtelten Dictionary-Struktur
///   (`[NormalizedDateKey: [UUID: [UUID]?]]`) gehalten. Diese ist für schnelle Lesezugriffe
///   optimiert: Datum -> Raum-ID -> Liste von Benutzer-IDs.
/// - **Datenintegrität:** Beinhaltet Funktionen (`handleRoomDeleted`, `handleRoomCapacityChanged`),
///   um die Buchungsdaten konsistent zu halten, falls Räume gelöscht oder deren Kapazität
///   geändert wird.
///
// MARK: - Zusammenspiel und Abhängigkeiten
///
/// - **Wird initialisiert von:** `RaumbuchungssystemApp` und als `@EnvironmentObject` bereitgestellt.
/// - **Wird genutzt von:**
///   - `CalendarBookingView` (insbesondere `RoomRowView`): Ruft `bookRoom()`, `cancelBooking()` und
///     `getBookedUserIDs()` auf, um die Buchungs-Interaktionen und -Anzeigen zu steuern.
/// - **Abhängigkeiten:**
///   - `Room`: Benötigt Raum-Informationen (insb. `id` und `capacity`) aus dem `RoomStore`.
///   - `User`: Benötigt die `id` des Benutzers aus dem `UserStore` für die Zuordnung von Buchungen.
///

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
    
    // MARK: - Public API

    /// Prüft, ob für einen bestimmten Raum irgendwelche Buchungen existieren.
    /// - Parameter roomID: Die ID des zu prüfenden Raumes.
    /// - Returns: `true`, wenn mindestens eine Buchung für diesen Raum existiert, sonst `false`.
    func hasBookings(for roomID: UUID) -> Bool {
        for (_, roomBookings) in bookingsByDateRoom {
            if let userList = roomBookings[roomID], let users = userList, !users.isEmpty {
                return true
            }
        }
        return false
    }

    func getBookedUserIDs(for roomID: UUID, on date: Date) -> [UUID] {
        let key = NormalizedDateKey(date: date)
        return bookingsByDateRoom[key]?[roomID, default: nil] ?? []
    }

    func bookRoom(room: Room, date: Date, userID: UUID) -> Bool {
        guard room.capacity > 0 else { return false }
        let key = NormalizedDateKey(date: date)
        
        var bookingsForDate = bookingsByDateRoom[key, default: [:]]
        var currentUserList = (bookingsForDate[room.id] ?? nil) ?? []

        guard currentUserList.count < room.capacity else {
            return false
        }

        if !currentUserList.contains(userID) {
            currentUserList.append(userID)
            bookingsForDate[room.id] = currentUserList
            bookingsByDateRoom[key] = bookingsForDate
            saveBookings()
            return true
        }
        return false
    }

    func cancelBooking(roomID: UUID, date: Date, userID: UUID) {
        let key = NormalizedDateKey(date: date)
        
        guard var bookingsForDate = bookingsByDateRoom[key] else { return }
        
        guard let userListOptional = bookingsForDate[roomID],
              var userList = userListOptional
        else {
            return
        }

        if let index = userList.firstIndex(of: userID) {
            userList.remove(at: index)
            
            bookingsForDate[roomID] = userList.isEmpty ? nil : userList
            
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
            if var bookingsOnDate = bookingsByDateRoom[dateKey] {
                bookingsOnDate.removeValue(forKey: roomID)
                
                if bookingsOnDate.isEmpty || bookingsOnDate.allSatisfy({ $0.value == nil }) {
                    bookingsByDateRoom[dateKey] = nil
                } else {
                    bookingsByDateRoom[dateKey] = bookingsOnDate
                }
            }
        }
        saveBookings()
    }
    
    func handleRoomCapacityChanged(room: Room) {
        for dateKey in bookingsByDateRoom.keys {
            if var bookingsOnDate = bookingsByDateRoom[dateKey] {
                
                if bookingsOnDate[room.id] != nil {
                    if var currentUserIDs = bookingsOnDate[room.id] ?? nil {
                        
                        if room.capacity == 0 {
                            currentUserIDs = []
                        } else if currentUserIDs.count > room.capacity {
                            let numberToRemove = currentUserIDs.count - room.capacity
                            if numberToRemove > 0 {
                                currentUserIDs.removeLast(numberToRemove)
                            }
                        }
                        
                        bookingsOnDate[room.id] = currentUserIDs.isEmpty ? nil : currentUserIDs
                    }
                } else if room.capacity == 0 && bookingsOnDate.keys.contains(room.id) {
                     bookingsOnDate[room.id] = nil
                }

                if bookingsOnDate.isEmpty || bookingsOnDate.allSatisfy({ $0.value == nil }) {
                    bookingsByDateRoom[dateKey] = nil
                } else {
                    bookingsByDateRoom[dateKey] = bookingsOnDate
                }
            }
        }
        saveBookings()
    }

    // MARK: - Persistence
    
    private func loadBookings() {
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
}
