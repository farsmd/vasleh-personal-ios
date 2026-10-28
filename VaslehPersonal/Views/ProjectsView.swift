import SwiftUI

// پروژه‌ها با نوار پیشرفت هر پروژه.
struct ProjectsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var projects: [Project] = []
    @State private var errorMessage: String?

    var body: some View {
        let palette = appState.palette
        ZStack {
            palette.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .trailing, spacing: 14) {
                    Text("پروژه‌ها")
                        .font(.system(size: 22, weight: palette.headingWeight))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    if let message = errorMessage {
                        Text(message)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.red)
                    }
                    if projects.isEmpty && errorMessage == nil {
                        Text("پروژه‌ای ثبت نشده است.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(palette.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    ForEach(projects) { project in
                        VStack(alignment: .trailing, spacing: 8) {
                            HStack {
                                Text(project.title)
                                    .font(.system(size: 15, weight: .bold))
                                Spacer()
                                Text(project.progress.faPercent)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(palette.accent)
                            }
                            ProgressView(value: project.progress)
                                .tint(palette.accent)
                        }
                        .padding()
                        .themedCard(palette: palette)
                    }
                }
                .padding()
            }
        }
        .foregroundStyle(palette.textPrimary)
        .task { await load() }
    }

    private func load() async {
        errorMessage = nil
        do {
            projects = try await appState.projectService.fetchProjects()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "خطای ناشناخته"
        }
    }
}
