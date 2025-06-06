//
//  CalendarBookingView.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 02.06.25.
//

// CalendarBookingView.swift
import SwiftUI

struct CalendarBookingView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var roomStore: RoomStore
    @EnvironmentObject var bookingManager: BookingManager

    @State private var selectedDate = Date() // Für den DatePicker
    @State private var showingConfigurationSheet = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Generiert die Tage für die Anzeige
    private var daysToDisplay: [Date] {
        (0..<7).map { Calendar.current.date(byAdding: .day, value: $0, to: selectedDate)! }
    }

    var body: some View {
        NavigationView { // Sinnvoll für macOS, um einen Titel und Toolbar-Items zu haben
            VStack(alignment: .leading) {
                // Header: Datumsauswahl und Konfigurationsbutton
                HStack {
                    DatePicker("Datum wählen", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden() // Nur den Picker anzeigen
                        .datePickerStyle(.compact) // Kompakter Stil für macOS
                        .frame(maxWidth: 150)


                    Button {
                        // Hier könnte Logik stehen, um die Ansicht basierend auf selectedDate zu aktualisieren,
                        // aber renderCalendar() in der Schleife unten tut dies bereits implizit.
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .padding(.leading, -8) // Etwas näher an den DatePicker

                    Spacer()
                    Text("Angemeldet: \(userStore.currentUser?.username ?? "Unbekannt")")
                    Button {
                        showingConfigurationSheet = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                        Text("Räume")
                    }
                }
                .padding()

                // Hauptinhalt: Scrollbare Tagesansicht
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(daysToDisplay, id: \.self) { day in
                            DayColumnView(date: day) // Wir erstellen diese Hilfs-View gleich
                                .frame(minWidth: 250) // Mindestbreite pro Tag
                                .padding(.trailing, 10) // Abstand zwischen den Tagespalten
                        }
                    }
                    .padding(.horizontal) // Innenabstand für die ScrollView
                }
                Spacer() // Füllt den restlichen vertikalen Platz
            }
            .navigationTitle("Raumbuchungssystem")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Logout") {
                        userStore.logout()
                    }
                }
            }
            .sheet(isPresented: $showingConfigurationSheet) {
                // Hier kommt die RoomConfigurationView rein
                Text("Raumkonfiguration (Platzhalter)")
                // RoomConfigurationView().environmentObject(roomStore)...
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Hinweis"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .frame(minWidth: 800, minHeight: 600) // Eine Mindestgröße für das Fenster
    }
}

// Hilfs-View für eine einzelne Tagespalte
struct DayColumnView: View {
    @EnvironmentObject var roomStore: RoomStore
    @EnvironmentObject var bookingManager: BookingManager
    @EnvironmentObject var userStore: UserStore // Für den aktuellen User beim Buchen

    let date: Date
    
    @State private var showingBookingAlert = false
    @State private var bookingAlertMessage = ""

    private func formatDateHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd.MM.yy" // z.B. Mo, 02.06.25
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(formatDateHeader(date))
                .font(.headline)
                .padding(.bottom, 5)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    if roomStore.rooms.isEmpty {
                        Text("Keine Räume definiert.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(roomStore.rooms) { room in
                            RoomRowView(room: room, date: date) // Wir erstellen diese auch gleich
                        }
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)) // Oben/Unten Padding für die Spalte
        .alert(isPresented: $showingBookingAlert) {
            Alert(title: Text("Buchungsinformation"), message: Text(bookingAlertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

// Hilfs-View für eine einzelne Raumzeile
struct RoomRowView: View {
    @EnvironmentObject var bookingManager: BookingManager
    @EnvironmentObject var userStore: UserStore

    let room: Room
    let date: Date
    
    @State private var showBookedUsersPopover = false

    private var bookedUserIDs: [UUID] {
        bookingManager.getBookedUserIDs(for: room.id, on: date)
    }
    
    private var bookedUsernames: [String] {
        bookedUserIDs.compactMap { userStore.getUsername(by: $0) }
    }

    private var availableSeats: Int {
        room.capacity - bookedUserIDs.count
    }
    
    private var isCurrentUserBooked: Bool {
        if let currentUserID = userStore.currentUser?.id {
            return bookedUserIDs.contains(currentUserID)
        }
        return false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(room.name).font(.title3)
            
            HStack {
                Text("Kapazität: \(room.capacity)")
                Spacer()
                Text("Frei: \(availableSeats < 0 ? 0 : availableSeats)")
                    .foregroundColor(availableSeats <= 0 && room.capacity > 0 ? .red : (availableSeats < room.capacity / 2 ? .orange : .green))
            }
            .font(.caption)

            if !bookedUsernames.isEmpty {
                Button(action: { showBookedUsersPopover = true }) {
                    Text("Gebucht von: \(bookedUsernames.prefix(2).joined(separator: ", "))\(bookedUsernames.count > 2 ? ", ..." : "")")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showBookedUsersPopover, arrowEdge: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Gebuchte Personen:").font(.headline)
                        ForEach(bookedUsernames, id: \.self) { name in
                            Text("• \(name)")
                        }
                    }
                    .padding()
                }
            } else {
                 Text("Noch keine Buchungen")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }


            if room.capacity > 0 { // Buchungsbutton nur anzeigen, wenn Kapazität > 0
                Button {
                    guard let currentUser = userStore.currentUser else { return }
                    
                    if isCurrentUserBooked {
                        // Stornieren
                        bookingManager.cancelBooking(roomID: room.id, date: date, userID: currentUser.id)
                        // Hier könnte Feedback für erfolgreiche Stornierung stehen
                    } else {
                        // Buchen
                        if availableSeats > 0 {
                            let success = bookingManager.bookRoom(room: room, date: date, userID: currentUser.id)
                            if !success {
                                // Zeige Alert, wenn Raum voll oder anderer Fehler
                                // bookingAlertMessage = "Raum konnte nicht gebucht werden (möglicherweise voll)."
                                // showingBookingAlert = true // Dies würde im DayColumnView Alert zeigen
                            }
                        } else {
                            // Zeige Alert, Raum ist voll
                            // bookingAlertMessage = "Dieser Raum ist bereits voll belegt."
                            // showingBookingAlert = true
                        }
                    }
                } label: {
                    Text(isCurrentUserBooked ? "Meine Buchung stornieren" : "Buchen")
                        .frame(maxWidth: .infinity)
                }
                .disabled(availableSeats <= 0 && !isCurrentUserBooked && room.capacity > 0) // Deaktivieren, wenn voll und nicht selbst gebucht
                .padding(.top, 4)
            } else {
                Text("Raum gesperrt")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5)) // Leichter Hintergrund für jede Raumkarte
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct CalendarBookingView_Previews: PreviewProvider {
    static var previews: some View {
        // Erstelle Dummy-Stores für die Preview
        let userStore = UserStore()
        let roomStore = RoomStore()
        let bookingManager = BookingManager()
        
        // Füge einen Testuser hinzu und setze ihn als currentUser
        _ = userStore.register(username: "TestUser", password: "password")
        userStore.login(username: "TestUser", password: "password")


        return MainView() // Zeige MainView, die dann CalendarBookingView oder StartView rendert
            .environmentObject(userStore)
            .environmentObject(roomStore)
            .environmentObject(bookingManager)
            .frame(width: 900, height: 700)
    }
}
