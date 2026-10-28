import Foundation

// یک کار در فهرست کارها.
struct Todo: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var done: Bool
    var createdAt: Date
}

// بدنهٔ ساخت کار تازه.
struct CreateTodoRequest: Codable {
    let title: String
}

// بدنهٔ تغییر وضعیت انجام کار.
struct ToggleTodoRequest: Codable {
    let done: Bool
}
