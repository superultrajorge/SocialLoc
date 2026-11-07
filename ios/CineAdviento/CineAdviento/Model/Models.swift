import Foundation

struct Movie: Codable, Hashable, Identifiable {
    var id: String
    var title: String
    var overview: String
    var year: String?
    var posterURL: URL?
    var rating: Double?
    /// Asset local (las ilustraciones del calendario original).
    var artwork: String?
    var emoji: String = "🎬"

    var subtitle: String {
        [year, rating.map { String(format: "★ %.1f", $0) }].compactMap { $0 }.joined(separator: " · ")
    }
}

enum MenuCategory: String, Codable, CaseIterable, Identifiable {
    case comfort = "Comfort food"
    case italiana = "Italiana"
    case texmex = "Tex-Mex"
    case horno = "Al horno"
    case rapida = "Rápida"
    case festiva = "Festiva"
    case propia = "Mis menús"

    var id: String { rawValue }
}

struct DinnerMenu: Codable, Hashable, Identifiable {
    var id: String
    var name: String
    var emoji: String
    var prepMinutes: Int
    var tip: String
    var ingredients: [String]
    var category: MenuCategory

    var prepText: String {
        let h = prepMinutes / 60, m = prepMinutes % 60
        if h == 0 { return "\(m) min" }
        return m == 0 ? "\(h) h" : "\(h) h \(m) min"
    }
}

struct MoviePlan: Codable, Hashable, Identifiable {
    var id = UUID()
    var date: Date
    var movie: Movie?
    var menu: DinnerMenu?
    var artwork: String?
    var isSpecial = false
    var opened = false

    var isEmpty: Bool { movie == nil && menu == nil }

    /// "SÁB 7 NOV"
    var dayLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateFormat = "EEE d MMM"
        return f.string(from: date).replacingOccurrences(of: ".", with: "").uppercased()
    }

    var dayNumber: Int { Calendar.current.component(.day, from: date) }

    func movieTime(_ minutes: Int) -> Date {
        Calendar.current.startOfDay(for: date).addingTimeInterval(TimeInterval(minutes * 60))
    }

    func prepStart(_ minutes: Int) -> Date {
        movieTime(minutes).addingTimeInterval(TimeInterval(-(menu?.prepMinutes ?? 0) * 60))
    }

    func isUnlocked(now: Date = .now) -> Bool {
        now >= Calendar.current.startOfDay(for: date)
    }

    func isToday(now: Date = .now) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: now)
    }
}

struct AdventCalendar: Codable, Hashable, Identifiable {
    var id = UUID()
    var name: String
    var emoji: String
    var movieMinutes: Int = 21 * 60
    var plans: [MoviePlan]

    var sortedPlans: [MoviePlan] { plans.sorted { $0.date < $1.date } }

    /// Agrupa por mes: [("NOVIEMBRE 2026", [planes])]
    var months: [(title: String, plans: [MoviePlan])] {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateFormat = "LLLL yyyy"
        var result: [(title: String, plans: [MoviePlan])] = []
        for plan in sortedPlans {
            let title = f.string(from: plan.date).uppercased()
            if let i = result.firstIndex(where: { $0.title == title }) {
                result[i].plans.append(plan)
            } else {
                result.append((title: title, plans: [plan]))
            }
        }
        return result
    }

    func nextPlan(now: Date = .now) -> MoviePlan? {
        let today = Calendar.current.startOfDay(for: now)
        return sortedPlans.first { $0.date >= today }
    }
}

/// Qué días se generan al crear un calendario.
enum DayPattern: String, CaseIterable, Identifiable {
    case weekends = "Sábados y domingos"
    case saturdays = "Solo sábados"
    case fridaySaturday = "Viernes y sábados"
    case everyDay = "Todos los días"

    var id: String { rawValue }

    /// Weekday de Calendar: 1 = domingo … 7 = sábado
    var weekdays: Set<Int> {
        switch self {
        case .weekends: return [1, 7]
        case .saturdays: return [7]
        case .fridaySaturday: return [6, 7]
        case .everyDay: return [1, 2, 3, 4, 5, 6, 7]
        }
    }

    func dates(from start: Date, to end: Date) -> [Date] {
        let cal = Calendar.current
        var d = cal.startOfDay(for: start)
        let last = cal.startOfDay(for: end)
        var out: [Date] = []
        while d <= last && out.count < 120 {
            if weekdays.contains(cal.component(.weekday, from: d)) { out.append(d) }
            d = cal.date(byAdding: .day, value: 1, to: d)!
        }
        return out
    }
}
