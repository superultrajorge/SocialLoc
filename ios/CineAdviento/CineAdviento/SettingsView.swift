import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: PlanStore
    @Environment(\.dismiss) private var dismiss

    private var movieTime: Binding<Date> {
        Binding(
            get: { Calendar.current.startOfDay(for: Date()).addingTimeInterval(TimeInterval(store.dinnerMinutes * 60)) },
            set: { date in
                let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                store.dinnerMinutes = (c.hour ?? 21) * 60 + (c.minute ?? 0)
            }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Hora de la peli", selection: movieTime, displayedComponents: .hourAndMinute)
                    Toggle("Aviso la tarde anterior (19:00) para la compra", isOn: $store.dayBeforeReminder)
                    Toggle("Aviso por la mañana (10:00)", isOn: $store.morningReminder)
                    Button("Enviar aviso de prueba (5 s)") { NotificationManager.sendTest() }
                } header: {
                    Text("Avisos")
                } footer: {
                    Text("Además, cada día de plan te aviso cuando toca empezar a cocinar, según lo que tarda cada receta.")
                }

                Section("Cuándo empezar a cocinar") {
                    ForEach(MoviePlan.all) { plan in
                        HStack {
                            Text(plan.emoji)
                            VStack(alignment: .leading) {
                                Text(plan.dayLabel).font(.caption.weight(.bold))
                                Text(plan.title).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                            }
                            Spacer()
                            Text(store.timeString(plan.prepStart(dinnerMinutes: store.dinnerMinutes)))
                                .monospacedDigit()
                                .foregroundStyle(Theme.gold)
                        }
                    }
                }

                Section {
                    Toggle("Modo prueba: abrir todas las puertas", isOn: $store.testMode)
                    Button("Volver a cerrar todas las puertas", role: .destructive) { store.opened = [] }
                } header: {
                    Text("Pruebas")
                } footer: {
                    Text("Útil para ver la animación antes de tiempo. Desactívalo para no destripar las sorpresas.")
                }
            }
            .navigationTitle("Ajustes")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Listo") { dismiss() } }
            }
        }
    }
}
