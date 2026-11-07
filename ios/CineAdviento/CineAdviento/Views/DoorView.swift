import SwiftUI

/// Una puerta del calendario: cerrada, lista para abrir, abierta o por decidir.
struct DoorView: View {
    @Environment(AppModel.self) private var model
    let plan: MoviePlan
    let action: () -> Void

    @State private var shakes: CGFloat = 0
    @State private var pulse = false

    private var unlocked: Bool { model.isUnlocked(plan) }
    private var ready: Bool { unlocked && !plan.opened && !plan.isEmpty }

    var body: some View {
        Button {
            if !unlocked && !plan.isEmpty { withAnimation(.linear(duration: 0.4)) { shakes += 1 } }
            action()
        } label: {
            ZStack {
                if plan.opened && !plan.isEmpty {
                    openedFace
                } else {
                    closedFace
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: plan.isSpecial ? 160 : 180)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .contentShape(RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.tint(ready ? Theme.gold.opacity(0.25) : Theme.burgundy.opacity(0.15)).interactive(),
                     in: .rect(cornerRadius: 22))
        .shadow(color: ready ? Theme.gold.opacity(pulse ? 0.7 : 0.15) : .clear, radius: pulse ? 18 : 6)
        .modifier(Shake(animatableData: shakes))
        .onAppear {
            guard ready else { return }
            withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) { pulse = true }
        }
    }

    private var openedFace: some View {
        ZStack(alignment: .bottomLeading) {
            PosterView(movie: plan.movie, artwork: plan.artwork, radius: 0)
            LinearGradient(colors: [.clear, .black.opacity(0.85)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 2) {
                Text(plan.dayLabel).font(.caption2.weight(.heavy)).foregroundStyle(Theme.gold)
                Text(plan.movie?.title ?? "Peli por decidir")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                if let menu = plan.menu {
                    Text("\(menu.emoji) \(menu.name)").font(.caption2).foregroundStyle(.white.opacity(0.8)).lineLimit(1)
                }
            }
            .padding(10)
        }
    }

    private var closedFace: some View {
        ZStack {
            // Lazo de regalo
            Rectangle().fill(Theme.gold.opacity(unlocked ? 0.5 : 0.25)).frame(width: 8)
            Rectangle().fill(Theme.gold.opacity(unlocked ? 0.5 : 0.25)).frame(height: 8)

            VStack(spacing: 6) {
                Text(plan.dayLabel)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Theme.cream)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .glassEffect(.regular.tint(Theme.burgundy.opacity(0.6)))
                Text(plan.isSpecial ? "🎁" : "\(plan.dayNumber)")
                    .font(Theme.serif(plan.isSpecial ? 48 : 56))
                    .foregroundStyle(LinearGradient(colors: [Theme.cream, Theme.gold], startPoint: .top, endPoint: .bottom))
                    .shadow(color: .black.opacity(0.4), radius: 4)
                if plan.isSpecial {
                    Text("ESPECIAL").font(.caption.weight(.heavy)).tracking(2).foregroundStyle(Theme.cream)
                }
                status
            }
        }
    }

    @ViewBuilder
    private var status: some View {
        if plan.isEmpty {
            Label("Elegir plan", systemImage: "plus.circle.fill")
                .font(.caption.weight(.bold)).foregroundStyle(Theme.gold)
        } else if unlocked {
            Label("¡Ábreme!", systemImage: "sparkles")
                .font(.caption.weight(.bold)).foregroundStyle(Theme.cream)
                .scaleEffect(pulse ? 1.08 : 1)
        } else {
            Label("Cerrada", systemImage: "lock.fill")
                .font(.caption.weight(.bold)).foregroundStyle(Theme.cream.opacity(0.55))
        }
    }
}
