import Foundation

// ثبت نوبت‌های پومودورو برای همگام‌سازی با سرور.
final class PomodoroService {
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func logSession(durationMinutes: Int) async throws {
        let body = try APIJSON.encoder.encode(
            PomodoroSessionRequest(durationMinutes: durationMinutes, completedAt: Date())
        )
        let response: OkResponse = try await client.request("api/v1/pomodoro/sessions", method: .post, body: body)
        guard response.ok else {
            throw APIError.serverError(500)
        }
    }
}
