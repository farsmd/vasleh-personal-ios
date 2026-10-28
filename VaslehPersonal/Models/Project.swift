import Foundation

// یک پروژه با درصد پیشرفت بین ۰ تا ۱.
struct Project: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var progress: Double
}
