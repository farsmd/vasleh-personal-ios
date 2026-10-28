import Foundation

// پروژه‌ها با درصد پیشرفت.
final class ProjectService {
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchProjects() async throws -> [Project] {
        try await client.request("api/v1/projects", method: .get, body: nil)
    }
}
