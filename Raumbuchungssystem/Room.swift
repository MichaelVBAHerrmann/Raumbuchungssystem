//
//  Room.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 02.06.25.
//

// Room.swift
import Foundation

struct Room: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var capacity: Int
}
