import Foundation

// روش‌های HTTP مورد استفادهٔ اپ.
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}

// خطاهای شبکه با پیام فارسی برای نمایش به کاربر.
enum APIError: Error, LocalizedError {
    case invalidURL
    case noResponse
    case unauthorized
    case serverError(Int)
    case decoding
    case network

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "نشانی سرویس نامعتبر است."
        case .noResponse:
            return "پاسخی از سرور دریافت نشد."
        case .unauthorized:
            return "کد تایید اشتباه یا منقضی شده است."
        case .serverError(let code):
            return "خطای سرور (\(code.faDigits))."
        case .decoding:
            return "پاسخ سرور قابل خواندن نبود."
        case .network:
            return "به اینترنت متصل نیستید."
        }
    }
}

// پیکربندی API در یک جا: برای عوض کردن نشانی سرور فقط همین‌جا را عوض کن.
struct APIConfig {
    static var baseURL = URL(string: "https://atroweb.ir")!
}

// رمزگذار و رمزگشای مشترک همهٔ سرویس‌ها (کلیدهای snake_case و تاریخ ISO8601).
enum APIJSON {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

// قرارداد کلاینت API: هم کلاینت واقعی و هم کلاینت نمونه همین را پیاده می‌کنند.
protocol APIClientProtocol: AnyObject {
    var token: String? { get set }
    func request<T: Decodable>(_ path: String, method: HTTPMethod, body: Data?) async throws -> T
    func requestVoid(_ path: String, method: HTTPMethod, body: Data?) async throws
}

// کلاینت واقعی: URLSession با هدر Authorization Bearer.
final class APIClient: APIClientProtocol {
    var token: String?
    private let session = URLSession.shared

    func request<T: Decodable>(_ path: String, method: HTTPMethod, body: Data?) async throws -> T {
        let (data, response) = try await perform(path: path, method: method, body: body)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.noResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 {
                throw APIError.unauthorized
            }
            throw APIError.serverError(http.statusCode)
        }
        do {
            return try APIJSON.decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }

    func requestVoid(_ path: String, method: HTTPMethod, body: Data?) async throws {
        let (_, response) = try await perform(path: path, method: method, body: body)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.noResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 {
                throw APIError.unauthorized
            }
            throw APIError.serverError(http.statusCode)
        }
    }

    private func perform(path: String, method: HTTPMethod, body: Data?) async throws -> (Data, URLResponse) {
        let url = APIConfig.baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let savedToken = token {
            request.setValue("Bearer \(savedToken)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body
        do {
            return try await session.data(for: request)
        } catch {
            throw APIError.network
        }
    }
}
