import Foundation

// یک یادداشت.
struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var body: String
    var updatedAt: Date
}

// بدنهٔ ساخت یادداشت تازه.
struct CreateNoteRequest: Codable {
    let title: String
    let body: String
}
