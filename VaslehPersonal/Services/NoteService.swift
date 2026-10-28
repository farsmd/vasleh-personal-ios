import Foundation

// یادداشت‌ها: خواندن و افزودن.
final class NoteService {
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchNotes() async throws -> [Note] {
        try await client.request("api/v1/notes", method: .get, body: nil)
    }

    func addNote(title: String, body: String) async throws -> Note {
        let requestBody = try APIJSON.encoder.encode(CreateNoteRequest(title: title, body: body))
        return try await client.request("api/v1/notes", method: .post, body: requestBody)
    }
}
