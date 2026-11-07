import SwiftUI

struct CalendarHomeView: View {
    @Environment(AppModel.self) private var model
    @Environment(PremiumStore.self) private var premium
    @Environment(\.scenePhase) private var scenePhase

    @State private var revealing: MoviePlan?
    @State private var editing: MoviePlan?
    @State private var showNewCalendar = false
    @State private var showPaywall = false
    @State private var toast: String?

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                if let cal = model.current {
                    content(cal)
                } else {
                    emptyState
                }
                toastView
            }
            .toolbar { toolbar }
            .sheet(item: $editing) { plan in PlanEditorView(plan: plan) }
            .sheet(isPresented: $showNewCalendar) { NewCalendarView() }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .fullScreenCover(item: $revealing) { plan in RevealView(plan: plan) }
            .onAppear(perform: autoReveal)
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { model.reschedule(); autoReveal() }
            }
        }
    }

    // MARK: - Contenido

    private func content(_ cal: AdventCalendar) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                header(cal)
                if let next = cal.nextPlan() {
                    NextPlanCard(plan: next, movieMinutes: cal.movieMinutes) { tap(next) }
                }
                ForEach(cal.months, id: \.title) { month in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(month.title)
                            .font(Theme.serif(20))
                            .tracking(2)
                            .foregroundStyle(Theme.cream)
                            .padding(.horizontal, 18).padding(.vertical, 8)
                            .glassEffect(.regular.tint(Theme.pine.opacity(0.5)))
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(month.plans.filter { !$0.isSpecial }) { plan in door(plan) }
                        }
                        ForEach(month.plans.filter(\.isSpecial)) { plan in door(plan) }
                    }
                }
                Button {
                    editing = MoviePlan(date: suggestedNewDate(cal))
                } label: {
                    Label("Añadir un plan", systemImage: "plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.glass)
                extras
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
    }

    private func door(_ plan: MoviePlan) -> some View {
        DoorView(plan: plan) { tap(plan) }
            .contextMenu {
                Button("Editar plan", systemImage: "pencil") { editing = plan }
                Button("Eliminar", systemImage: "trash", role: .destructive) { model.delete(plan) }
            }
    }

    private func header(_ cal: AdventCalendar) -> some View {
        VStack(spacing: 4) {
            Text(cal.emoji).font(.system(size: 44))
            Text("Calendario de Adviento")
                .font(Theme.serif(18, .semibold))
                .foregroundStyle(Theme.cream.opacity(0.85))
            Text(cal.name)
                .font(Theme.serif(32))
                .foregroundStyle(
                    LinearGradient(colors: [Theme.cream, Theme.gold], startPoint: .top, endPoint: .bottom)
                )
                .multilineTextAlignment(.center)
            Text("\(cal.plans.count) planes · peli a las \(cal.plans.first.map { timeString($0.movieTime(cal.movieMinutes)) } ?? "21:00")")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.cream.opacity(0.7))
        }
        .padding(.top, 8)
    }

    private var extras: some View {
        VStack(spacing: 10) {
            Text("Extra ideal para acompañar")
                .font(Theme.serif(17).italic())
                .foregroundStyle(Theme.gold)
            HStack {
                extra("🍿", "Palomitas")
                extra("☕️", "Chocolate caliente")
                extra("🍪", "Cookies")
            }
            .foregroundStyle(Theme.cream)
        }
        .padding(16)
        .glassCard()
    }

    private func extra(_ emoji: String, _ text: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji).font(.system(size: 32))
            Text(text).font(.caption.weight(.semibold)).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("🎬").font(.system(size: 70))
            Text("Crea tu primer calendario").font(Theme.serif(26)).foregroundStyle(Theme.cream)
            Button("Crear calendario") { showNewCalendar = true }
                .buttonStyle(.glassProminent)
        }
    }

    @ViewBuilder
    private var toastView: some View {
        if let toast {
            VStack {
                Spacer()
                Text(toast)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.cream)
                    .padding(.horizontal, 20).padding(.vertical, 14)
                    .glassEffect()
                    .padding(.bottom, 100)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                ForEach(model.calendars) { cal in
                    Button {
                        model.selectedID = cal.id
                    } label: {
                        if cal.id == model.current?.id {
                            Label("\(cal.emoji) \(cal.name)", systemImage: "checkmark")
                        } else {
                            Text("\(cal.emoji) \(cal.name)")
                        }
                    }
                }
                Divider()
                Button("Nuevo calendario", systemImage: "plus") { newCalendar() }
            } label: {
                Image(systemName: "square.stack.3d.up.fill")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                if let cal = model.current { editing = MoviePlan(date: suggestedNewDate(cal)) }
            } label: {
                Image(systemName: "plus")
            }
        }
    }

    // MARK: - Acciones

    private func newCalendar() {
        if premium.isPremium || model.calendars.count < AppModel.freeCalendarLimit {
            showNewCalendar = true
        } else {
            showPaywall = true
        }
    }

    private func tap(_ plan: MoviePlan) {
        if plan.isEmpty {
            editing = plan
        } else if model.isUnlocked(plan) {
            revealing = plan
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            show("🔒 Se abre el \(plan.dayLabel.lowercased()) · mantén pulsado para editar")
        }
    }

    private func show(_ message: String) {
        withAnimation(.spring) { toast = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { if toast == message { toast = nil } }
        }
    }

    private func autoReveal() {
        guard revealing == nil, let plan = model.todayPlanToReveal() else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if revealing == nil { revealing = plan }
        }
    }

    private func suggestedNewDate(_ cal: AdventCalendar) -> Date {
        let last = cal.sortedPlans.last?.date ?? .now
        let base = max(last, Calendar.current.startOfDay(for: .now))
        return Calendar.current.date(byAdding: .day, value: 1, to: base) ?? .now
    }

    private func timeString(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}

/// Tarjeta del próximo plan con cuenta atrás.
struct NextPlanCard: View {
    let plan: MoviePlan
    let movieMinutes: Int
    let action: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { context in
            let now = context.date
            let prep = plan.prepStart(movieMinutes)
            let movie = plan.movieTime(movieMinutes)
            Button(action: action) {
                HStack(spacing: 14) {
                    Text(plan.isToday(now: now) ? "✨" : "⏳")
                        .font(.system(size: 34))
                    VStack(alignment: .leading, spacing: 4) {
                        Eyebrow(text: plan.isToday(now: now) ? "HOY HAY PLAN" : "PRÓXIMO PLAN · \(plan.dayLabel)")
                        Text(headline(now: now, prep: prep, movie: movie))
                            .font(.headline)
                            .foregroundStyle(Theme.cream)
                        Text(plan.menu == nil ? "Aún no hay menú: toca para elegirlo"
                                              : "Aviso para cocinar a las \(prep.formatted(date: .omitted, time: .shortened))")
                            .font(.subheadline)
                            .foregroundStyle(Theme.cream.opacity(0.75))
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right").foregroundStyle(Theme.gold)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .glassCard(22, tint: Theme.gold.opacity(0.12), interactive: true)
        }
    }

    private func headline(now: Date, prep: Date, movie: Date) -> String {
        if plan.isToday(now: now) {
            if now < prep { return "A cocinar a las \(prep.formatted(date: .omitted, time: .shortened)) · peli a las \(movie.formatted(date: .omitted, time: .shortened))" }
            if now < movie { return "🍳 ¡Toca cocinar! Peli a las \(movie.formatted(date: .omitted, time: .shortened))" }
            return "🍿 ¡A disfrutar de la peli!"
        }
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: now), to: plan.date).day ?? 0
        return days == 1 ? "Mañana se abre una puerta" : "Faltan \(days) días"
    }
}
