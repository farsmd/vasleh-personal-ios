import SwiftUI

// یادداشت‌ها: فهرست و افزودن یادداشت تازه.
struct NotesView: View {
    @EnvironmentObject private var appState: AppState
    @State private var notes: [Note] = []
    @State private var newTitle = ""
    @State private var newBody = ""
    @State private var errorMessage: String?

    var body: some View {
        let palette = appState.palette
        ZStack {
            palette.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .trailing, spacing: 14) {
                    Text("یادداشت‌ها")
                        .font(.system(size: 22, weight: palette.headingWeight))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    VStack(alignment: .trailing, spacing: 10) {
                        TextField("عنوان یادداشت...", text: $newTitle)
                            .padding()
                            .background(palette.surfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                        TextEditor(text: $newBody)
                            .frame(height: 80)
                            .padding(8)
                            .background(palette.surfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                        Button("افزودن یادداشت") { addNote() }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(palette.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                            .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding()
                    .themedCard(palette: palette)
                    if let message = errorMessage {
                        Text(message)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.red)
                    }
                    ForEach(notes) { note in
                        VStack(alignment: .trailing, spacing: 6) {
                            Text(note.title)
                                .font(.system(size: 15, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            Text(note.body)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(palette.textSecondary)
                                .lineLimit(3)
                                .frame(maxWidth: .infinity, alignment: .trailing)
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
            notes = try await appState.noteService.fetchNotes()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "خطای ناشناخته"
        }
    }

    private func addNote() {
        let title = newTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        let body = newBody
        newTitle = ""
        newBody = ""
        Task {
            do {
                let created = try await appState.noteService.addNote(title: title, body: body)
                notes.insert(created, at: 0)
            } catch {
                errorMessage = (error as? APIError)?.errorDescription ?? "خطای ناشناخته"
            }
        }
    }
}
