
import SwiftUI

struct Desk: Identifiable, Codable, Hashable {
    let id: UUID
    let position: CGPoint          // Mittelpunkt im Raum-Koordinatensystem
    var reservedBy: String?        // nil = frei
}

struct Room: Identifiable, Codable {
    let id: UUID
    let name: String
    let origin: CGPoint            // linke obere Ecke im Floor-Plan
    let size: CGSize
    var desks: [Desk]
}

struct Avatar: Identifiable {
    let id: UUID
    var name: String
    var position: CGPoint          // Floor-Plan-Koordinaten
}
