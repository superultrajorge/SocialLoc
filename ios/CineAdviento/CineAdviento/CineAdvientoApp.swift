import SwiftUI
import UserNotifications

@main
struct CineAdvientoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var model = AppModel()
    @State private var premium = PremiumStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .environment(premium)
                .preferredColorScheme(.dark)
                .tint(Theme.gold)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
}

struct RootView: View {
    @Environment(AppModel.self) private var model
    @Environment(PremiumStore.self) private var premium

    var body: some View {
        TabView {
            Tab("Calendario", systemImage: "calendar") { CalendarHomeView() }
            Tab("Ruleta", systemImage: "dial.medium.fill") { RouletteView() }
            Tab("Menús", systemImage: "fork.knife") {
                NavigationStack { MenuPickerView(selection: nil) }
            }
            Tab("Ajustes", systemImage: "gearshape.fill") { SettingsView() }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .task {
            if await NotificationManager.requestPermission() { model.reschedule() }
            await premium.load()
        }
    }
}
