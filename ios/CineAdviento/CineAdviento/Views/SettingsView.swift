import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @Environment(PremiumStore.self) private var premium
    @State private var showPaywall = false
    @State private var confirmDelete = false

    private var movieTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.startOfDay(for: .now)
                    .addingTimeInterval(TimeInterval((model.current?.movieMinutes ?? 21 * 60) * 60))
            },
            set: { date in
                let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                model.setMovieMinutes((c.hour ?? 21) * 60 + (c.minute ?? 0))
            }
        )
    }

    var body: some View {
        @Bindable var model = model
        NavigationStack {
            Form {
                Section {
                    Button { showPaywall = true } label: {
                        HStack(spacing: 14) {
                            Text("👑").font(.system(size: 34))
                            VStack(alignment: .leading) {
                                Text(premium.isPremium ? "Premium activo" : "CineAdviento Premium")
                                    .font(.headline).foregroundStyle(Theme.cream)
                                Text(premium.isPremium ? "Gracias por apoyar la app ❤️" : "Calendarios y ruleta ilimitados")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(Theme.gold)
                        }
                    }
                }

                if let cal = model.current {
                    Section {
                        DatePicker("Hora de la peli", selection: movieTime, displayedComponents: .hourAndMinute)
                        Toggle("Aviso la tarde anterior (19:00)", isOn: $model.dayBeforeReminder)
                        Toggle("Aviso por la mañana (10:00)", isOn: $model.morningReminder)
                        Button("Enviar aviso de prueba (5 s)") { NotificationManager.sendTest() }
                    } header: {
                        Text("Avisos · \(cal.name)")
                    } footer: {
                        Text("Cada día de plan te aviso cuando toca empezar a cocinar, según lo que tarda el menú elegido.")
                    }

                    Section("Cuándo empezar a cocinar") {
                        ForEach(cal.sortedPlans.filter { $0.menu != nil }) { plan in
                            HStack {
                                Text(plan.menu?.emoji ?? "🍽️")
                                VStack(alignment: .leading) {
                                    Text(plan.dayLabel).font(.caption.weight(.bold))
                                    Text(plan.movie?.title ?? "Peli por decidir").font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                                }
                                Spacer()
                                Text(plan.prepStart(cal.movieMinutes).formatted(date: .omitted, time: .shortened))
                                    .monospacedDigit().foregroundStyle(Theme.gold)
                            }
                        }
                    }
                }

                Section {
                    SecureField("API Key o Read Access Token", text: $model.tmdbKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Link("Conseguir una clave gratis en themoviedb.org",
                         destination: URL(string: "https://www.themoviedb.org/settings/api")!)
                } header: {
                    Text("Buscador de películas (TMDB)")
                } footer: {
                    Text("Este producto usa la API de TMDB, pero no está avalado ni certificado por TMDB.")
                }

                Section {
                    Toggle("Modo prueba: abrir todas las puertas", isOn: $model.testMode)
                    Button("Volver a cerrar todas las puertas") { model.closeAllDoors() }
                    if model.calendars.count > 1 {
                        Button("Eliminar este calendario", role: .destructive) { confirmDelete = true }
                    }
                } header: {
                    Text("Pruebas")
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppBackground(snow: false))
            .navigationTitle("Ajustes")
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .confirmationDialog("¿Eliminar \(model.current?.name ?? "")?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Eliminar", role: .destructive) {
                    if let id = model.current?.id { model.deleteCalendar(id) }
                }
            }
        }
    }
}
