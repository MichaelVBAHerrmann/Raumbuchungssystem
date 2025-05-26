//
//  RaumbuchungssystemApp.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 26.05.25.
//

import SwiftUI

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
