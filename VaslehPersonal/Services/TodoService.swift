import Foundation

// کارها: خواندن، افزودن، تغییر وضعیت انجام و حذف.
final class TodoService {
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func fetchTodos() async throws -> [Todo] {
        try await client.request("api/v1/todos", method: .get, body: nil)
    }

    func addTodo(title: String) async throws -> Todo {
        let body = try APIJSON.encoder.encode(CreateTodoRequest(title: title))
        return try await client.request("api/v1/todos", method: .post, body: body)
    }

    func setDone(_ todo: Todo, done: Bool) async throws -> Todo {
        let body = try APIJSON.encoder.encode(ToggleTodoRequest(done: done))
        return try await client.request("api/v1/todos/\(todo.id.uuidString)", method: .patch, body: body)
    }

    func deleteTodo(_ todo: Todo) async throws {
        try await client.requestVoid("api/v1/todos/\(todo.id.uuidString)", method: .delete, body: nil)
    }
}
