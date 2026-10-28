import SwiftUI

// نقطهٔ ورود اپ «مدیریت شخصی وصله» — نسخهٔ iOS
// همهٔ متن‌های کاربر فارسی و چیدمان راست‌به‌چپ است.
@main
struct VaslehPersonalApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoggedIn {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(appState)
            .environment(\.layoutDirection, .rightToLeft)
        }
    }
}
