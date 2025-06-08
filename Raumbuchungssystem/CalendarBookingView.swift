// CalendarBookingView.swift
import SwiftUI

struct CalendarBookingView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var roomStore: RoomStore
    @EnvironmentObject var bookingManager: BookingManager

    @State private var selectedDate = Date()
    @State private var showingConfigurationSheet = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    private var daysToDisplay: [Date] {
        (0..<7).map { Calendar.current.date(byAdding: .day, value: $0, to: selectedDate)! }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Manuell erstellter Header für eine konsistente UI
            VStack(alignment: .leading) {
                Text("Raumbuchungssystem")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack {
                    DatePicker("Datum wählen", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .frame(maxWidth: 150)

                    Button("Heute") {
                        selectedDate = Date()
                    }

                    Spacer()
                    
                    Text("Angemeldet: \(userStore.currentUser?.username ?? "Unbekannt")")
                        .padding(.trailing, 10)
                    
                    Button {
                        showingConfigurationSheet = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                        Text("Räume")
                    }
                    
                    Button("Logout") {
                        userStore.logout()
                    }
                }
            }
            .padding()

            // Hauptinhalt: Scrollbare Tagesansicht
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(daysToDisplay, id: \.self) { day in
                        DayColumnView(date: day)
                            .frame(minWidth: 250)
                            .padding(.trailing, 10)
                    }
                }
                .padding(.horizontal)
            }
            Spacer()
        }
        .sheet(isPresented: $showingConfigurationSheet) {
            RoomConfigurationView()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Hinweis"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}


// Sub-Views bleiben unverändert
struct DayColumnView: View {
    @EnvironmentObject var roomStore: RoomStore
    @EnvironmentObject var bookingManager: BookingManager
    @EnvironmentObject var userStore: UserStore

    let date: Date
    
    @State private var showingBookingAlert = false
    @State private var bookingAlertMessage = ""

    private func formatDateHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd.MM.yy"
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
                            RoomRowView(room: room, date: date)
                        }
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        .alert(isPresented: $showingBookingAlert) {
            Alert(title: Text("Buchungsinformation"), message: Text(bookingAlertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

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


            if room.capacity > 0 {
                Button {
                    guard let currentUser = userStore.currentUser else { return }
                    
                    if isCurrentUserBooked {
                        bookingManager.cancelBooking(roomID: room.id, date: date, userID: currentUser.id)
                    } else {
                        if availableSeats > 0 {
                            _ = bookingManager.bookRoom(room: room, date: date, userID: currentUser.id)
                        }
                    }
                } label: {
                    Text(isCurrentUserBooked ? "Meine Buchung stornieren" : "Buchen")
                        .frame(maxWidth: .infinity)
                }
                .disabled(availableSeats <= 0 && !isCurrentUserBooked && room.capacity > 0)
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
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
