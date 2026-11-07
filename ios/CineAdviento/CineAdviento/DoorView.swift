import SwiftUI

/// Una puerta del calendario: cerrada, lista para abrir o ya abierta.
struct DoorView: View {
    @EnvironmentObject private var store: PlanStore
    let plan: MoviePlan
    var wide = false
    let action: () -> Void

    @State private var shakes: CGFloat = 0
    @State private var pulse = false

    private var unlocked: Bool { store.isUnlocked(plan) }
    private var opened: Bool { store.opened.contains(plan.id) }

    var body: some View {
        Button {
            if !unlocked { withAnimation(.linear(duration: 0.4)) { shakes += 1 } }
            action()
        } label: {
            ZStack {
                if opened {
                    openedFace
                } else {
                    closedFace
                }
            }
            .frame(height: wide ? 150 : 170)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.gold.opacity(unlocked ? 0.9 : 0.35), lineWidth: unlocked && !opened ? 2 : 1))
            .shadow(color: unlocked && !opened ? Theme.gold.opacity(pulse ? 0.8 : 0.2) : .black.opacity(0.4),
                    radius: unlocked && !opened ? (pulse ? 16 : 6) : 6)
        }
        .buttonStyle(.plain)
        .modifier(Shake(animatableData: shakes))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { pulse = true }
        }
    }

    private var openedFace: some View {
        Image(plan.image)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(Theme.gold)
                    .padding(8)
                    .shadow(radius: 3)
            }
    }

    private var closedFace: some View {
        ZStack {
            LinearGradient(colors: unlocked ? [Theme.deepRed, Theme.burgundy] : [Theme.burgundy.opacity(0.9), Theme.night],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            // Lazo de regalo
            Rectangle().fill(Theme.gold.opacity(0.55)).frame(width: 10)
            Rectangle().fill(Theme.gold.opacity(0.55)).frame(height: 10)

            VStack(spacing: 6) {
                Text(plan.dayLabel)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Theme.cream)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(Theme.burgundy))
                    .overlay(Capsule().stroke(Theme.gold, lineWidth: 1))
                Text(plan.isSpecial ? "🎁" : "\(plan.day)")
                    .font(Theme.title(plan.isSpecial ? 50 : 54))
                    .foregroundStyle(Theme.gold)
                    .shadow(color: .black.opacity(0.5), radius: 4)
                if plan.isSpecial {
                    Text("ESPECIAL NOCHEBUENA")
                        .font(.caption.weight(.heavy)).tracking(1.5)
                        .foregroundStyle(Theme.cream)
                }
                Label(unlocked ? "¡Ábreme!" : "Cerrada", systemImage: unlocked ? "sparkles" : "lock.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(unlocked ? Theme.cream : Theme.cream.opacity(0.55))
                    .scaleEffect(unlocked && pulse ? 1.08 : 1)
            }
        }
    }
}
