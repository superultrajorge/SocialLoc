import SwiftUI

private struct Flake {
    let x = Double.random(in: 0...1)
    let speed = Double.random(in: 0.03...0.09)
    let size = Double.random(in: 1.5...4.5)
    let drift = Double.random(in: 0...(2 * .pi))
    let offset = Double.random(in: 0...1)
}

/// Nieve cayendo suavemente de fondo.
struct SnowfallView: View {
    @State private var flakes = (0..<70).map { _ in Flake() }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                for f in flakes {
                    let y = (f.offset + t * f.speed).truncatingRemainder(dividingBy: 1.0)
                    let x = f.x + sin(t * 0.6 + f.drift) * 0.015
                    let rect = CGRect(x: x * size.width, y: y * (size.height + 20) - 10, width: f.size, height: f.size)
                    ctx.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.25 + f.size / 10)))
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

private struct Spark {
    let angle = Double.random(in: 0..<(2 * .pi))
    let speed = Double.random(in: 140...480)
    let size = Double.random(in: 6...18)
    let x = Double.random(in: 0...1)
    let y = Double.random(in: 0...1)
    let phase = Double.random(in: 0...(2 * .pi))
    let isStar = Bool.random()
    let color: Color = [Theme.gold, .white, Color(red: 1, green: 0.85, blue: 0.5), Color(red: 1, green: 0.55, blue: 0.5)].randomElement()!
}

/// Destellos mágicos: brillos que parpadean y, al abrir, una explosión de estrellas.
struct MagicSparkles: View {
    var burst: Date?
    var ambient: Bool = true
    @State private var sparks = (0..<90).map { _ in Spark() }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                var glow = ctx
                glow.addFilter(.blur(radius: 2))

                if ambient {
                    for s in sparks.prefix(40) {
                        let a = max(0, sin(t * 2 + s.phase))
                        let p = CGPoint(x: s.x * size.width, y: s.y * size.height)
                        draw(&glow, s, at: p, scale: 0.6, opacity: a * 0.8)
                    }
                }

                if let burst {
                    let dt = timeline.date.timeIntervalSince(burst)
                    if dt >= 0 && dt < 2.6 {
                        let center = CGPoint(x: size.width / 2, y: size.height * 0.42)
                        for s in sparks {
                            let d = s.speed * dt * (1 - dt / 5.2)
                            let p = CGPoint(x: center.x + cos(s.angle) * d,
                                            y: center.y + sin(s.angle) * d + 60 * dt * dt)
                            draw(&glow, s, at: p, scale: 1, opacity: 1 - dt / 2.6)
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private func draw(_ ctx: inout GraphicsContext, _ s: Spark, at p: CGPoint, scale: Double, opacity: Double) {
        ctx.opacity = opacity
        if s.isStar {
            ctx.draw(Text("✦").font(.system(size: s.size * scale)).foregroundColor(s.color), at: p)
        } else {
            let r = s.size * 0.35 * scale
            ctx.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)), with: .color(s.color))
        }
    }
}

/// Sacudida para las puertas cerradas.
struct Shake: GeometryEffect {
    var travel: CGFloat = 8
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: travel * sin(animatableData * .pi * 4), y: 0))
    }
}
