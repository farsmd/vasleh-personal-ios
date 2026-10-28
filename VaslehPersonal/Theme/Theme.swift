import SwiftUI

// چهار سبک طراحی، دقیقاً همان چهار سبک ماکاپ:
// منشور تاریک، بوم آرام، نئون ساختاریافته، ماتریس مهندسی.
enum AppTheme: String, CaseIterable, Identifiable, Codable {
    case darkPrism
    case zenCanvas
    case swissPop
    case monoGrid

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .darkPrism: return "منشور تاریک"
        case .zenCanvas: return "بوم آرام"
        case .swissPop: return "نئون ساختاریافته"
        case .monoGrid: return "ماتریس مهندسی"
        }
    }

    var subtitle: String {
        switch self {
        case .darkPrism: return "شیشه مایع، عمق فضایی و نئون ملایم"
        case .zenCanvas: return "مینیمالیسم گرم، کاغذی و بدون استرس"
        case .swissPop: return "نئوبروتالیسم، سایه سخت و کنتراست بالا"
        case .monoGrid: return "گرید صنعتی، خطوط دقیق و داده‌محور"
        }
    }

    var dotHex: String {
        switch self {
        case .darkPrism: return "#818CF8"
        case .zenCanvas: return "#2D5A27"
        case .swissPop: return "#FF5E36"
        case .monoGrid: return "#FF4F00"
        }
    }

    var palette: ThemePalette {
        switch self {
        case .darkPrism:
            return ThemePalette(
                background: Color(hex: "#090A0F"),
                surface: Color.white.opacity(0.06),
                surfaceElevated: Color.white.opacity(0.09),
                textPrimary: Color(hex: "#F8FAFC"),
                textSecondary: Color(hex: "#94A3B8"),
                accent: Color(hex: "#818CF8"),
                accentSecondary: Color(hex: "#34D399"),
                border: Color.white.opacity(0.11),
                borderWidth: 1,
                cornerRadius: 24,
                isDark: true,
                headingWeight: .heavy
            )
        case .zenCanvas:
            return ThemePalette(
                background: Color(hex: "#F6F4F0"),
                surface: Color(hex: "#FFFFFF"),
                surfaceElevated: Color(hex: "#EFECE6"),
                textPrimary: Color(hex: "#1C1B18"),
                textSecondary: Color(hex: "#605C56"),
                accent: Color(hex: "#2D5A27"),
                accentSecondary: Color(hex: "#D96B43"),
                border: Color(hex: "#E6E2DA"),
                borderWidth: 1,
                cornerRadius: 20,
                isDark: false,
                headingWeight: .semibold
            )
        case .swissPop:
            return ThemePalette(
                background: Color(hex: "#F4F4F6"),
                surface: Color(hex: "#FFFFFF"),
                surfaceElevated: Color(hex: "#D4FF33"),
                textPrimary: Color(hex: "#111111"),
                textSecondary: Color(hex: "#3F3F46"),
                accent: Color(hex: "#FF5E36"),
                accentSecondary: Color(hex: "#6366F1"),
                border: Color(hex: "#111111"),
                borderWidth: 2,
                cornerRadius: 16,
                isDark: false,
                headingWeight: .black
            )
        case .monoGrid:
            return ThemePalette(
                background: Color(hex: "#121316"),
                surface: Color(hex: "#1A1C20"),
                surfaceElevated: Color(hex: "#20232A"),
                textPrimary: Color(hex: "#EDEDEF"),
                textSecondary: Color(hex: "#8A8F98"),
                accent: Color(hex: "#FF4F00"),
                accentSecondary: Color(hex: "#00E5FF"),
                border: Color(hex: "#2A2D34"),
                borderWidth: 1,
                cornerRadius: 6,
                isDark: true,
                headingWeight: .bold
            )
        }
    }
}

struct ThemePalette {
    let background: Color
    let surface: Color
    let surfaceElevated: Color
    let textPrimary: Color
    let textSecondary: Color
    let accent: Color
    let accentSecondary: Color
    let border: Color
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let isDark: Bool
    let headingWeight: Font.Weight
}

extension Color {
    init(hex: String) {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("#") {
            value.removeFirst()
        }
        var rgb: UInt64 = 0
        _ = Scanner(string: value).scanHexInt64(&rgb)
        let red = Double((rgb >> 16) & 0xFF) / 255
        let green = Double((rgb >> 8) & 0xFF) / 255
        let blue = Double(rgb & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

// کارت استاندارد هر تم: پس‌زمینه، گوشه و حاشیهٔ همان تم.
extension View {
    func themedCard(palette: ThemePalette) -> some View {
        self
            .background(palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: palette.cornerRadius)
                    .stroke(palette.border, lineWidth: palette.borderWidth)
            )
    }
}
