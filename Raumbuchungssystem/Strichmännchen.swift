//
//  Strichmännchen.swift
//  Raumbuchungssystem
//
//  Created by Michael Herrmann on 29.05.25.
//

import SwiftUI

// MARK: - Main View
struct Strichmännchen: View {
    @State private var animationStep = 0
    // Timer to control the animation sequence
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Background Color
            Color(red: 0.1, green: 0.1, blue: 0.2).ignoresSafeArea()

            // Desk
            DeskView()
                .offset(y: 100) // Adjust position as needed

            // Laptop
            LaptopView(isOpen: animationStep >= 3, isLoggedIn: animationStep >= 5)
                .offset(y: 30) // Adjust position relative to the desk

            // Stick Figure
            StickFigureView(step: animationStep)
                .offset(x: animationStep == 0 ? -200 : (animationStep >= 1 ? -50 : -200), y: 80) // Initial position and walking to desk
                .animation(.easeInOut(duration: 1.5), value: animationStep)


            // Text for debugging or showing steps (optional)
            VStack {
                Spacer()
                Text("Animation Step: \(animationStep)")
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .onReceive(timer) { _ in
            if animationStep < 6 {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animationStep += 1
                }
            } else {
                timer.upstream.connect().cancel() // Stop timer after animation completes
            }
        }
        .frame(minWidth: 400, minHeight: 400) // Set a minimum size for the window
    }
}

// MARK: - Stick Figure View
struct StickFigureView: View {
    let step: Int // Current animation step

    // Stick figure properties based on step
    var isWalking: Bool { step == 0 }
    var isSitting: Bool { step >= 1 && step < 6 }
    var isTyping: Bool { step == 4 }
    var isSmiling: Bool { step >= 5 }
    var armAngle: Double { isTyping ? -30 : (isSitting ? -10 : 0) }
    var legOffset: CGFloat { isWalking ? 5 : 0 } // Simple walk cycle

    var body: some View {
        ZStack {
            // Body
            Capsule()
                .frame(width: 10, height: 50)
                .offset(y: isSitting ? 15 : 0) // Adjust for sitting

            // Head
            Circle()
                .frame(width: 30, height: 30)
                .offset(y: isSitting ? -20 : -35)

            // Arms
            // Left Arm
            RoundedRectangle(cornerRadius: 5)
                .frame(width: 8, height: 35)
                .rotationEffect(.degrees(armAngle + 180), anchor: .top)
                .offset(x: -10, y: isSitting ? -5 : -10)
            // Right Arm
            RoundedRectangle(cornerRadius: 5)
                .frame(width: 8, height: 35)
                .rotationEffect(.degrees(-armAngle), anchor: .top)
                .offset(x: 10, y: isSitting ? -5 : -10)


            // Legs (simplified for sitting)
            if !isSitting {
                // Left Leg
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 8, height: 40)
                    .offset(x: -5 + legOffset, y: 45)
                // Right Leg
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 8, height: 40)
                    .offset(x: 5 - legOffset, y: 45)
            } else {
                 // Legs when sitting
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 8, height: 30)
                    .rotationEffect(.degrees(90), anchor: .top)
                    .offset(x: -10, y: 30)
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 8, height: 30)
                    .rotationEffect(.degrees(90), anchor: .top)
                    .offset(x: 10, y: 30)
                 RoundedRectangle(cornerRadius: 5) // Lower leg part
                    .frame(width: 8, height: 25)
                    .offset(x: -23, y: 48)
                 RoundedRectangle(cornerRadius: 5) // Lower leg part
                    .frame(width: 8, height: 25)
                    .offset(x: 23, y: 48)
            }


            // Face features
            if isSmiling {
                // Smile
                Path { path in
                    path.move(to: CGPoint(x: -7, y: isSitting ? -18 : -33))
                    path.addQuadCurve(to: CGPoint(x: 7, y: isSitting ? -18 : -33), control: CGPoint(x: 0, y: isSitting ? -12 : -27))
                }
                .stroke(lineWidth: 1.5)
            } else {
                // Neutral mouth
                 Path { path in
                    path.move(to: CGPoint(x: -5, y: isSitting ? -15 : -30))
                    path.addLine(to: CGPoint(x: 5, y: isSitting ? -15 : -30))
                }
                .stroke(lineWidth: 1.5)
            }
            // Eyes
            Circle().frame(width: 3, height: 3).offset(x: -5, y: isSitting ? -22 : -38)
            Circle().frame(width: 3, height: 3).offset(x: 5, y: isSitting ? -22 : -38)

        }
        .foregroundColor(.white) // Stick figure color
    }
}

// MARK: - Desk View
struct DeskView: View {
    var body: some View {
        ZStack {
            // Tabletop
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(red: 0.4, green: 0.3, blue: 0.2)) // Brown color
                .frame(width: 200, height: 15)
            // Legs
            Rectangle()
                .fill(Color(red: 0.35, green: 0.25, blue: 0.15))
                .frame(width: 10, height: 80)
                .offset(x: -80, y: 47.5)
            Rectangle()
                .fill(Color(red: 0.35, green: 0.25, blue: 0.15))
                .frame(width: 10, height: 80)
                .offset(x: 80, y: 47.5)
        }
    }
}

// MARK: - Laptop View
struct LaptopView: View {
    let isOpen: Bool
    let isLoggedIn: Bool

    var body: some View {
        ZStack {
            // Laptop Base
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.8))
                .frame(width: 80, height: 5)
                .offset(y: 25) // Base slightly lower

            // Laptop Screen
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.9))
                    .frame(width: 80, height: 60)

                // Screen Content
                if isLoggedIn {
                    // "Logged In" - e.g., green screen with a checkmark or smiley
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.green.opacity(0.7))
                        .frame(width: 70, height: 50)
                    Image(systemName: "checkmark.circle.fill") // Or a custom "logged in" graphic
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                } else if isOpen {
                     // "Login Screen" - e.g., blueish screen
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.blue.opacity(0.5))
                        .frame(width: 70, height: 50)
                    Text("Login...")
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                } else {
                    // Closed screen - dark
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.black.opacity(0.8))
                        .frame(width: 70, height: 50)
                }
            }
            .frame(width: 80, height: 60)
            .rotation3DEffect(
                .degrees(isOpen ? 0 : 90),
                axis: (x: 1, y: 0, z: 0),
                anchor: .bottom // Pivot from the bottom edge of the screen
            )
            .offset(y: -7.5) // Position screen relative to base hinge
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isOpen)

        }
        .shadow(radius: isOpen ? 5 : 0)
    }
}


// MARK: - App Entry Point
// In your main App struct (e.g., YourAppNameApp.swift)
/*
@main
struct YourMacAppNameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Remove the default window title bar for a cleaner background look (optional)
        // .windowStyle(HiddenTitleBarWindowStyle())
    }
}
*/

// MARK: - Preview
#Preview {
    Strichmännchen()
}
