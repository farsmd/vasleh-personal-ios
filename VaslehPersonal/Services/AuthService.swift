import Foundation

// ورود با موبایل + کد پیامکی، در دو مرحله:
// ۱) requestCode: شماره را می‌فرستد تا سرور کد بفرستد.
// ۲) verifyCode: شماره + کد را می‌فرستد و توکن Bearer را پس می‌گیرد.
// هیچ رمزی در اپ ذخیره نمی‌شود؛ توکن فقط در Keychain می‌ماند.
final class AuthService {
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func requestCode(mobile: String) async throws -> RequestCodeResponse {
        let body = try APIJSON.encoder.encode(RequestCodeRequest(mobile: mobile))
        return try await client.request("api/v1/auth/request-code", method: .post, body: body)
    }

    func verifyCode(mobile: String, code: String) async throws -> AuthResponse {
        let body = try APIJSON.encoder.encode(VerifyCodeRequest(mobile: mobile, code: code))
        return try await client.request("api/v1/auth/verify-code", method: .post, body: body)
    }

    /// نرمال‌سازی شمارهٔ موبایل ایران: ارقام فارسی به لاتین، حذف فاصله و خط تیره،
    /// و تبدیل ‎+98‎ یا ‎98‎ ابتدای شماره به ‎09‎. خروجی معتبر ‎09xxxxxxxxx‎ است.
    static func normalizedMobile(_ raw: String) -> String {
        let latin = raw.faDigitsToLatin
        let digits = latin.filter { $0.isNumber }
        if digits.hasPrefix("98"), digits.count == 12 {
            return "0" + digits.dropFirst(2)
        }
        if digits.hasPrefix("0098"), digits.count == 14 {
            return "0" + digits.dropFirst(4)
        }
        return digits
    }

    static func isValidMobile(_ raw: String) -> Bool {
        let mobile = normalizedMobile(raw)
        return mobile.count == 11 && mobile.hasPrefix("09")
    }
}
