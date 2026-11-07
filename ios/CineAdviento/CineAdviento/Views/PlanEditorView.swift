import SwiftUI

/// Crear o editar un plan: fecha, peli (TMDB / catálogo / ruleta) y menú.
struct PlanEditorView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var draft: MoviePlan
    @State private var showRoulette = false
    private let isNew: Bool

    init(plan: MoviePlan) {
        _draft = State(initialValue: plan)
        isNew = plan.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Día", selection: $draft.date, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "es_ES"))
                    Toggle("Plan especial (puerta grande)", isOn: $draft.isSpecial)
                }

                Section("Película") {
                    NavigationLink {
                        MoviePickerView(selection: $draft.movie)
                    } label: {
                        if let movie = draft.movie {
                            MovieRow(movie: movie)
                        } else {
                            Label("Elegir película", systemImage: "film")
                        }
                    }
                    Button {
                        showRoulette = true
                    } label: {
                        Label("Que decida la ruleta", systemImage: "dial.medium.fill")
                    }
                }

                Section("Menú") {
                    NavigationLink {
                        MenuPickerView(selection: $draft.menu)
                    } label: {
                        if let menu = draft.menu {
                            MenuRow(menu: menu)
                        } else {
                            Label("Elegir menú", systemImage: "fork.knife")
                        }
                    }
                }

                if !isNew {
                    Section {
                        Button("Eliminar plan", role: .destructive) {
                            model.delete(draft)
                            dismiss()
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppBackground(snow: false))
            .navigationTitle(isNew ? "Nuevo plan" : "Editar plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        draft.date = Calendar.current.startOfDay(for: draft.date)
                        if draft.movie?.artwork == nil { draft.artwork = nil } else { draft.artwork = draft.movie?.artwork }
                        model.save(draft)
                        dismiss()
                    }
                    .disabled(draft.isEmpty)
                }
            }
            .sheet(isPresented: $showRoulette) {
                RouletteView { movie in
                    draft.movie = movie
                    showRoulette = false
                }
            }
        }
    }
}

struct MovieRow: View {
    let movie: Movie
    var body: some View {
        HStack(spacing: 12) {
            PosterView(movie: movie, radius: 8)
                .frame(width: 46, height: 68)
            VStack(alignment: .leading, spacing: 3) {
                Text(movie.title).font(.subheadline.weight(.semibold)).lineLimit(2)
                if !movie.subtitle.isEmpty {
                    Text(movie.subtitle).font(.caption).foregroundStyle(Theme.gold)
                }
                Text(movie.overview).font(.caption).foregroundStyle(.secondary).lineLimit(2)
            }
        }
    }
}

struct MenuRow: View {
    let menu: DinnerMenu
    var body: some View {
        HStack(spacing: 12) {
            Text(menu.emoji).font(.system(size: 34))
            VStack(alignment: .leading, spacing: 3) {
                Text(menu.name).font(.subheadline.weight(.semibold)).lineLimit(2)
                Label(menu.prepText, systemImage: "timer").font(.caption).foregroundStyle(Theme.gold)
            }
        }
    }
}
