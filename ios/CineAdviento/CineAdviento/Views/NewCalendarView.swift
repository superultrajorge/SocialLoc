import SwiftUI

/// Crear tu propio calendario de adviento.
struct NewCalendarView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    @State private var name = "Nuestro adviento de pelis"
    @State private var emoji = "🎄"
    @State private var start = Date()
    @State private var end = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: .now), month: 12, day: 23)) ?? .now
    @State private var pattern: DayPattern = .weekends
    @State private var christmasEve = true
    @State private var movieTime = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: .now) ?? .now
    @State private var template = false

    private let emojis = ["🎄", "🎅", "❄️", "⭐️", "🍿", "🎬", "❤️", "🧙", "🦌", "☃️"]

    private var dates: [Date] {
        var d = pattern.dates(from: start, to: end)
        if christmasEve, let eve = christmasEveDate, !d.contains(eve) { d.append(eve) }
        return d
    }

    private var christmasEveDate: Date? {
        Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: start), month: 12, day: 24))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nombre", text: $name)
                    Picker("Icono", selection: $emoji) {
                        ForEach(emojis, id: \.self) { Text($0).tag($0) }
                    }
                }

                Section {
                    Toggle("Usar el calendario de ejemplo (Harry Potter + Navidad)", isOn: $template)
                }

                if !template {
                    Section {
                        DatePicker("Desde", selection: $start, displayedComponents: .date)
                        DatePicker("Hasta", selection: $end, in: start..., displayedComponents: .date)
                        Picker("Días", selection: $pattern) {
                            ForEach(DayPattern.allCases) { Text($0.rawValue).tag($0) }
                        }
                        Toggle("Especial Nochebuena (24 dic)", isOn: $christmasEve)
                    } header: {
                        Text("Días de plan")
                    } footer: {
                        Text("Se crearán \(dates.count) puertas. Luego eliges peli y menú en cada una, o dejas que decida la ruleta.")
                    }
                }

                Section("Hora de la peli") {
                    DatePicker("Empieza a las", selection: $movieTime, displayedComponents: .hourAndMinute)
                }
            }
            .environment(\.locale, Locale(identifier: "es_ES"))
            .navigationTitle("Nuevo calendario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar", role: .cancel) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear", action: create)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || (!template && dates.isEmpty))
                }
            }
        }
    }

    private func create() {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: movieTime)
        let minutes = (comps.hour ?? 21) * 60 + (comps.minute ?? 0)
        var cal: AdventCalendar
        if template {
            cal = Catalog.templateCalendar()
        } else {
            let eve = christmasEve ? christmasEveDate : nil
            let plans = dates.sorted().map { MoviePlan(date: $0, isSpecial: $0 == eve) }
            cal = AdventCalendar(name: name, emoji: emoji, plans: plans)
        }
        cal.name = name
        cal.emoji = emoji
        cal.movieMinutes = minutes
        model.addCalendar(cal)
        dismiss()
    }
}
