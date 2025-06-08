// RoomConfigurationView.swift
import SwiftUI

struct RoomConfigurationView: View {
    @EnvironmentObject var roomStore: RoomStore
    @EnvironmentObject var bookingManager: BookingManager
    @Environment(\.dismiss) var dismiss

    // State für das Formular
    @State private var name: String = ""
    @State private var capacityString: String = ""
    @State private var editingRoom: Room? = nil

    // State für den Lösch-Dialog
    @State private var showingDeleteAlert = false
    @State private var roomToDelete: Room? = nil

    var body: some View {
        // Die Wurzel der Ansicht ist ein einfacher VStack, um fehlerhafte
        // Navigation-Container zu vermeiden.
        VStack(spacing: 0) {
            
            // Manuell erstellter Header mit Titel und Schließen-Button
            HStack {
                Text("Räume konfigurieren")
                    .font(.title) // Etwas kleiner für eine bessere Passform
                    .fontWeight(.bold)
                Spacer()
                Button("Schließen") {
                    dismiss()
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor)) // Hintergrund für den Header

            Divider()

            // Formular zum Anlegen und Bearbeiten von Räumen
            Form {
                Section(header: Text(editingRoom == nil ? "Neuen Raum hinzufügen" : "Raum bearbeiten")) {
                    TextField("Raumname", text: $name)
                    
                    TextField("Kapazität", text: $capacityString)
                        .onChange(of: capacityString) { _, newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.capacityString = filtered
                            }
                        }
                    
                    HStack {
                        Button(action: {
                            // Explizite Closure, um Compiler-Probleme zu vermeiden
                            self.saveRoom()
                        }) {
                            Text(editingRoom == nil ? "Hinzufügen" : "Speichern")
                        }
                        .disabled(name.isEmpty || capacityString.isEmpty)

                        if editingRoom != nil {
                            Button("Abbrechen") {
                                self.resetForm()
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding([.horizontal, .top])
            .frame(height: 150) // Feste Höhe für das Formular
            
            Divider()

            // Liste der existierenden Räume
            List {
                ForEach(roomStore.rooms) { room in
                    roomRow(for: room)
                }
            }
            .listStyle(.inset(alternatesRowBackgrounds: true))
            
        }
        .frame(minWidth: 500, idealWidth: 600, minHeight: 500, idealHeight: 700)
        .alert(isPresented: $showingDeleteAlert) {
            deleteConfirmationAlert
        }
    }

    private func roomRow(for room: Room) -> some View {
        HStack {
            Text("\(room.name) (Kapazität: \(room.capacity))")
            Spacer()
            Button("Bearbeiten") {
                self.startEditing(room)
            }
            .buttonStyle(.borderless)
            
            Button {
                self.roomToDelete = room
                self.showingDeleteAlert = true
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
            .foregroundColor(.red)
        }
        .padding(.vertical, 4)
    }
    
    private var deleteConfirmationAlert: Alert {
        guard let room = roomToDelete else { return Alert(title: Text("Fehler")) }
        let hasBookings = bookingManager.hasBookings(for: room.id)
        let title = Text("Raum \"\(room.name)\" löschen?")
        var message = Text("Möchten Sie diesen Raum wirklich endgültig löschen?")
        
        if hasBookings {
            message = Text("Achtung: Für diesen Raum existieren bereits Buchungen! Diese gehen ebenfalls verloren. Fortfahren?")
        }

        return Alert(title: title, message: message,
            primaryButton: .destructive(Text("Löschen")) {
                self.deleteRoom(room)
            },
            secondaryButton: .cancel()
        )
    }

    // MARK: - Helper Functions

    private func saveRoom() {
        guard let capacity = Int(capacityString), capacity >= 0 else { return }
        if let editingRoom = editingRoom {
            var updatedRoom = editingRoom
            updatedRoom.name = name
            updatedRoom.capacity = capacity
            roomStore.updateRoom(room: editingRoom, newName: name, newCapacity: capacity)
            bookingManager.handleRoomCapacityChanged(room: updatedRoom)
        } else {
            roomStore.addRoom(name: name, capacity: capacity)
        }
        resetForm()
    }

    private func startEditing(_ room: Room) {
        self.editingRoom = room
        self.name = room.name
        self.capacityString = "\(room.capacity)"
    }

    private func deleteRoom(_ room: Room) {
        roomStore.deleteRoom(room: room)
        bookingManager.handleRoomDeleted(roomID: room.id)
        resetForm()
    }

    private func resetForm() {
        self.name = ""
        self.capacityString = ""
        self.editingRoom = nil
    }
}
