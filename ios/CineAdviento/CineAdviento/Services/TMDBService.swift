import Foundation

/// Búsqueda de películas en TMDB (títulos y sinopsis en español + pósters).
struct TMDBService {
    let key: String

    enum TMDBError: LocalizedError {
        case badKey, http(Int)
        var errorDescription: String? {
            switch self {
            case .badKey: return "La clave de TMDB no es válida. Revísala en Ajustes."
            case .http(let code): return "TMDB respondió con error \(code)."
            }
        }
    }

    private struct SearchResponse: Decodable { let results: [Result] }
    private struct Result: Decodable {
        let id: Int
        let title: String
        let overview: String?
        let release_date: String?
        let poster_path: String?
        let vote_average: Double?
    }

    func search(_ query: String) async throws -> [Movie] {
        try await fetch(path: "/3/search/movie", params: ["query": query, "include_adult": "false"])
    }

    /// Pelis navideñas populares (palabra clave "christmas" de TMDB).
    func christmasPopular() async throws -> [Movie] {
        try await fetch(path: "/3/discover/movie", params: ["with_keywords": "207317", "sort_by": "popularity.desc"])
    }

    private func fetch(path: String, params: [String: String]) async throws -> [Movie] {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let isToken = trimmed.count > 40
        var comps = URLComponents(string: "https://api.themoviedb.org" + path)!
        var items = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        items.append(URLQueryItem(name: "language", value: "es-ES"))
        if !isToken { items.append(URLQueryItem(name: "api_key", value: trimmed)) }
        comps.queryItems = items

        var request = URLRequest(url: comps.url!)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        if isToken { request.setValue("Bearer \(trimmed)", forHTTPHeaderField: "Authorization") }

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw http.statusCode == 401 ? TMDBError.badKey : TMDBError.http(http.statusCode)
        }
        let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
        return decoded.results.map { r in
            Movie(id: "tmdb-\(r.id)",
                  title: r.title,
                  overview: (r.overview?.isEmpty == false) ? r.overview! : "Sin sinopsis en español.",
                  year: r.release_date.flatMap { $0.count >= 4 ? String($0.prefix(4)) : nil },
                  posterURL: r.poster_path.flatMap { URL(string: "https://image.tmdb.org/t/p/w500\($0)") },
                  rating: r.vote_average.flatMap { $0 > 0 ? $0 : nil })
        }
    }
}
