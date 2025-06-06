//
//  Room.swift
//  Raumbuchungssystem
//
// MARK: - Fachliche Funktionalität
///
/// Repräsentiert das Datenmodell für einen einzelnen buchbaren Raum.
/// Es enthält alle grundlegenden Eigenschaften eines Raumes, wie seinen Namen
/// und die maximale Anzahl an Personen, die ihn nutzen können (Kapazität).
///
// MARK: - Technische Funktionalität
///
/// Eine einfache `struct`, die als reiner Datencontainer dient.
/// Sie konformiert zu mehreren wichtigen Protokollen:
/// - `Identifiable`: Erforderlich, um Instanzen in SwiftUI-Listen (z.B. `ForEach`) eindeutig
///   identifizieren zu können. Jedes `Room`-Objekt erhält eine einzigartige `id`.
/// - `Codable`: Ermöglicht die einfache Umwandlung von und zu JSON, was für die Persistenz
///   der Daten in `UserDefaults` durch den `RoomStore` genutzt wird.
/// - `Hashable`: Erlaubt die Verwendung von `Room`-Objekten als Schlüssel in Dictionaries oder
///   Elemente in Sets, falls erforderlich.
///
// MARK: - Besonderheiten
///
/// Dieses Modul enthält bewusst keinerlei Geschäftslogik. Es ist ein reines Datenmodell
/// (Plain Old Data Object), was die Trennung von Daten und Logik im System unterstützt.
///
// MARK: - Zusammenspiel und Abhängigkeiten
///
/// - **Wird erstellt/verwaltet von:** `RoomStore`.
/// - **Wird genutzt von:**
///   - `CalendarBookingView`: Zur Anzeige der Raumdetails.
///   - `BookingManager`: Nutzt die `id` zur Identifikation und die `capacity` zur Prüfung von Buchungsregeln.
///

// Room.swift
import Foundation

struct Room: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var capacity: Int
}
