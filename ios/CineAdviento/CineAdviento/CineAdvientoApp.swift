import SwiftUI
import UserNotifications

@main
struct CineAdvientoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = PlanStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Muestra el aviso aunque la app esté abierta.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
}

/// Estado de la app: puertas abiertas y ajustes.
final class PlanStore: ObservableObject {
    private let defaults = UserDefaults.standard

    @Published var opened: Set<Int> {
        didSet { defaults.set(Array(opened), forKey: "opened") }
    }
    /// Hora de la peli en minutos desde medianoche (21:00 por defecto).
    @Published var dinnerMinutes: Int {
        didSet { defaults.set(dinnerMinutes, forKey: "dinnerMinutes"); reschedule() }
    }
    @Published var dayBeforeReminder: Bool {
        didSet { defaults.set(dayBeforeReminder, forKey: "dayBefore"); reschedule() }
    }
    @Published var morningReminder: Bool {
        didSet { defaults.set(morningReminder, forKey: "morning"); reschedule() }
    }
    /// Desbloquea todas las puertas para probar la animación.
    @Published var testMode: Bool {
        didSet { defaults.set(testMode, forKey: "testMode") }
    }

    init() {
        opened = Set(defaults.array(forKey: "opened") as? [Int] ?? [])
        dinnerMinutes = defaults.object(forKey: "dinnerMinutes") as? Int ?? 21 * 60
        dayBeforeReminder = defaults.object(forKey: "dayBefore") as? Bool ?? true
        morningReminder = defaults.object(forKey: "morning") as? Bool ?? true
        testMode = defaults.bool(forKey: "testMode")
    }

    func isUnlocked(_ plan: MoviePlan, now: Date = Date()) -> Bool {
        testMode || now >= Calendar.current.startOfDay(for: plan.date)
    }

    func isToday(_ plan: MoviePlan, now: Date = Date()) -> Bool {
        Calendar.current.isDate(plan.date, inSameDayAs: now)
    }

    /// Plan de hoy o el siguiente que viene.
    func nextPlan(now: Date = Date()) -> MoviePlan? {
        let today = Calendar.current.startOfDay(for: now)
        return MoviePlan.all.first { $0.date >= today }
    }

    func todayPlanToReveal(now: Date = Date()) -> MoviePlan? {
        MoviePlan.all.first { isToday($0, now: now) && !opened.contains($0.id) }
    }

    func setUp() async {
        if await NotificationManager.requestPermission() { reschedule() }
    }

    func reschedule() {
        NotificationManager.scheduleAll(dinnerMinutes: dinnerMinutes,
                                        dayBefore: dayBeforeReminder,
                                        morning: morningReminder)
    }

    func timeString(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
