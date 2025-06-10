

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

// Booking.swift
import Foundation
import FirebaseFirestore

struct Booking: Identifiable, Codable {
    @DocumentID var id: String?
    var roomId: String
    var userId: String
    var userEmail: String // Nützlich für die Anzeige
    var date: Timestamp // Firestore-Datumsformat
}

// BookingManager.swift
import Foundation
import FirebaseFirestore

@MainActor
final class BookingManager: ObservableObject {
    @Published private(set) var bookings: [Booking] = []
    private let db = Firestore.firestore()

    init() {
        // Man könnte hier alle Buchungen laden, aber es ist effizienter,
        // sie nur bei Bedarf für das ausgewählte Datum zu laden.
    }

    // Lädt Buchungen für einen bestimmten Datumsbereich
    func fetchBookings(for dates: [Date]) {
        guard !dates.isEmpty else {
            self.bookings = []
            return
        }
        
        let calendar = Calendar.current
        let startOfFirstDay = calendar.startOfDay(for: dates.first!)
        let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: dates.last!)!
        let endOfLastDay = calendar.startOfDay(for: startOfNextDay)

        db.collection("bookings")
            .whereField("date", isGreaterThanOrEqualTo: startOfFirstDay)
            .whereField("date", isLessThan: endOfLastDay)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching bookings: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                
                self.bookings = documents.compactMap { try? $0.data(as: Booking.self) }
            }
    }

    func getBookings(for roomId: String, on date: Date) -> [Booking] {
        let calendar = Calendar.current
        return bookings.filter { booking in
            return booking.roomId == roomId && calendar.isDate(booking.date.dateValue(), inSameDayAs: date)
        }
    }

    func bookRoom(room: Room, date: Date, user: User) async {
        guard let roomId = room.id else { return }
        
        let newBooking = Booking(
            roomId: roomId,
            userId: user.id,
            userEmail: user.email,
            date: Timestamp(date: date)
        )
        
        do {
            _ = try await db.collection("bookings").addDocument(from: newBooking)
        } catch {
            print("Error creating booking: \(error.localizedDescription)")
        }
    }

    func cancelBooking(for bookingId: String) async {
        do {
            try await db.collection("bookings").document(bookingId).delete()
        } catch {
            print("Error cancelling booking: \(error.localizedDescription)")
        }
    }
}
