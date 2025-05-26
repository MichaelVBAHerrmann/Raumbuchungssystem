import SwiftUI

/// Stilisierter iPhone-Rahmen im Comic-Stil mit animiertem Auftauchen.
/// Die `content`-Closure wird exakt im Display-Ausschnitt platziert.
struct DeviceFrameView<Content: View>: View {

    var content: () -> Content

    // Animationsstatus
    @State private var appear = false
    @State private var floatUp = false

    // Comic-Stil Parameter (anpassbar)
    let deviceBodyColor: Color = Color.gray.opacity(0.2) // Heller Grauton für das Gehäuse
    let screenBackgroundColor: Color = Color.gray.opacity(0.3) // leicht transparentes Grau, damit Hintergrund durchscheint
    let notchColor: Color = .black
    let buttonColor: Color = Color.gray.opacity(0.9)
    let outlineColor: Color = .black
    let comicOutlineWidth: CGFloat = 2.0 // Dicke der Hauptumrisse
    let buttonOutlineWidth: CGFloat = 1.5 // Etwas dünner für Knöpfe

    // Proportionen basierend auf der Gerätebreite (width)
    let bodyCornerRadiusFactor: CGFloat = 0.11 // Stärkere Abrundung für Comic-Look
    let screenInsetFactor: CGFloat = 0.055    // Abstand Display zum Gehäuserand
    
    // Notch/Dynamic Island Proportionen (relativ zur Bildschirmbreite/-höhe des DeviceFrameView)
    let notchWidthFactor: CGFloat = 0.35     // Breite der Notch
    let notchHeightFactor: CGFloat = 0.016   // Höhe der Notch (relativ zur Gerätehöhe)
    let notchCornerRadiusFactor: CGFloat = 0.3 // Abrundung der Notch (relativ zur Notch-Höhe)

    // Seitenknopf-Proportionen (relativ zur Gerätehöhe)
    let sideButtonWidthFactor: CGFloat = 0.018 // Dicke der Knöpfe
    let powerButtonHeightFactor: CGFloat = 0.12
    let volumeButtonHeightFactor: CGFloat = 0.07
    let silentSwitchHeightFactor: CGFloat = 0.035


    var body: some View {
        GeometryReader { geo in
            // Geräteproportionen beibehalten (iPhone 15 Pro Max ähnliches Verhältnis)
            let targetAspectRatio: CGFloat = 9.0 / 19.5
            let width  = min(geo.size.width, geo.size.height * targetAspectRatio)
            let height = width / targetAspectRatio
            
            // Dynamische Größen basierend auf der berechneten Gerätebreite/-höhe
            let bodyCornerRadius = width * bodyCornerRadiusFactor
            let screenInset = width * screenInsetFactor

            let displayAreaWidth = width - (2 * screenInset)
            let displayAreaHeight = height - (2 * screenInset)
            // Display-Ecken sollten etwas weniger abgerundet sein als Gehäuse-Ecken
            let displayCornerRadius = max(0, bodyCornerRadius - screenInset * 0.5)

            let actualNotchWidth = displayAreaWidth * notchWidthFactor
            let actualNotchHeight = height * notchHeightFactor // Höhe relativ zur gesamten Gerätehöhe
            let actualNotchCornerRadius = actualNotchHeight * notchCornerRadiusFactor

            let actualSideButtonWidth = height * sideButtonWidthFactor


            ZStack {
                // 1. Gerätegehäuse (Comic-Stil)
                RoundedRectangle(cornerRadius: bodyCornerRadius, style: .continuous)
                    .fill(deviceBodyColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: bodyCornerRadius, style: .continuous)
                            .strokeBorder(outlineColor, lineWidth: comicOutlineWidth)
                    )
                    .frame(width: width, height: height)

                // 2. Display-Bereich (Hintergrund für den Inhalt)
                RoundedRectangle(cornerRadius: displayCornerRadius, style: .continuous)
                    .fill(screenBackgroundColor)
                    .frame(width: displayAreaWidth, height: displayAreaHeight)
                    // Comic-Rand für den Display-Ausschnitt selbst
                    .overlay(
                        RoundedRectangle(cornerRadius: displayCornerRadius, style: .continuous)
                            .strokeBorder(outlineColor.opacity(0.6), lineWidth: comicOutlineWidth * 0.75)
                    )


                // 3. Inhalt im Display-Ausschnitt
                content()
                    .frame(width: displayAreaWidth * 0.98, height: displayAreaHeight * 0.98) // Kleine Anpassung für inneren Rand
                     // Der Inhalt wird so platziert, dass die Notch ihn nicht verdeckt (siehe unten)
                    .padding(.top, actualNotchHeight * 1.2) // Platz für Notch lassen
                    .frame(width: displayAreaWidth, height: displayAreaHeight)
                    .clipShape(RoundedRectangle(cornerRadius: displayCornerRadius, style: .continuous))


                // 4. Notch / Dynamic Island (Comic-Stil)
                // Wird über dem Inhalt, aber innerhalb des Display-Bereichs platziert
                RoundedRectangle(cornerRadius: actualNotchCornerRadius)
                    .fill(notchColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: actualNotchCornerRadius)
                            .strokeBorder(outlineColor.opacity(0.7), lineWidth: buttonOutlineWidth * 0.8)
                    )
                    .frame(width: actualNotchWidth, height: actualNotchHeight)
                    // Positionierung der Notch am oberen Rand des Display-Bereichs
                    .offset(y: (-height / 2) + screenInset + (actualNotchHeight / 2) + comicOutlineWidth * 0.2)


                // 5. Seitenknöpfe (Comic-Stil)
                let buttonXOffset = (width / 2) - (actualSideButtonWidth / 2) - (comicOutlineWidth / 2) + buttonOutlineWidth*0.5

                // Power-Knopf (Rechts)
                Capsule()
                    .fill(buttonColor)
                    .frame(width: actualSideButtonWidth, height: height * powerButtonHeightFactor)
                    .overlay(Capsule().strokeBorder(outlineColor, lineWidth: buttonOutlineWidth))
                    .offset(x: buttonXOffset, y: -height * 0.15) // Y-Position anpassen

                // Lautstärkeknöpfe (Links)
                VStack(spacing: height * 0.015) { // Abstand zwischen den Knöpfen
                    Capsule()
                        .fill(buttonColor)
                        .frame(width: actualSideButtonWidth, height: height * volumeButtonHeightFactor)
                        .overlay(Capsule().strokeBorder(outlineColor, lineWidth: buttonOutlineWidth))
                    Capsule()
                        .fill(buttonColor)
                        .frame(width: actualSideButtonWidth, height: height * volumeButtonHeightFactor)
                        .overlay(Capsule().strokeBorder(outlineColor, lineWidth: buttonOutlineWidth))
                }
                .offset(x: -buttonXOffset, y: -height * 0.15) // Y-Position anpassen
                
                // Stummschalter (Links, über den Lautstärkeknöpfen)
                 Capsule()
                     .fill(buttonColor)
                     .frame(width: actualSideButtonWidth, height: height * silentSwitchHeightFactor)
                     .overlay(Capsule().strokeBorder(outlineColor, lineWidth: buttonOutlineWidth))
                     .offset(x: -buttonXOffset, y: -height * 0.32) // Y-Position anpassen
            }
            .frame(width: width, height: height) // Stellt sicher, dass der ZStack die korrekte Größe hat
            // Animationen bleiben erhalten
            .scaleEffect(appear ? 1 : 0.8)
            .offset(y: floatUp ? -6 : 6)
            .opacity(appear ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    appear = true
                }
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    floatUp.toggle()
                }
            }
        }
        // Behält die Proportionen des DeviceFrameView bei, wenn es in einem Eltern-Layout platziert wird.
        // Es ist wichtig, hier das korrekte Seitenverhältnis (Breite/Höhe) zu verwenden.
        .aspectRatio(9.0 / 19.5, contentMode: .fit)
    }
}

// MARK: - Previews
#Preview("DeviceFrameView Preview") {
    DeviceFrameView {
        // Sample content for preview
        Text("Preview")
            .font(.headline)
            .foregroundColor(.black)
    }
    .frame(width: 200, height: 400)
}

