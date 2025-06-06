//
//  RaumbuchungssystemApp.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 26.05.25.
//

import SwiftUI
/*
@main
struct RaumBuchungssystemApp: App {
    @StateObject private var userStore = UserStore()

    var body: some Scene {
        WindowGroup {
            StartView()
                .environmentObject(userStore)
        }
    }
}

*/

@main
struct RaumBuchungssystemApp: App {
    @StateObject private var userStore = UserStore()
    @StateObject private var roomStore = RoomStore() // Neu
    @StateObject private var bookingManager = BookingManager() // Neu

    var body: some Scene {
        WindowGroup {
            MainView() // Wir erstellen eine neue MainView
                .environmentObject(userStore)
                .environmentObject(roomStore) // Neu
                .environmentObject(bookingManager) // Neu
        }
    }
}
