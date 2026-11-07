import Foundation
import UserNotifications

/// Avisos locales: funcionan con la app cerrada y sin internet.
enum NotificationManager {
    /// iOS solo guarda 64 avisos pendientes por app: programamos los más próximos.
    private static let maxPending = 60

    static func requestPermission() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    private struct Item {
        let id: String
        let date: Date
        let title: String
        let body: String
    }

    static func scheduleAll(calendars: [AdventCalendar], dayBefore: Bool, morning: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        let cal = Calendar.current
        let now = Date()
        var items: [Item] = []

        for calendar in calendars {
            for plan in calendar.plans where !plan.isEmpty {
                let key = plan.id.uuidString
                let dayStart = cal.startOfDay(for: plan.date)
                let movieTime = plan.movieTime(calendar.movieMinutes)
                let title = plan.movie?.title ?? "Peli por decidir 🎡"

                if dayBefore {
                    let body = plan.menu.map { "Cena: \($0.name). Revisa que tienes todo." } ?? "Elegid menú y peli para mañana."
                    items.append(Item(id: key + "-daybefore",
                                      date: cal.date(byAdding: .day, value: -1, to: dayStart)!.addingTimeInterval(19 * 3600),
                                      title: "🛒 Mañana hay plan", body: body))
                }
                let morningTime = dayStart.addingTimeInterval(10 * 3600)
                if morning && morningTime < plan.prepStart(calendar.movieMinutes).addingTimeInterval(-1800) {
                    items.append(Item(id: key + "-morning", date: morningTime,
                                      title: "🎬 ¡Hoy se abre una puerta!",
                                      body: "Abre \(calendar.name) para descubrir el plan de esta noche ✨"))
                }
                if let menu = plan.menu {
                    items.append(Item(id: key + "-prep", date: plan.prepStart(calendar.movieMinutes),
                                      title: "⏰ A cocinar: \(menu.emoji) \(menu.prepText) para la peli",
                                      body: "\(menu.name). \(menu.tip)"))
                }
                items.append(Item(id: key + "-movie", date: movieTime,
                                  title: "🍿 ¡Empieza la peli!", body: "\(title). Palomitas y al sofá."))
            }
        }

        for item in items.filter({ $0.date > now }).sorted(by: { $0.date < $1.date }).prefix(maxPending) {
            let content = UNMutableNotificationContent()
            content.title = item.title
            content.body = item.body
            content.sound = .default
            let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: item.date)
            center.add(UNNotificationRequest(identifier: item.id, content: content,
                                             trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)))
        }
    }

    static func sendTest() {
        let content = UNMutableNotificationContent()
        content.title = "✨ Aviso de prueba"
        content.body = "Así te avisaré antes de cada plan."
        content.sound = .default
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "test", content: content,
                                                                     trigger: UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)))
    }
}
