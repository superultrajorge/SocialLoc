import Foundation
import UserNotifications

/// Programa los avisos locales. No necesita internet ni servidor:
/// el iPhone los lanza aunque la app esté cerrada.
enum NotificationManager {
    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func scheduleAll(dinnerMinutes: Int, dayBefore: Bool, morning: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        let cal = Calendar.current
        let now = Date()

        for plan in MoviePlan.all {
            let dayStart = cal.startOfDay(for: plan.date)
            let movie = plan.movieTime(dinnerMinutes: dinnerMinutes)
            let prep = plan.prepStart(dinnerMinutes: dinnerMinutes)

            if dayBefore {
                add(id: "\(plan.id)-daybefore",
                    at: cal.date(byAdding: .day, value: -1, to: dayStart)!.addingTimeInterval(19 * 3600),
                    title: "🛒 Mañana: \(plan.title)",
                    body: "Cena: \(plan.food). Revisa que tienes todo para mañana.",
                    now: now)
            }
            let morningTime = dayStart.addingTimeInterval(10 * 3600)
            if morning && morningTime < prep.addingTimeInterval(-30 * 60) {
                add(id: "\(plan.id)-morning", at: morningTime,
                    title: "🎬 ¡Hoy se abre una puerta del calendario!",
                    body: "Abre la app para descubrir el plan de esta noche ✨",
                    now: now)
            }
            add(id: "\(plan.id)-prep", at: prep,
                title: "⏰ Hora de cocinar: \(plan.emoji) \(plan.prepText) para la peli",
                body: "\(plan.food). \(plan.prepTip)",
                now: now)
            add(id: "\(plan.id)-movie", at: movie,
                title: "🍿 ¡Empieza la peli!",
                body: "\(plan.title). Palomitas, chocolate caliente y al sofá.",
                now: now)
        }
    }

    static func sendTest() {
        let content = UNMutableNotificationContent()
        content.title = "✨ Aviso de prueba"
        content.body = "Así te avisaré antes de cada plan."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "test", content: content, trigger: trigger))
    }

    private static func add(id: String, at date: Date, title: String, body: String, now: Date) {
        guard date > now else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}
