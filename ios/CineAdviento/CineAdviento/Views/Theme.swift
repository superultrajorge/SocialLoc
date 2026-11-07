import SwiftUI

enum Theme {
    static let burgundy = Color(red: 0.42, green: 0.05, blue: 0.09)
    static let deepRed = Color(red: 0.70, green: 0.10, blue: 0.16)
    static let pine = Color(red: 0.05, green: 0.30, blue: 0.18)
    static let night = Color(red: 0.04, green: 0.05, blue: 0.09)
    static let gold = Color(red: 0.96, green: 0.80, blue: 0.45)
    static let cream = Color(red: 0.99, green: 0.95, blue: 0.87)

    static func serif(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}

/// Fondo vivo: degradado de malla que se mueve muy despacio + nieve.
struct AppBackground: View {
    var snow = true

    var body: some View {
        ZStack {
            TimelineView(.animation(minimumInterval: 1 / 20)) { context in
                let t = Float(context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 10_000))
                let center = SIMD2<Float>(0.5 + 0.12 * sin(t * 0.25), 0.45 + 0.1 * cos(t * 0.2))
                let points: [SIMD2<Float>] = [
                    SIMD2(0, 0), SIMD2(0.5, 0), SIMD2(1, 0),
                    SIMD2(0, 0.5), center, SIMD2(1, 0.5),
                    SIMD2(0, 1), SIMD2(0.5, 1), SIMD2(1, 1),
                ]
                MeshGradient(
                    width: 3, height: 3,
                    points: points,
                    colors: [
                        Theme.burgundy, Theme.deepRed, Theme.night,
                        Theme.night, Theme.burgundy, Theme.pine,
                        Theme.pine, Theme.night, Theme.burgundy,
                    ]
                )
            }
            .ignoresSafeArea()
            if snow { SnowfallView() }
        }
    }
}

extension View {
    /// Tarjeta de cristal con tinte cálido.
    func glassCard(_ radius: CGFloat = 24, tint: Color = Theme.burgundy.opacity(0.25), interactive: Bool = false) -> some View {
        glassEffect(interactive ? .regular.tint(tint).interactive() : .regular.tint(tint), in: .rect(cornerRadius: radius))
    }
}

/// Etiqueta pequeña en mayúsculas, dorada.
struct Eyebrow: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption.weight(.heavy))
            .tracking(1.6)
            .foregroundStyle(Theme.gold)
    }
}

/// Póster de una peli: TMDB, ilustración local o emoji.
struct PosterView: View {
    let movie: Movie?
    var artwork: String? = nil
    var radius: CGFloat = 14

    var body: some View {
        ZStack {
            if let url = movie?.posterURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        placeholder
                    }
                }
            } else if let name = artwork ?? movie?.artwork {
                Image(name).resizable().scaledToFill()
            } else {
                placeholder
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: radius))
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(colors: [Theme.deepRed, Theme.burgundy], startPoint: .top, endPoint: .bottom)
            Text(movie?.emoji ?? "🎬").font(.system(size: 34))
        }
    }
}
