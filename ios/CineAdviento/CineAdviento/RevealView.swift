import SwiftUI

/// La animación mágica: un regalo que tiembla, se abre con una explosión
/// de estrellas y revela la película y la cena.
struct RevealView: View {
    @EnvironmentObject private var store: PlanStore
    @Environment(\.dismiss) private var dismiss
    let plan: MoviePlan

    private enum Phase { case closed, opening, revealed }
    @State private var phase: Phase = .closed
    @State private var wobble = false
    @State private var burst: Date?
    @State private var flash = 0.0
    @State private var showCard = false
    @State private var showTitle = false
    @State private var showFood = false
    @State private var showDetails = false

    var body: some View {
        ZStack {
            RadialGradient(colors: [Theme.deepRed, Theme.burgundy, Theme.night], center: .center, startRadius: 20, endRadius: 600)
                .ignoresSafeArea()
            SnowfallView()
            MagicSparkles(burst: burst)

            if phase != .revealed { gift }
            if phase == .revealed { revealed }

            Color.white.opacity(flash).ignoresSafeArea().allowsHitTesting(false)
        }
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(Theme.cream)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(.trailing, 16)
        }
        .onAppear {
            // Si ya estaba abierta, se enseña directamente.
            if store.opened.contains(plan.id) {
                phase = .revealed
                showCard = true; showTitle = true; showFood = true; showDetails = true
            } else {
                withAnimation(.easeInOut(duration: 0.12).repeatForever(autoreverses: true)) { wobble = true }
            }
        }
    }

    // MARK: - Regalo cerrado

    private var gift: some View {
        VStack(spacing: 28) {
            Text(plan.dayLabel)
                .font(.headline.weight(.heavy)).tracking(2)
                .foregroundStyle(Theme.gold)
            Text("🎁")
                .font(.system(size: 150))
                .rotationEffect(.degrees(phase == .closed ? (wobble ? 6 : -6) : 0))
                .scaleEffect(phase == .opening ? 2.4 : 1)
                .opacity(phase == .opening ? 0 : 1)
                .shadow(color: Theme.gold.opacity(0.8), radius: 30)
            Text("Toca para abrir la puerta de hoy")
                .font(Theme.title(20).italic())
                .foregroundStyle(Theme.cream)
                .opacity(phase == .closed ? 1 : 0)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: open)
    }

    private func open() {
        guard phase == .closed else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        withAnimation(.easeIn(duration: 0.45)) { phase = .opening }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            burst = Date()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.easeOut(duration: 0.08)) { flash = 0.85 }
            withAnimation(.easeOut(duration: 0.9).delay(0.08)) { flash = 0 }
            phase = .revealed
            store.opened.insert(plan.id)
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.15)) { showCard = true }
            withAnimation(.easeOut(duration: 0.6).delay(0.7)) { showTitle = true }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(1.2)) { showFood = true }
            withAnimation(.easeOut(duration: 0.6).delay(1.8)) { showDetails = true }
        }
    }

    // MARK: - Revelado

    private var revealed: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(plan.isSpecial ? "✨ ESPECIAL NOCHEBUENA ✨" : "✨ \(plan.dayLabel) ✨")
                    .font(.subheadline.weight(.heavy)).tracking(2)
                    .foregroundStyle(Theme.gold)
                    .padding(.top, 60)

                Image(plan.image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.gold, lineWidth: 2))
                    .shadow(color: Theme.gold.opacity(0.6), radius: 24)
                    .rotation3DEffect(.degrees(showCard ? 0 : 90), axis: (x: 0, y: 1, z: 0))
                    .scaleEffect(showCard ? 1 : 0.3)
                    .opacity(showCard ? 1 : 0)

                VStack(spacing: 6) {
                    Text("🎬 LA PELI")
                        .font(.caption.weight(.heavy)).tracking(2)
                        .foregroundStyle(Theme.gold)
                    Text(plan.title)
                        .font(Theme.title(30))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.cream)
                }
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 20)
                .blur(radius: showTitle ? 0 : 8)

                VStack(spacing: 8) {
                    Text("🍽️ LA CENA")
                        .font(.caption.weight(.heavy)).tracking(2)
                        .foregroundStyle(Theme.gold)
                    Text(plan.emoji)
                        .font(.system(size: 64))
                        .scaleEffect(showFood ? 1 : 0.1)
                        .rotationEffect(.degrees(showFood ? 0 : -180))
                    Text(plan.food)
                        .font(Theme.title(21))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.cream)
                }
                .opacity(showFood ? 1 : 0)

                details
                    .opacity(showDetails ? 1 : 0)
                    .offset(y: showDetails ? 0 : 30)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Preparación: \(plan.prepText)", systemImage: "timer")
                Spacer()
                Label(store.timeString(plan.prepStart(dinnerMinutes: store.dinnerMinutes)), systemImage: "bell.fill")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.gold)

            Text(plan.prepTip)
                .font(.subheadline)

            Divider().overlay(Theme.gold.opacity(0.5))

            Text("Lista de la compra")
                .font(.headline)
            ForEach(plan.ingredients, id: \.self) { item in
                Label(item, systemImage: "checkmark.circle")
                    .font(.subheadline)
            }

            Divider().overlay(Theme.gold.opacity(0.5))
            Text("🍿 Palomitas · ☕️ Chocolate caliente · 🍪 Cookies")
                .font(.footnote.weight(.semibold))
                .frame(maxWidth: .infinity)
        }
        .foregroundStyle(Theme.cream)
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial))
    }
}
