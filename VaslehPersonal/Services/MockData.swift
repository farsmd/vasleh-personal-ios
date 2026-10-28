import Foundation

// دادهٔ نمونه برای حالت نمایشی اپ.
// این‌ها دادهٔ واقعی هیچ کاربری نیستند؛ فقط برای دیدن صفحه‌ها ساخته شده‌اند.
enum MockData {
    static let sampleUser = User(id: UUID(), name: "کاربر نمونه")

    static func sampleTodos() -> [Todo] {
        let now = Date()
        return [
            Todo(id: UUID(), title: "مرور یادداشت‌های جلسهٔ دیروز", done: true, createdAt: now),
            Todo(id: UUID(), title: "آماده‌سازی گزارش هفتگی", done: false, createdAt: now),
            Todo(id: UUID(), title: "خواندن ۲۰ صفحه کتاب", done: false, createdAt: now),
            Todo(id: UUID(), title: "پیاده‌روی عصر", done: false, createdAt: now),
            Todo(id: UUID(), title: "پاسخ به پیام‌های کاری", done: true, createdAt: now)
        ]
    }

    static func sampleEvents() -> [CalendarEvent] {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        return [
            CalendarEvent(
                id: UUID(),
                title: "جلسهٔ بازبینی طراحی",
                startsAt: at(hour: 10, minute: 30, on: today),
                endsAt: at(hour: 11, minute: 30, on: today),
                location: "تماس تصویری"
            ),
            CalendarEvent(
                id: UUID(),
                title: "ارائهٔ معماری فرانت‌اند",
                startsAt: at(hour: 15, minute: 0, on: today),
                endsAt: at(hour: 16, minute: 0, on: today),
                location: "اتاق جلسات"
            ),
            CalendarEvent(
                id: UUID(),
                title: "مرور هفتگی",
                startsAt: at(hour: 9, minute: 0, on: tomorrow),
                endsAt: at(hour: 10, minute: 0, on: tomorrow),
                location: nil
            )
        ]
    }

    static func sampleNotes() -> [Note] {
        let now = Date()
        return [
            Note(
                id: UUID(),
                title: "ایده‌های طراحی",
                body: "استفاده از کنتراست بالا و دکمه‌های درشت در یک‌سوم پایینی صفحه، کار با موبایل را سریع‌تر می‌کند.",
                updatedAt: now
            ),
            Note(
                id: UUID(),
                title: "فهرست مطالعه",
                body: "فصل اول کتاب طراحی تعامل، مقالهٔ بنتوگریدهای پویا و مستندات تایمر پومودورو.",
                updatedAt: now
            )
        ]
    }

    static func sampleProjects() -> [Project] {
        return [
            Project(id: UUID(), title: "بازطراحی اپ", progress: 0.8),
            Project(id: UUID(), title: "کمپین پاییزه", progress: 0.45),
            Project(id: UUID(), title: "یادگیری زبان", progress: 0.6)
        ]
    }

    private static func at(hour: Int, minute: Int, on day: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }
}
