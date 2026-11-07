import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: PlanStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var revealing: MoviePlan?
    @State private var showSettings = false
    @State private var lockedMessage: String?

    private var november: [MoviePlan] { MoviePlan.all.filter { $0.month == 11 } }
    private var december: [MoviePlan] { MoviePlan.all.filter { $0.month == 12 && !$0.isSpecial } }
    private var special: MoviePlan? { MoviePlan.all.first { $0.isSpecial } }
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            SnowfallView()

            ScrollView {
                VStack(spacing: 22) {
                    header
                    if let next = store.nextPlan() { NextPlanCard(plan: next) }

                    MonthBanner(text: "NOVIEMBRE")
                    grid(november)
                    MonthBanner(text: "DICIEMBRE")
                    grid(december)
                    if let special {
                        DoorView(plan: special, wide: true) { tap(special) }
                    }
                    extras
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }

            if let lockedMessage {
                VStack {
                    Spacer()
                    Text(lockedMessage)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 18).padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 30)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .overlay(alignment: .topTrailing) {
            Button { showSettings = true } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.gold)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding(.trailing, 16)
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .fullScreenCover(item: $revealing) { plan in RevealView(plan: plan) }
        .task {
            await store.setUp()
            autoReveal()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { store.reschedule(); autoReveal() }
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("Calendario de Adviento de")
                .font(Theme.title(22))
            Text("Películas y Comidas")
                .font(Theme.title(34).italic())
            Text("Fines de semana + especial Nochebuena · 2026")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.burgundy)
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(Capsule().fill(Theme.cream))
                .padding(.top, 4)
        }
        .foregroundStyle(Theme.cream)
        .multilineTextAlignment(.center)
        .padding(.top, 50)
    }

    private func grid(_ plans: [MoviePlan]) -> some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(plans) { plan in
                DoorView(plan: plan) { tap(plan) }
            }
        }
    }

    private var extras: some View {
        VStack(spacing: 10) {
            Text("Extra ideal para acompañar")
                .font(Theme.title(18).italic())
                .foregroundStyle(Theme.gold)
            HStack(spacing: 0) {
                extra("🍿", "Palomitas")
                extra("☕️", "Chocolate caliente")
                extra("🍪", "Cookies")
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Theme.cream.opacity(0.1)))
    }

    private func extra(_ emoji: String, _ text: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji).font(.system(size: 34))
            Text(text).font(.caption.weight(.semibold)).multilineTextAlignment(.center)
        }
        .foregroundStyle(Theme.cream)
        .frame(maxWidth: .infinity)
    }

    private func tap(_ plan: MoviePlan) {
        if store.isUnlocked(plan) {
            revealing = plan
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            withAnimation(.spring) { lockedMessage = "🔒 Esta puerta se abre el \(plan.dayLabel.lowercased())" }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { lockedMessage = nil }
            }
        }
    }

    private func autoReveal() {
        guard revealing == nil, let plan = store.todayPlanToReveal() else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { revealing = plan }
    }
}

/// Tarjeta superior con el próximo plan y la cuenta atrás.
struct NextPlanCard: View {
    @EnvironmentObject private var store: PlanStore
    let plan: MoviePlan

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { context in
            let now = context.date
            let prep = plan.prepStart(dinnerMinutes: store.dinnerMinutes)
            let movie = plan.movieTime(dinnerMinutes: store.dinnerMinutes)
            VStack(alignment: .leading, spacing: 6) {
                Text(store.isToday(plan, now: now) ? "✨ HOY HAY PLAN" : "PRÓXIMO PLAN · \(plan.dayLabel)")
                    .font(.caption.weight(.heavy))
                    .tracking(1.5)
                    .foregroundStyle(Theme.gold)
                if store.isToday(plan, now: now) {
                    Text(status(now: now, prep: prep, movie: movie))
                        .font(.headline)
                    Text("Abre la puerta de hoy para ver la peli y la cena")
                        .font(.subheadline).opacity(0.8)
                } else {
                    Text(countdown(now: now))
                        .font(.headline)
                    Text("Te avisaré a las \(store.timeString(prep)) para empezar a cocinar")
                        .font(.subheadline).opacity(0.8)
                }
            }
            .foregroundStyle(Theme.cream)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.gold.opacity(0.6), lineWidth: 1))
        }
    }

    private func status(now: Date, prep: Date, movie: Date) -> String {
        if now < prep { return "A cocinar a las \(store.timeString(prep)) · peli a las \(store.timeString(movie))" }
        if now < movie { return "🍳 ¡Toca cocinar! La peli empieza a las \(store.timeString(movie))" }
        return "🍿 ¡A disfrutar de la peli!"
    }

    private func countdown(now: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: now), to: plan.date).day ?? 0
        return days == 1 ? "Mañana se abre una puerta" : "Faltan \(days) días para la siguiente puerta"
    }
}
