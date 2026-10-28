import SwiftUI

// نوار پایین اپ با شش بخش اصلی.
struct MainTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        let palette = appState.palette
        TabView {
            TodayView()
                .tabItem { Label("امروز", systemImage: "house") }
            TodosView()
                .tabItem { Label("کارها", systemImage: "checkmark.circle") }
            CalendarView()
                .tabItem { Label("تقویم", systemImage: "calendar") }
            NotesView()
                .tabItem { Label("یادداشت‌ها", systemImage: "note.text") }
            ProjectsView()
                .tabItem { Label("پروژه‌ها", systemImage: "folder") }
            SettingsView()
                .tabItem { Label("تنظیمات", systemImage: "gearshape") }
        }
        .tint(palette.accent)
    }
}
