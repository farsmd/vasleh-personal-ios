import Foundation

// تبدیل ارقام لاتین به فارسی برای نمایش اعداد در رابط کاربری.
extension String {
    var faDigits: String {
        let map: [Character: Character] = [
            "0": "۰", "1": "۱", "2": "۲", "3": "۳", "4": "۴",
            "5": "۵", "6": "۶", "7": "۷", "8": "۸", "9": "۹"
        ]
        return String(self.map { map[$0] ?? $0 })
    }
}

extension Int {
    var faDigits: String { String(self).faDigits }
}

// تبدیل ارقام فارسی و عربی به لاتین، برای نرمال‌سازی شمارهٔ موبایل پیش از ارسال.
extension String {
    var faDigitsToLatin: String {
        let map: [Character: Character] = [
            "۰": "0", "۱": "1", "۲": "2", "۳": "3", "۴": "4",
            "۵": "5", "۶": "6", "۷": "7", "۸": "8", "۹": "9",
            "٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4",
            "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9"
        ]
        return String(self.map { map[$0] ?? $0 })
    }
}

extension Double {
    // نسبت ۰ تا ۱ را به درصد فارسی تبدیل می‌کند، مثلاً ۰٫۷۸ به «۷۸٪».
    var faPercent: String { "\(Int(self * 100).faDigits)٪" }
}
