import SwiftUI

// تنظیمات: استایل با همان چهار سبک، تنظیمات کاربری، دادهٔ نمونه و خروج از حساب.
struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showLogoutAlert = false

    var body: some View {
        let palette = appState.palette
        ZStack {
            palette.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .trailing, spacing: 20) {
                    Text("تنظیمات")
                        .font(.system(size: 22, weight: palette.headingWeight))
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    VStack(alignment: .trailing, spacing: 10) {
                        Text("تنظیمات استایل")
                            .font(.system(size: 15, weight: palette.headingWeight))
                        ForEach(AppTheme.allCases) { theme in
                            Button(action: { appState.selectedTheme = theme }) {
                                HStack {
                                    Circle()
                                        .fill(Color(hex: theme.dotHex))
                                        .frame(width: 12, height: 12)
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(theme.displayName)
                                            .font(.system(size: 14, weight: .bold))
                                        Text(theme.subtitle)
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundStyle(palette.textSecondary)
                                    }
                                    Spacer()
                                    if appState.selectedTheme == theme {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(palette.accent)
                                    }
                                }
                                .padding()
                                .themedCard(palette: palette)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    VStack(alignment: .trailing, spacing: 10) {
                        Text("تنظیمات کاربری")
                            .font(.system(size: 15, weight: palette.headingWeight))
                        TextField("نام نمایشی", text: $appState.displayName)
                            .padding()
                            .background(palette.surface)
                            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                        Stepper(
                            "مدت تمرکز: \(appState.focusMinutes.faDigits) دقیقه",
                            value: $appState.focusMinutes,
                            in: 5...120,
                            step: 5
                        )
                        Stepper(
                            "مدت استراحت: \(appState.breakMinutes.faDigits) دقیقه",
                            value: $appState.breakMinutes,
                            in: 1...30,
                            step: 1
                        )
                        Text("تغییرات به‌صورت خودکار ذخیره می‌شوند.")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(palette.textSecondary)
                    }

                    VStack(alignment: .trailing, spacing: 10) {
                        Text("داده")
                            .font(.system(size: 15, weight: palette.headingWeight))
                        Toggle("استفاده از دادهٔ نمونه", isOn: $appState.useMockAPI)
                        Text("با خاموش کردن این گزینه، اپ به API واقعی وصله وصل می‌شود؛ endpointهای موبایل هنوز روی سرور ساخته نشده‌اند.")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(palette.textSecondary)
                    }

                    VStack(alignment: .trailing, spacing: 10) {
                        Text("حساب کاربری")
                            .font(.system(size: 15, weight: palette.headingWeight))
                        Text(appState.displayName.isEmpty ? "کاربر واردشده" : appState.displayName)
                            .font(.system(size: 14, weight: .regular))
                        Button("خروج از حساب کاربری", role: .destructive) {
                            showLogoutAlert = true
                        }
                    }
                }
                .padding()
            }
        }
        .foregroundStyle(palette.textPrimary)
        .alert("خروج از حساب کاربری", isPresented: $showLogoutAlert) {
            Button("خروج", role: .destructive) {
                appState.signOut()
            }
            Button("لغو", role: .cancel) {}
        } message: {
            Text("آیا مطمئن هستی که می‌خواهی خارج شوی؟")
        }
    }
}
