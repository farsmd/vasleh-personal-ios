import SwiftUI

// صفحهٔ ورود با موبایل + کد پیامکی، در دو مرحله:
// ۱) شمارهٔ موبایل → ارسال کد ۵ رقمی
// ۲) وارد کردن کد → تایید و ورود
// هیچ رمزی گرفته یا ذخیره نمی‌شود؛ بعد از تایید، توکن Bearer فقط در Keychain می‌ماند.
struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @State private var mobile = ""
    @State private var code = ""
    @State private var step: Step = .phone
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var resendCountdown = 0

    private enum Step {
        case phone
        case code
    }

    var body: some View {
        let palette = appState.palette
        ZStack {
            palette.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .trailing, spacing: 20) {
                    Spacer().frame(height: 60)
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("مدیریت شخصی وصله")
                            .font(.system(size: 28, weight: palette.headingWeight))
                        Text("Vasleh Personal")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(palette.textSecondary)
                        Text("کارها، رویدادها، یادداشت‌ها و پروژه‌هایت در یک جا")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(palette.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    VStack(spacing: 12) {
                        if step == .phone {
                            phoneStep(palette: palette)
                        } else {
                            codeStep(palette: palette)
                        }
                        if let message = errorMessage {
                            Text(message)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        if appState.useMockAPI {
                            Text("در حالت نمونه، هیچ پیامکی واقعاً ارسال نمی‌شود و هر کد ۵ رقمی پذیرفته می‌شود.")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(palette.textSecondary)
                        }
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .foregroundStyle(palette.textPrimary)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if resendCountdown > 0 {
                resendCountdown -= 1
            }
        }
    }

    private func phoneStep(palette: ThemePalette) -> some View {
        VStack(spacing: 12) {
            TextField("شمارهٔ موبایل (مثل ۰۹۱۲۳۴۵۶۷۸۹)", text: $mobile)
                .keyboardType(.phonePad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(palette.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
            Text("کد تایید ۵ رقمی به همین شماره پیامک می‌شود.")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(palette.textSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            Button(action: requestCode) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("ارسال کد تایید")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(palette.accent)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
            .disabled(!AuthService.isValidMobile(mobile) || isLoading)
        }
    }

    private func codeStep(palette: ThemePalette) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("کد ارسال‌شده به \(AuthService.normalizedMobile(mobile).faDigits)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
                Spacer()
                Button("ویرایش شماره") {
                    errorMessage = nil
                    code = ""
                    step = .phone
                }
                .font(.system(size: 13, weight: .bold))
            }
            TextField("کد ۵ رقمی", text: $code)
                .keyboardType(.numberPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(palette.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                .onChange(of: code) { _, newValue in
                    let latin = newValue.faDigitsToLatin.filter { $0.isNumber }
                    code = String(latin.prefix(5))
                }
            Button(action: verifyCode) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("تایید و ورود")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(palette.accent)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
            .disabled(code.count != 5 || isLoading)
            if resendCountdown > 0 {
                Text("ارسال دوبارهٔ کد تا \(resendCountdown.faDigits) ثانیهٔ دیگر")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
            } else {
                Button("ارسال دوبارهٔ کد", action: requestCode)
                    .font(.system(size: 13, weight: .bold))
                    .disabled(isLoading)
            }
        }
    }

    private func requestCode() {
        errorMessage = nil
        isLoading = true
        let normalized = AuthService.normalizedMobile(mobile)
        Task {
            do {
                let response = try await appState.authService.requestCode(mobile: normalized)
                resendCountdown = response.resendAfter
                step = .code
            } catch {
                errorMessage = (error as? APIError)?.errorDescription ?? "خطای ناشناخته"
            }
            isLoading = false
        }
    }

    private func verifyCode() {
        errorMessage = nil
        isLoading = true
        let normalized = AuthService.normalizedMobile(mobile)
        Task {
            do {
                let response = try await appState.authService.verifyCode(mobile: normalized, code: code)
                appState.signIn(token: response.token, user: response.user)
            } catch {
                errorMessage = (error as? APIError)?.errorDescription ?? "خطای ناشناخته"
            }
            isLoading = false
        }
    }
}
