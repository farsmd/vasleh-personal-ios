import SwiftUI

// زبانهٔ امروز: سلام و تاریخ جلالی، پیشرفت روز، تایمر تمرکز و کارهای امروز.
struct TodayView: View {
    @EnvironmentObject private var appState: AppState
    @State private var todos: [Todo] = []
    @State private var isLoading = false
    @State private var loadError: String?

    var body: some View {
        let palette = appState.palette
        ZStack {
            palette.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .trailing, spacing: 16) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("سلام، \(appState.displayName)")
                            .font(.system(size: 22, weight: palette.headingWeight))
                        Text(todayLine)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(palette.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    progressCard(palette: palette)
                    PomodoroView()
                    todayTasksCard(palette: palette)
                }
                .padding()
            }
        }
        .foregroundStyle(palette.textPrimary)
        .task { await load() }
    }

    private var todayLine: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fa_IR")
        formatter.calendar = Calendar(identifier: .persian)
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: Date())
    }

    private var doneCount: Int { todos.filter { $0.done }.count }

    private var progress: Double {
        todos.isEmpty ? 0 : Double(doneCount) / Double(todos.count)
    }

    private func progressCard(palette: ThemePalette) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text("پیشرفت امروز")
                .font(.system(size: 15, weight: palette.headingWeight))
            HStack {
                Text("\(doneCount.faDigits) از \(todos.count.faDigits) کار")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
                Spacer()
                Text(progress.faPercent)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(palette.accent)
            }
            ProgressView(value: progress)
                .tint(palette.accent)
        }
        .padding()
        .themedCard(palette: palette)
    }

    private func todayTasksCard(palette: ThemePalette) -> some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text("کارهای امروز")
                .font(.system(size: 15, weight: palette.headingWeight))
            if isLoading {
                ProgressView()
            } else if let message = loadError {
                Text(message)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.red)
            } else if todos.isEmpty {
                Text("کاری برای امروز ثبت نشده است.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
            } else {
                ForEach(todos.prefix(5)) { todo in
                    HStack {
                        Image(systemName: todo.done ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(todo.done ? palette.accent : palette.textSecondary)
                        Text(todo.title)
                            .font(.system(size: 14, weight: .regular))
                            .strikethrough(todo.done)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .themedCard(palette: palette)
    }

    private func load() async {
        isLoading = true
        loadError = nil
        do {
            todos = try await appState.todoService.fetchTodos()
        } catch {
            loadError = (error as? APIError)?.errorDescription ?? "خطای ناشناخته"
        }
        isLoading = false
    }
}
