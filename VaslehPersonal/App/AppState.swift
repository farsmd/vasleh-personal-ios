import Foundation
import SwiftUI

// وضعیت سراسری اپ: ورود، توکن، تم انتخاب‌شده و تنظیمات کاربر.
// تنظیمات در UserDefaults ذخیره می‌شوند؛ توکن فقط در Keychain است.
final class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var token: String?

    @Published var displayName: String = "" {
        didSet { UserDefaults.standard.set(displayName, forKey: "displayName") }
    }

    @Published var selectedTheme: AppTheme = .darkPrism {
        didSet { UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme") }
    }

    @Published var focusMinutes: Int = 25 {
        didSet { UserDefaults.standard.set(focusMinutes, forKey: "focusMinutes") }
    }

    @Published var breakMinutes: Int = 5 {
        didSet { UserDefaults.standard.set(breakMinutes, forKey: "breakMinutes") }
    }

    // یک پرچم برای جابه‌جایی بین دادهٔ نمونه و API واقعی.
    // پیش‌فرض روشن است تا اپ بدون سرور هم همهٔ صفحه‌ها را نشان بدهد.
    @Published var useMockAPI: Bool = true {
        didSet { UserDefaults.standard.set(useMockAPI, forKey: "useMockAPI") }
    }

    private let liveClient = APIClient()
    private let mockClient = MockAPIClient()

    var apiClient: APIClientProtocol { useMockAPI ? mockClient : liveClient }

    var authService: AuthService { AuthService(client: apiClient) }
    var todoService: TodoService { TodoService(client: apiClient) }
    var eventService: EventService { EventService(client: apiClient) }
    var noteService: NoteService { NoteService(client: apiClient) }
    var projectService: ProjectService { ProjectService(client: apiClient) }
    var pomodoroService: PomodoroService { PomodoroService(client: apiClient) }

    var palette: ThemePalette { selectedTheme.palette }

    init() {
        let defaults = UserDefaults.standard
        if let savedTheme = defaults.string(forKey: "selectedTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            selectedTheme = theme
        }
        displayName = defaults.string(forKey: "displayName") ?? ""
        focusMinutes = defaults.object(forKey: "focusMinutes") as? Int ?? 25
        breakMinutes = defaults.object(forKey: "breakMinutes") as? Int ?? 5
        useMockAPI = defaults.object(forKey: "useMockAPI") as? Bool ?? true

        if let savedToken = KeychainHelper.loadToken(), !savedToken.isEmpty {
            token = savedToken
            liveClient.token = savedToken
            mockClient.token = savedToken
            isLoggedIn = true
        }
    }

    func signIn(token: String, user: User) {
        self.token = token
        liveClient.token = token
        mockClient.token = token
        displayName = user.name
        KeychainHelper.saveToken(token)
        isLoggedIn = true
    }

    func signOut() {
        token = nil
        liveClient.token = nil
        mockClient.token = nil
        KeychainHelper.deleteToken()
        isLoggedIn = false
    }
}
