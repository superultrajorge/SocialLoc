import SwiftUI

/// Ruleta para cuando la pareja no se decide.
struct RouletteView: View {
    @Environment(AppModel.self) private var model
    @Environment(PremiumStore.self) private var premium
    @Environment(\.dismiss) private var dismiss

    /// Si se abre desde un plan, devuelve la peli elegida.
    var onPick: ((Movie) -> Void)? = nil

    @State private var rotation: Double = 0
    @State private var spinning = false
    @State private var winner: Movie?
    @State private var showPicker = false
    @State private var showPaywall = false
    @State private var assignedMessage: String?

    private var movies: [Movie] {
        let all = model.rouletteMovies
        return premium.isPremium ? all : Array(all.prefix(AppModel.freeRouletteLimit))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(spacing: 24) {
                        Text("¿Qué peli vemos?")
                            .font(Theme.serif(30))
                            .foregroundStyle(Theme.cream)
                            .padding(.top, 8)

                        wheel
                            .frame(width: 330, height: 330)
                            .padding(.top, 4)

                        Button {
                            spin()
                        } label: {
                            Label(spinning ? "Girando…" : "¡Girar!", systemImage: "sparkles")
                                .font(.title3.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.glassProminent)
                        .disabled(spinning || movies.count < 2)
                        .padding(.horizontal, 30)

                        if movies.count < 2 {
                            Text("Añade al menos 2 pelis a la ruleta").foregroundStyle(Theme.cream.opacity(0.8))
                        }

                        candidates
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Ruleta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showPicker = true } label: { Image(systemName: "plus") }
                }
                if onPick != nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cerrar", role: .cancel) { dismiss() }
                    }
                }
            }
            .sheet(isPresented: $showPicker) {
                NavigationStack {
                    MoviePickerView(selection: nil)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Listo") { showPicker = false }
                            }
                        }
                }
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .sheet(item: $winner) { movie in winnerSheet(movie) }
        }
    }

    // MARK: - Rueda

    private var wheel: some View {
        ZStack {
            WheelShapeView(movies: movies)
                .rotationEffect(.degrees(rotation))
                .shadow(color: Theme.gold.opacity(0.4), radius: 20)

            // Centro
            Circle()
                .fill(.clear)
                .frame(width: 70, height: 70)
                .glassEffect(.regular.tint(Theme.gold.opacity(0.4)), in: .circle)
                .overlay(Text("🍿").font(.system(size: 30)))

            // Puntero
            VStack {
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(Theme.gold)
                    .shadow(color: .black.opacity(0.5), radius: 3)
                    .offset(y: -14)
                Spacer()
            }
        }
    }

    private func spin() {
        guard movies.count >= 2, !spinning else { return }
        spinning = true
        let count = movies.count
        let seg = 360.0 / Double(count)
        let index = Int.random(in: 0..<count)
        let jitter = Double.random(in: -seg * 0.35...seg * 0.35)
        // Con la rueda girada r grados, bajo el puntero queda el ángulo (360 - r) mod 360.
        let targetMod = (360 - (Double(index) * seg + seg / 2 + jitter)).truncatingRemainder(dividingBy: 360)
        let currentMod = rotation.truncatingRemainder(dividingBy: 360)
        let target = rotation - currentMod + 360 * 6 + (targetMod < 0 ? targetMod + 360 : targetMod)

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.timingCurve(0.12, 0.8, 0.2, 1, duration: 4.2)) { rotation = target }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.3) {
            spinning = false
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            winner = movies[index]
        }
    }

    // MARK: - Candidatas

    private var candidates: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Eyebrow(text: "EN LA RULETA (\(model.rouletteMovies.count))")
                Spacer()
                Button("Añadir") { showPicker = true }.font(.subheadline.weight(.semibold))
            }
            ForEach(model.rouletteMovies) { movie in
                let locked = !movies.contains(where: { $0.id == movie.id })
                HStack {
                    MovieRow(movie: movie).opacity(locked ? 0.45 : 1)
                    Spacer()
                    if locked {
                        Button { showPaywall = true } label: { Image(systemName: "lock.fill") }
                            .foregroundStyle(Theme.gold)
                    } else {
                        Button { model.toggleRoulette(movie) } label: { Image(systemName: "minus.circle.fill") }
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
            if !premium.isPremium && model.rouletteMovies.count > AppModel.freeRouletteLimit {
                Button("Desbloquea la ruleta ilimitada con Premium") { showPaywall = true }
                    .font(.footnote.weight(.semibold))
            }
        }
        .padding(16)
        .glassCard()
    }

    // MARK: - Resultado

    private func winnerSheet(_ movie: Movie) -> some View {
        ZStack {
            AppBackground()
            MagicSparkles(burst: Date())
            VStack(spacing: 18) {
                Eyebrow(text: "✨ ESTA NOCHE TOCA ✨")
                PosterView(movie: movie, radius: 18)
                    .frame(width: 170, height: 250)
                    .shadow(color: Theme.gold.opacity(0.6), radius: 24)
                Text(movie.title)
                    .font(Theme.serif(26))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.cream)
                Text(movie.overview)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.cream.opacity(0.85))
                    .lineLimit(4)

                if let onPick {
                    Button("Usar en este plan") { winner = nil; onPick(movie) }
                        .buttonStyle(.glassProminent)
                } else {
                    Button("Ponerla en el próximo plan libre") {
                        if let plan = model.assignToNextFreePlan(movie) {
                            assignedMessage = "Guardada para el \(plan.dayLabel.lowercased()) ✅"
                        } else {
                            assignedMessage = "No hay planes sin peli. Añade uno en el calendario."
                        }
                    }
                    .buttonStyle(.glassProminent)
                    if let assignedMessage {
                        Text(assignedMessage).font(.footnote).foregroundStyle(Theme.cream)
                    }
                }
                Button("Girar otra vez") { winner = nil; assignedMessage = nil }
                    .buttonStyle(.glass)
            }
            .padding(24)
        }
        .presentationDetents([.large])
    }
}

/// Dibujo de la rueda: un sector por peli, empezando arriba y en sentido horario.
struct WheelShapeView: View {
    let movies: [Movie]
    private let colors: [Color] = [Theme.deepRed, Theme.pine, Theme.burgundy, Color(red: 0.55, green: 0.38, blue: 0.12)]

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let r = size / 2
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let count = max(movies.count, 1)
            let seg = 360.0 / Double(count)
            ZStack {
                ForEach(Array(movies.enumerated()), id: \.element.id) { i, movie in
                    sector(center: center, radius: r, from: Double(i) * seg, to: Double(i + 1) * seg)
                        .fill(colors[(count % 2 == 1 && i == count - 1 && count > 1) ? 3 : i % 3])
                    sector(center: center, radius: r, from: Double(i) * seg, to: Double(i + 1) * seg)
                        .stroke(Theme.gold.opacity(0.7), lineWidth: 1.5)
                    label(movie, angle: Double(i) * seg + seg / 2, center: center, radius: r * 0.62)
                }
                if movies.isEmpty {
                    Circle().fill(Theme.burgundy)
                }
                Circle().stroke(Theme.gold, lineWidth: 5)
            }
        }
    }

    /// Ángulos en grados, 0 = arriba, sentido horario.
    private func point(_ center: CGPoint, _ radius: Double, _ degrees: Double) -> CGPoint {
        let a = degrees * .pi / 180
        return CGPoint(x: center.x + radius * sin(a), y: center.y - radius * cos(a))
    }

    private func sector(center: CGPoint, radius: Double, from: Double, to: Double) -> Path {
        Path { p in
            p.move(to: center)
            let steps = max(Int((to - from) / 3), 2)
            for s in 0...steps {
                p.addLine(to: point(center, radius, from + (to - from) * Double(s) / Double(steps)))
            }
            p.closeSubpath()
        }
    }

    private func label(_ movie: Movie, angle: Double, center: CGPoint, radius: Double) -> some View {
        VStack(spacing: 2) {
            Text(movie.emoji).font(.system(size: 20))
            Text(movie.title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Theme.cream)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
        .rotationEffect(.degrees(angle))
        .position(point(center, radius, angle))
    }
}
