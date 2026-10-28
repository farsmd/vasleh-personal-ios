import Foundation

// یک رویداد در تقویم.
struct CalendarEvent: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var startsAt: Date
    var endsAt: Date
    var location: String?
}
