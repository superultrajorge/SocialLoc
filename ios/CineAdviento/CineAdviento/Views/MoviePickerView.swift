import SwiftUI

/// Buscador de pelis: TMDB (si hay clave) + catálogo incluido.
struct MoviePickerView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    /// nil = modo "añadir a la ruleta".
    var selection: Binding<Movie?>?

    @State private var query = ""
    @State private var results: [Movie] = []
    @State private var popular: [Movie] = []
    @State private var loading = false
    @State private var error: String?

    private var localMatches: [Movie] {
        guard !query.isEmpty else { return Catalog.movies }
        return Catalog.movies.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        List {
            if !model.hasTMDB {
                Section {
                    Label("Añade tu clave gratuita de TMDB en Ajustes para buscar cualquier película con su póster y sinopsis.",
                          systemImage: "key.fill")
                        .font(.footnote)
                }
            }
            if let error {
                Section { Label(error, systemImage: "exclamationmark.triangle.fill").font(.footnote) }
            }
            if !results.isEmpty {
                Section("Resultados") { ForEach(results) { row($0) } }
            } else if query.isEmpty && !popular.isEmpty {
                Section("Populares en Navidad") { ForEach(popular) { row($0) } }
            }
            if !localMatches.isEmpty {
                Section("Catálogo navideño") { ForEach(localMatches) { row($0) } }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppBackground(snow: false))
        .navigationTitle("Películas")
        .searchable(text: $query, prompt: "Buscar película")
        .overlay { if loading { ProgressView().controlSize(.large) } }
        .task(id: query) { await search() }
        .task { await loadPopular() }
    }

    private func row(_ movie: Movie) -> some View {
        HStack {
            Button {
                if let selection {
                    selection.wrappedValue = movie
                    dismiss()
                } else {
                    model.toggleRoulette(movie)
                }
            } label: {
                MovieRow(movie: movie)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                model.toggleRoulette(movie)
            } label: {
                Image(systemName: model.rouletteMovies.contains(where: { $0.id == movie.id }) ? "dial.medium.fill" : "dial.medium")
                    .foregroundStyle(Theme.gold)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Añadir a la ruleta")
        }
        .listRowBackground(Color.white.opacity(0.06))
    }

    private func search() async {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard model.hasTMDB, q.count >= 2 else { results = []; return }
        try? await Task.sleep(for: .milliseconds(350)) // espera a que acabes de escribir
        guard !Task.isCancelled else { return }
        loading = true
        defer { loading = false }
        do {
            results = try await TMDBService(key: model.tmdbKey).search(q)
            error = nil
        } catch is CancellationError {
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func loadPopular() async {
        guard model.hasTMDB, popular.isEmpty else { return }
        popular = (try? await TMDBService(key: model.tmdbKey).christmasPopular()) ?? []
    }
}
