import Foundation

// کاربر واردشده.
struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
}

// بدنهٔ درخواست کد تایید پیامکی: فقط شمارهٔ موبایل.
struct RequestCodeRequest: Codable {
    let mobile: String
}

// پاسخ درخواست کد: اعتبار کد (ثانیه) و فاصلهٔ مجاز تا ارسال دوباره (ثانیه).
struct RequestCodeResponse: Codable {
    let ok: Bool
    let expiresIn: Int
    let resendAfter: Int
}

// بدنهٔ تایید کد: شمارهٔ موبایل + کد ۵ رقمی.
struct VerifyCodeRequest: Codable {
    let mobile: String
    let code: String
}

// پاسخ ورود: توکن Bearer و کاربر.
struct AuthResponse: Codable {
    let token: String
    let user: User
}

// بدنهٔ ثبت یک نوبت پومودورو.
struct PomodoroSessionRequest: Codable {
    let durationMinutes: Int
    let completedAt: Date
}

// پاسخ سادهٔ «انجام شد» از سرور.
struct OkResponse: Codable {
    let ok: Bool
}
