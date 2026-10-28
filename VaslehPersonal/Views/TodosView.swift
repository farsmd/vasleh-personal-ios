import SwiftUI

// فهرست کارها: تیک زدن، افزودن و حذف.
struct TodosView: View {
    @EnvironmentObject private var appState: AppState
    @State private var todos: [Todo] = []
    @State private var newTitle = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        let palette = appState.palette
        ZStack {
            palette.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .trailing, spacing: 14) {
                    Text("کارها")
                        .font(.system(size: 22, weight: palette.headingWeight))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    HStack {
                        TextField("کار تازه...", text: $newTitle)
                            .padding()
                            .background(palette.surface)
                            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                        Button("افزودن") { addTodo() }
                            .padding()
                            .background(palette.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                            .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    if isLoading {
                        ProgressView()
                    }
                    if let message = errorMessage {
                        Text(message)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.red)
                    }
                    ForEach(todos) { todo in
                        HStack {
                            Button(action: { toggle(todo) }) {
                                Image(systemName: todo.done ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(todo.done ? palette.accent : palette.textSecondary)
                            }
                            Text(todo.title)
                                .font(.system(size: 15, weight: .regular))
                                .strikethrough(todo.done)
                            Spacer()
                            Button(action: { delete(todo) }) {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
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
        isLoading = true
        errorMessage = nil
        do {
            todos = try await appState.todoService.fetchTodos()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "خطای ناشناخته"
        }
        isLoading = false
    }

    private func addTodo() {
        let title = newTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        newTitle = ""
        Task {
            do {
                let created = try await appState.todoService.addTodo(title: title)
                todos.insert(created, at: 0)
            } catch {
                errorMessage = (error as? APIError)?.errorDescription ?? "خطای ناشناخته"
            }
        }
    }

    private func toggle(_ todo: Todo) {
        Task {
            do {
                let updated = try await appState.todoService.setDone(todo, done: !todo.done)
                if let index = todos.firstIndex(where: { $0.id == todo.id }) {
                    todos[index] = updated
                }
            } catch {
                errorMessage = (error as? APIError)?.errorDescription ?? "خطای ناشناخته"
            }
        }
    }

    private func delete(_ todo: Todo) {
        Task {
            do {
                try await appState.todoService.deleteTodo(todo)
                todos.removeAll { $0.id == todo.id }
            } catch {
                errorMessage = (error as? APIError)?.errorDescription ?? "خطای ناشناخته"
            }
        }
    }
}
