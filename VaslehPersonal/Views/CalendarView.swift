import SwiftUI

// تقویم: نوار هفت روز و رویدادهای روز انتخاب‌شده.
struct CalendarView: View {
    @EnvironmentObject private var appState: AppState
    @State private var events: [CalendarEvent] = []
    @State private var selectedDay: Date = Calendar.current.startOfDay(for: Date())
    @State private var errorMessage: String?

    private var weekDays: [Date] {
        let calendar = Calendar.current
        let start = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        ) ?? Date()
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private var dayEvents: [CalendarEvent] {
        events
            .filter { Calendar.current.isDate($0.startsAt, inSameDayAs: selectedDay) }
            .sorted { $0.startsAt < $1.startsAt }
    }

    var body: some View {
        let palette = appState.palette
        ZStack {
            palette.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .trailing, spacing: 14) {
                    Text("تقویم")
                        .font(.system(size: 22, weight: palette.headingWeight))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    HStack(spacing: 6) {
                        ForEach(weekDays, id: \.self) { day in
                            let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDay)
                            Button(action: { selectedDay = Calendar.current.startOfDay(for: day) }) {
                                VStack(spacing: 4) {
                                    Text(weekdayLetter(for: day))
                                        .font(.system(size: 11, weight: .regular))
                                    Text(dayNumber(for: day))
                                        .font(.system(size: 15, weight: .bold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(isSelected ? palette.accent : palette.surface)
                                .foregroundStyle(isSelected ? .white : palette.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                            }
                        }
                    }
                    if let message = errorMessage {
                        Text(message)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.red)
                    }
                    if dayEvents.isEmpty {
                        Text("برای این روز رویدادی ثبت نشده است.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(palette.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    } else {
                        ForEach(dayEvents) { event in
                            HStack {
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(event.title)
                                        .font(.system(size: 15, weight: .bold))
                                    if let location = event.location {
                                        Text(location)
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundStyle(palette.textSecondary)
                                    }
                                }
                                Spacer()
                                Text("\(timeText(event.startsAt)) تا \(timeText(event.endsAt))")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(palette.textSecondary)
                            }
                            .padding()
                            .themedCard(palette: palette)
                        }
                    }
                }
                .padding()
            }
        }
        .foregroundStyle(palette.textPrimary)
        .task { await load() }
    }

    // حرف اول نام روز هفته، مثل ش برای شنبه.
    private func weekdayLetter(for day: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fa_IR")
        formatter.dateFormat = "EEEE"
        let name = formatter.string(from: day)
        return String(name.prefix(1))
    }

    private func dayNumber(for day: Date) -> String {
        let number = Calendar.current.component(.day, from: day)
        return number.faDigits
    }

    private func timeText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fa_IR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date).faDigits
    }

    private func load() async {
        errorMessage = nil
        do {
            events = try await appState.eventService.fetchEvents()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "خطای ناشناخته"
        }
    }
}
