import Foundation

// کلاینت نمونه: همان قرارداد کلاینت واقعی را دارد ولی با دادهٔ نمونهٔ درون‌حافظه‌ای
// جواب می‌دهد، تا اپ بدون سرور هم همهٔ صفحه‌ها را نشان بدهد و تیک زدن و افزودن کار کند.
final class MockAPIClient: APIClientProtocol {
    var token: String?

    private var todos: [Todo] = MockData.sampleTodos()
    private var events: [CalendarEvent] = MockData.sampleEvents()
    private var notes: [Note] = MockData.sampleNotes()
    private var projects: [Project] = MockData.sampleProjects()

    func request<T: Decodable>(_ path: String, method: HTTPMethod, body: Data?) async throws -> T {
        // تأخیر کوتاه برای شبیه‌سازی شبکه.
        try? await Task.sleep(nanoseconds: 300_000_000)

        switch (method, path) {
        case (.post, "api/v1/auth/request-code"):
            // حالت نمونه: هیچ پیامکی واقعاً ارسال نمی‌شود؛ فقط شماره اعتبارسنجی می‌شود.
            let request = try decodeBody(RequestCodeRequest.self, from: body)
            guard AuthService.isValidMobile(request.mobile) else {
                throw APIError.serverError(422)
            }
            return try respond(RequestCodeResponse(ok: true, expiresIn: 300, resendAfter: 60))
        case (.post, "api/v1/auth/verify-code"):
            // حالت نمونه: هر کد ۵ رقمی پذیرفته می‌شود و دادهٔ واقعی کاربر نیست.
            let request = try decodeBody(VerifyCodeRequest.self, from: body)
            guard AuthService.isValidMobile(request.mobile),
                  request.code.count == 5,
                  request.code.allSatisfy({ $0.isNumber }) else {
                throw APIError.unauthorized
            }
            return try respond(AuthResponse(token: "mock-token", user: MockData.sampleUser))
        case (.get, "api/v1/todos"):
            return try respond(todos)
        case (.post, "api/v1/todos"):
            let request = try decodeBody(CreateTodoRequest.self, from: body)
            let todo = Todo(id: UUID(), title: request.title, done: false, createdAt: Date())
            todos.insert(todo, at: 0)
            return try respond(todo)
        case (.get, "api/v1/events"):
            return try respond(events)
        case (.get, "api/v1/notes"):
            return try respond(notes)
        case (.post, "api/v1/notes"):
            let request = try decodeBody(CreateNoteRequest.self, from: body)
            let note = Note(id: UUID(), title: request.title, body: request.body, updatedAt: Date())
            notes.insert(note, at: 0)
            return try respond(note)
        case (.get, "api/v1/projects"):
            return try respond(projects)
        case (.post, "api/v1/pomodoro/sessions"):
            return try respond(OkResponse(ok: true))
        default:
            if method == .patch, path.hasPrefix("api/v1/todos/") {
                let idText = String(path.dropFirst("api/v1/todos/".count))
                guard let id = UUID(uuidString: idText),
                      let index = todos.firstIndex(where: { $0.id == id }) else {
                    throw APIError.serverError(404)
                }
                let request = try decodeBody(ToggleTodoRequest.self, from: body)
                todos[index].done = request.done
                return try respond(todos[index])
            }
            throw APIError.serverError(404)
        }
    }

    func requestVoid(_ path: String, method: HTTPMethod, body: Data?) async throws {
        if method == .delete, path.hasPrefix("api/v1/todos/") {
            let idText = String(path.dropFirst("api/v1/todos/".count))
            if let id = UUID(uuidString: idText) {
                todos.removeAll { $0.id == id }
            }
            return
        }
        throw APIError.serverError(404)
    }

    private func decodeBody<U: Decodable>(_ type: U.Type, from body: Data?) throws -> U {
        guard let body = body else {
            throw APIError.decoding
        }
        do {
            return try APIJSON.decoder.decode(U.self, from: body)
        } catch {
            throw APIError.decoding
        }
    }

    private func respond<T: Decodable, U: Encodable>(_ value: U) throws -> T {
        let data = try APIJSON.encoder.encode(value)
        do {
            return try APIJSON.decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }
}
