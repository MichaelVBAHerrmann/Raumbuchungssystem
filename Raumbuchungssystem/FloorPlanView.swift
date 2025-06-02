
import SwiftUI

// Helper to add two CGPoints
fileprivate extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

struct FloorPlanView: View {
    @EnvironmentObject var userStore: UserStore       // ggf. für spätere Rechte
    @State private var avatar = Avatar(id: UUID(),
                                       name: "Ich",
                                       position: .zero)
    @State private var rooms: [Room] = DemoFloor.initialRooms
    @State private var selectedDesk: Desk? = nil

    // MARK: - Sub‑Views to help type‑checker
    @ViewBuilder
    private var floorLayer: some View {
        ForEach(rooms, id: \.id) { room in
            RoomLayer(room: room) { desk in
                avatar.position = desk.position + room.origin
                selectedDesk = desk
            }
        }
    }

    @ViewBuilder
    private var avatarLayer: some View {
        AvatarView()
            .position(avatar.position)
    }

    @ViewBuilder
    private var reserveButtonLayer: some View {
        if let desk = selectedDesk,
           desk.reservedBy == nil {
            VStack {
                Spacer()
                Button("Platz reservieren") {
                    reserve(deskID: desk.id)
                }
                .padding()
                .background(Color.gray.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 4, y: 3)
            }
            .padding()
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                floorLayer
                avatarLayer
                reserveButtonLayer
            }
            .onAppear {
                avatar.position = CGPoint(x: geo.size.width / 2, y: 40)
            }
        }
    }

    // MARK: - Reservierung
    private func reserve(deskID: UUID) {
        for r in rooms.indices {
            if let d = rooms[r].desks.firstIndex(where: { $0.id == deskID }) {
                rooms[r].desks[d].reservedBy = avatar.name
                selectedDesk = nil
            }
        }
    }
}

// MARK: - RoomLayer (reduces compiler complexity)
private struct RoomLayer: View {
    let room: Room
    let onDeskSelect: (Desk) -> Void

    var body: some View {
        ZStack {
            RoomShape(room: room)
                .stroke(Color.brown, lineWidth: 3)

            ForEach(room.desks) { desk in
                DeskCellView(desk: desk)
                    .position(desk.position + room.origin)
                    .onTapGesture { onDeskSelect(desk) }
            }
        }
    }
}

// MARK: - Einzel-Views
struct DeskCellView: View {
    var desk: Desk
    var body: some View {
        VStack(spacing: 4) {
            Rectangle().fill(Color.gray.opacity(0.6))
                .frame(width: 38, height: 8)    // Monitor
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.brown)
                .frame(width: 50, height: 26)   // Tisch
        }
        .overlay(
            // Avatar falls belegt
            Group {
                if let name = desk.reservedBy {
                    VStack(spacing: 2){
                        AvatarView(scale: 0.5)
                        Text(name)
                            .font(.caption2)
                            .foregroundColor(.black)
                    }
                }
            }
        )
    }
}

struct RoomShape: Shape {
    var room: Room
    func path(in rect: CGRect) -> Path {
        Path(roundedRect:
                CGRect(origin: room.origin, size: room.size),
             cornerRadius: 6)
    }
}

struct AvatarView: View {
    var scale: CGFloat = 1
    var body: some View {
        VStack(spacing: 2){
            Circle().fill(Color.black)
                .frame(width: 10*scale, height: 10*scale)
            RoundedRectangle(cornerRadius: scale)
                .fill(Color.black)
                .frame(width: 4*scale, height: 14*scale)
        }
    }
}

// MARK: - Demo-Floor
enum DemoFloor {
    static let initialRooms: [Room] = {
        let template: [Desk] = (0..<3).map { i in
            Desk(id: UUID(),
                 position: CGPoint(x: 60, y: 50 + CGFloat(i)*80),
                 reservedBy: nil)
        }
        return [
            Room(id: UUID(), name: "Raum A",
                 origin: CGPoint(x: 40, y: 40),
                 size: CGSize(width: 140, height: 260),
                 desks: template),
            Room(id: UUID(), name: "Raum B",
                 origin: CGPoint(x: 220, y: 40),
                 size: CGSize(width: 140, height: 260),
                 desks: template)
        ]
    }()
}
