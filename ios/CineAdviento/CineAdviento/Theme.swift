import SwiftUI

enum Theme {
    static let burgundy = Color(red: 0.42, green: 0.05, blue: 0.09)
    static let deepRed = Color(red: 0.62, green: 0.08, blue: 0.12)
    static let pine = Color(red: 0.06, green: 0.24, blue: 0.14)
    static let night = Color(red: 0.05, green: 0.07, blue: 0.10)
    static let gold = Color(red: 0.93, green: 0.77, blue: 0.42)
    static let cream = Color(red: 0.98, green: 0.94, blue: 0.85)

    static let background = LinearGradient(colors: [burgundy, Color(red: 0.18, green: 0.04, blue: 0.06), pine],
                                           startPoint: .top, endPoint: .bottom)

    static func title(_ size: CGFloat) -> Font { .system(size: size, weight: .bold, design: .serif) }
}

/// Banda tipo "NOVIEMBRE" con acebo.
struct MonthBanner: View {
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Text("🌿")
            Text(text)
                .font(Theme.title(24))
                .tracking(2)
                .foregroundStyle(Theme.cream)
            Text("🌿")
        }
        .padding(.horizontal, 22).padding(.vertical, 6)
        .background(Capsule().fill(Theme.pine).overlay(Capsule().stroke(Theme.gold, lineWidth: 1.5)))
        .frame(maxWidth: .infinity)
    }
}
