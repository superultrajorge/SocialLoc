import SwiftUI

/// La animación mágica: un regalo que tiembla, estalla en estrellas
/// y revela la película y la cena.
struct RevealView: View {
    @Environment(AppModel.self) private var model
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
    @State private var checked: Set<String> = []

    private var movieMinutes: Int { model.current?.movieMinutes ?? 21 * 60 }

    var body: some View {
        ZStack {
            AppBackground()
            MagicSparkles(burst: burst)

            if phase != .revealed { gift }
            if phase == .revealed { revealed }

            Color.white.opacity(flash).ignoresSafeArea().allowsHitTesting(false)
        }
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.headline).padding(6)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .padding(.trailing, 16)
        }
        .onAppear {
            if plan.opened {
                phase = .revealed
                showCard = true; showTitle = true; showFood = true; showDetails = true
            } else {
                withAnimation(.easeInOut(duration: 0.12).repeatForever(autoreverses: true)) { wobble = true }
            }
        }
    }

    // MARK: - Regalo

    private var gift: some View {
        VStack(spacing: 28) {
            Eyebrow(text: plan.dayLabel)
            Text("🎁")
                .font(.system(size: 150))
                .rotationEffect(.degrees(phase == .closed ? (wobble ? 6 : -6) : 0))
                .scaleEffect(phase == .opening ? 2.4 : 1)
                .opacity(phase == .opening ? 0 : 1)
                .shadow(color: Theme.gold.opacity(0.8), radius: 30)
            Text("Toca para abrir la puerta de hoy")
                .font(Theme.serif(20).italic())
                .foregroundStyle(Theme.cream)
                .padding(.horizontal, 22).padding(.vertical, 12)
                .glassEffect()
                .opacity(phase == .closed ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            model.markOpened(plan)
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.15)) { showCard = true }
            withAnimation(.easeOut(duration: 0.6).delay(0.7)) { showTitle = true }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(1.2)) { showFood = true }
            withAnimation(.easeOut(duration: 0.6).delay(1.8)) { showDetails = true }
        }
    }

    // MARK: - Revelado

    private var revealed: some View {
        ScrollView {
            VStack(spacing: 22) {
                Eyebrow(text: plan.isSpecial ? "✨ ESPECIAL ✨" : "✨ \(plan.dayLabel) ✨")
                    .padding(.top, 56)

                PosterView(movie: plan.movie, artwork: plan.artwork, radius: 22)
                    .frame(width: plan.movie?.posterURL != nil ? 230 : nil)
                    .frame(height: plan.movie?.posterURL != nil ? 345 : 190)
                    .frame(maxWidth: .infinity)
                    .shadow(color: Theme.gold.opacity(0.55), radius: 28)
                    .rotation3DEffect(.degrees(showCard ? 0 : 90), axis: (x: 0, y: 1, z: 0))
                    .scaleEffect(showCard ? 1 : 0.3)
                    .opacity(showCard ? 1 : 0)

                VStack(spacing: 8) {
                    Eyebrow(text: "🎬 LA PELI")
                    Text(plan.movie?.title ?? "Peli por decidir")
                        .font(Theme.serif(30))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.cream)
                    if let movie = plan.movie {
                        if !movie.subtitle.isEmpty {
                            Text(movie.subtitle).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.gold)
                        }
                        Text(movie.overview)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Theme.cream.opacity(0.85))
                    }
                }
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 20)
                .blur(radius: showTitle ? 0 : 8)

                if let menu = plan.menu {
                    VStack(spacing: 8) {
                        Eyebrow(text: "🍽️ LA CENA")
                        Text(menu.emoji)
                            .font(.system(size: 64))
                            .scaleEffect(showFood ? 1 : 0.1)
                            .rotationEffect(.degrees(showFood ? 0 : -180))
                        Text(menu.name)
                            .font(Theme.serif(21))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Theme.cream)
                    }
                    .opacity(showFood ? 1 : 0)

                    details(menu)
                        .opacity(showDetails ? 1 : 0)
                        .offset(y: showDetails ? 0 : 30)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }

    private func details(_ menu: DinnerMenu) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Preparación: \(menu.prepText)", systemImage: "timer")
                Spacer()
                Label(plan.prepStart(movieMinutes).formatted(date: .omitted, time: .shortened), systemImage: "bell.fill")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.gold)

            Text(menu.tip).font(.subheadline)

            Divider()

            Text("Lista de la compra").font(.headline)
            ForEach(menu.ingredients, id: \.self) { item in
                Button {
                    if checked.contains(item) { checked.remove(item) } else { checked.insert(item) }
                } label: {
                    Label(item, systemImage: checked.contains(item) ? "checkmark.circle.fill" : "circle")
                        .font(.subheadline)
                        .strikethrough(checked.contains(item))
                }
                .buttonStyle(.plain)
            }

            Divider()
            Text("🍿 Palomitas · ☕️ Chocolate caliente · 🍪 Cookies")
                .font(.footnote.weight(.semibold))
                .frame(maxWidth: .infinity)
        }
        .foregroundStyle(Theme.cream)
        .padding(18)
        .glassCard()
    }
}
