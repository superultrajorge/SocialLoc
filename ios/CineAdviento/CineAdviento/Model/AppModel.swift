import Foundation
import Observation

/// Estado de la app y guardado en disco (JSON en Documents).
@MainActor
@Observable
final class AppModel {
    static let freeCalendarLimit = 2
    static let freeRouletteLimit = 6

    var calendars: [AdventCalendar] { didSet { save(); reschedule() } }
    var rouletteMovies: [Movie] { didSet { save() } }
    var customMenus: [DinnerMenu] { didSet { save() } }

    var selectedID: UUID? {
        didSet { UserDefaults.standard.set(selectedID?.uuidString, forKey: "selectedCalendar") }
    }
    var dayBeforeReminder: Bool {
        didSet { UserDefaults.standard.set(dayBeforeReminder, forKey: "dayBefore"); reschedule() }
    }
    var morningReminder: Bool {
        didSet { UserDefaults.standard.set(morningReminder, forKey: "morning"); reschedule() }
    }
    /// Abre todas las puertas para probar la animación.
    var testMode: Bool {
        didSet { UserDefaults.standard.set(testMode, forKey: "testMode") }
    }
    var tmdbKey: String {
        didSet { UserDefaults.standard.set(tmdbKey, forKey: "tmdbKey") }
    }

    private struct Saved: Codable {
        var calendars: [AdventCalendar]
        var rouletteMovies: [Movie]
        var customMenus: [DinnerMenu]
    }

    private static var fileURL: URL {
        URL.documentsDirectory.appending(path: "cineadviento.json")
    }

    init() {
        let d = UserDefaults.standard
        let saved = (try? Data(contentsOf: Self.fileURL)).flatMap { try? JSONDecoder().decode(Saved.self, from: $0) }
        let cals = saved?.calendars ?? [Catalog.templateCalendar()]
        calendars = cals
        rouletteMovies = saved?.rouletteMovies ?? Array(Catalog.movies.suffix(7))
        customMenus = saved?.customMenus ?? []
        selectedID = d.string(forKey: "selectedCalendar").flatMap(UUID.init(uuidString:)) ?? cals.first?.id
        dayBeforeReminder = d.object(forKey: "dayBefore") as? Bool ?? true
        morningReminder = d.object(forKey: "morning") as? Bool ?? true
        testMode = d.bool(forKey: "testMode")
        tmdbKey = d.string(forKey: "tmdbKey") ?? Secrets.tmdbKey
    }

    // MARK: - Lectura

    var current: AdventCalendar? {
        calendars.first { $0.id == selectedID } ?? calendars.first
    }

    var allMenus: [DinnerMenu] { customMenus + Catalog.menus }

    var hasTMDB: Bool { !tmdbKey.trimmingCharacters(in: .whitespaces).isEmpty }

    func isUnlocked(_ plan: MoviePlan) -> Bool { testMode || plan.isUnlocked() }

    func todayPlanToReveal() -> MoviePlan? {
        current?.plans.first { $0.isToday() && !$0.opened && !$0.isEmpty }
    }

    // MARK: - Escritura

    func addCalendar(_ cal: AdventCalendar) {
        calendars.append(cal)
        selectedID = cal.id
    }

    func deleteCalendar(_ id: UUID) {
        calendars.removeAll { $0.id == id }
        if selectedID == id { selectedID = calendars.first?.id }
    }

    func updateCalendar(_ cal: AdventCalendar) {
        guard let i = calendars.firstIndex(where: { $0.id == cal.id }) else { return }
        calendars[i] = cal
    }

    func setMovieMinutes(_ minutes: Int) {
        guard let i = calendars.firstIndex(where: { $0.id == current?.id }) else { return }
        calendars[i].movieMinutes = minutes
    }

    func save(_ plan: MoviePlan) {
        guard let c = calendars.firstIndex(where: { $0.id == current?.id }) else { return }
        if let p = calendars[c].plans.firstIndex(where: { $0.id == plan.id }) {
            calendars[c].plans[p] = plan
        } else {
            calendars[c].plans.append(plan)
        }
    }

    func delete(_ plan: MoviePlan) {
        guard let c = calendars.firstIndex(where: { $0.id == current?.id }) else { return }
        calendars[c].plans.removeAll { $0.id == plan.id }
    }

    func markOpened(_ plan: MoviePlan) {
        var p = plan
        p.opened = true
        save(p)
    }

    func closeAllDoors() {
        guard let c = calendars.firstIndex(where: { $0.id == current?.id }) else { return }
        for i in calendars[c].plans.indices { calendars[c].plans[i].opened = false }
    }

    /// Asigna una peli al siguiente plan que no tenga película.
    @discardableResult
    func assignToNextFreePlan(_ movie: Movie) -> MoviePlan? {
        guard var plan = current?.sortedPlans.first(where: { $0.movie == nil && $0.date >= Calendar.current.startOfDay(for: .now) }) else { return nil }
        plan.movie = movie
        save(plan)
        return plan
    }

    func toggleRoulette(_ movie: Movie) {
        if let i = rouletteMovies.firstIndex(where: { $0.id == movie.id }) {
            rouletteMovies.remove(at: i)
        } else {
            rouletteMovies.append(movie)
        }
    }

    // MARK: - Disco y avisos

    private func save() {
        let saved = Saved(calendars: calendars, rouletteMovies: rouletteMovies, customMenus: customMenus)
        if let data = try? JSONEncoder().encode(saved) {
            try? data.write(to: Self.fileURL, options: .atomic)
        }
    }

    func reschedule() {
        NotificationManager.scheduleAll(calendars: calendars, dayBefore: dayBeforeReminder, morning: morningReminder)
    }
}
