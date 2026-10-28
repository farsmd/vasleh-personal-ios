import SwiftUI

// تایمر تمرکز پومودورو با حلقهٔ پیشرفت: شروع، توقف و بازنشانی.
// مدت پیش‌فرض از تنظیمات کاربر می‌آید؛ پایان نوبت روی سرور ثبت می‌شود.
struct PomodoroView: View {
    @EnvironmentObject private var appState: AppState
    @State private var remainingSeconds: Int?
    @State private var isRunning = false
    @State private var timerTask: Task<Void, Never>?
    @State private var finished = false

    private var totalSeconds: Int { appState.focusMinutes * 60 }

    private var currentSeconds: Int { remainingSeconds ?? totalSeconds }

    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - currentSeconds) / Double(totalSeconds)
    }

    var body: some View {
        let palette = appState.palette
        VStack(spacing: 14) {
            HStack {
                Label("تایمر تمرکز", systemImage: "timer")
                    .font(.system(size: 15, weight: palette.headingWeight))
                Spacer()
                Text("نوبت تمرکز")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
            }
            ZStack {
                Circle()
                    .stroke(palette.surfaceElevated, lineWidth: 10)
                    .frame(width: 140, height: 140)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(palette.accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                Text(timeText)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
            }
            if finished {
                Text("نوبت تمرکز تمام شد.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(palette.accentSecondary)
            }
            HStack(spacing: 10) {
                Button(isRunning ? "توقف" : "شروع") { toggle() }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(palette.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                Button("بازنشانی") { reset() }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(palette.surfaceElevated)
                    .foregroundStyle(palette.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
            }
        }
        .padding()
        .themedCard(palette: palette)
    }

    private var timeText: String {
        let minutes = currentSeconds / 60
        let seconds = currentSeconds % 60
        return "\(minutes.faDigits):\(String(format: "%02d", seconds).faDigits)"
    }

    private func toggle() {
        if isRunning {
            timerTask?.cancel()
            timerTask = nil
            isRunning = false
        } else {
            if remainingSeconds == nil || remainingSeconds == 0 {
                remainingSeconds = totalSeconds
                finished = false
            }
            isRunning = true
            timerTask = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    guard !Task.isCancelled else { break }
                    await MainActor.run {
                        if let left = remainingSeconds, left > 0 {
                            remainingSeconds = left - 1
                            if left - 1 == 0 {
                                finish()
                            }
                        }
                    }
                }
            }
        }
    }

    private func finish() {
        timerTask?.cancel()
        timerTask = nil
        isRunning = false
        finished = true
        let minutes = appState.focusMinutes
        Task {
            try? await appState.pomodoroService.logSession(durationMinutes: minutes)
        }
    }

    private func reset() {
        timerTask?.cancel()
        timerTask = nil
        isRunning = false
        remainingSeconds = totalSeconds
        finished = false
    }
}
