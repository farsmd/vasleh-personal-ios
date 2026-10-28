import Foundation

// رویدادهای تقویم.
final class EventService {
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchEvents() async throws -> [CalendarEvent] {
        try await client.request("api/v1/events", method: .get, body: nil)
    }
}
