//
//  MainView.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 02.06.25.
//

// MainView.swift
import SwiftUI

struct MainView: View {
    @EnvironmentObject var userStore: UserStore

    var body: some View {
        if userStore.currentUser == nil {
            StartView() // Deine bestehende StartView für Login/Registrierung
        } else {
            CalendarBookingView() // Die neue Hauptansicht für die Raumbuchung
        }
    }
}
