//
//  SettingsView.swift
//  MachineGE
//
//  Created by sg on 12/29/25.
//

import SwiftUI
import MessageUI
import StoreKit

// MARK: - 앱 테마 설정
enum AppTheme: String, CaseIterable {
    case system = "시스템 설정"
    case light = "라이트 모드"
    case dark = "다크 모드"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

// MARK: - 설정 뷰
struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    
    @State private var showingLoginSheet = false
    @State private var showingLogoutAlert = false
    @State private var showingMailComposer = false
    @State private var showingDonationSheet = false
    @State private var showingThemePicker = false
    @State private var mailErrorAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - 계정 섹션
                Section {
                    if isLoggedIn {
                        HStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(userName.isEmpty ? "사용자" : userName)
                                    .font(.headline)
                                Text("로그인됨")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("로그아웃") {
                                showingLogoutAlert = true
                            }
                            .font(.subheadline)
                            .foregroundStyle(.red)
                        }
                        .padding(.vertical, 8)
                    } else {
                        Button {
                            showingLoginSheet = true
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.gray)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("로그인")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text("리뷰 작성 및 즐겨찾기 동기화")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                } header: {
                    Text("계정")
                }
                
                // MARK: - 앱 설정 섹션
                Section {
                    // 테마 설정
                    Button {
                        showingThemePicker = true
                    } label: {
                        HStack {
                            Label {
                                Text("테마")
                            } icon: {
                                Image(systemName: appTheme.icon)
                                    .foregroundStyle(.purple)
                            }
                            
                            Spacer()
                            
                            Text(appTheme.rawValue)
                                .foregroundStyle(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    // 알림 설정
                    Toggle(isOn: $notificationsEnabled) {
                        Label {
                            Text("알림")
                        } icon: {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    
                    // 언어 설정 (iOS 설정으로 이동)
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Label {
                                Text("언어")
                            } icon: {
                                Image(systemName: "globe")
                                    .foregroundStyle(.blue)
                            }
                            
                            Spacer()
                            
                            Text(Locale.current.language.languageCode?.identifier == "ko" ? "한국어" : "English")
                                .foregroundStyle(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("앱 설정")
                }
                
                // MARK: - 지원 섹션
                Section {
                    // 개발자 후원
                    Button {
                        showingDonationSheet = true
                    } label: {
                        Label {
                            Text("개발자 후원하기")
                        } icon: {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.pink)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    // 개발자에게 문의
                    Button {
                        if MFMailComposeViewController.canSendMail() {
                            showingMailComposer = true
                        } else {
                            mailErrorAlert = true
                        }
                    } label: {
                        Label {
                            Text("개발자에게 문의")
                        } icon: {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    // 앱 평가
                    Button {
                        requestAppReview()
                    } label: {
                        Label {
                            Text("앱 평가하기")
                        } icon: {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    // 앱 공유
                    ShareLink(item: URL(string: "https://apps.apple.com/app/idYOUR_APP_ID")!) {
                        Label {
                            Text("앱 공유하기")
                        } icon: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(.green)
                        }
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("지원")
                }
                
                // MARK: - 정보 섹션
                Section {
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label {
                            Text("개인정보 처리방침")
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        Label {
                            Text("이용약관")
                        } icon: {
                            Image(systemName: "doc.text.fill")
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    NavigationLink {
                        OpenSourceLicenseView()
                    } label: {
                        Label {
                            Text("오픈소스 라이선스")
                        } icon: {
                            Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .foregroundStyle(.indigo)
                        }
                    }
                    
                    HStack {
                        Label {
                            Text("버전")
                        } icon: {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.cyan)
                        }
                        
                        Spacer()
                        
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("정보")
                }
                
                // MARK: - 데이터 관리 섹션
                Section {
                    Button {
                        clearCache()
                    } label: {
                        Label {
                            Text("캐시 삭제")
                        } icon: {
                            Image(systemName: "trash.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("데이터 관리")
                } footer: {
                    Text("이미지 캐시 및 임시 파일을 삭제합니다.")
                }
            }
            .navigationTitle("⚙️ 설정")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingLoginSheet) {
                LoginView(isLoggedIn: $isLoggedIn, userName: $userName)
            }
            .sheet(isPresented: $showingMailComposer) {
                MailComposerView()
            }
            .sheet(isPresented: $showingDonationSheet) {
                DonationView()
            }
            .confirmationDialog("테마 선택", isPresented: $showingThemePicker, titleVisibility: .visible) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Button(theme.rawValue) {
                        appTheme = theme
                    }
                }
                Button("취소", role: .cancel) {}
            }
            .alert("로그아웃", isPresented: $showingLogoutAlert) {
                Button("취소", role: .cancel) {}
                Button("로그아웃", role: .destructive) {
                    isLoggedIn = false
                    userName = ""
                }
            } message: {
                Text("정말 로그아웃하시겠습니까?")
            }
            .alert("메일 앱 필요", isPresented: $mailErrorAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("기기에 메일 앱이 설정되어 있지 않습니다. support@example.com으로 문의해주세요.")
            }
            .preferredColorScheme(appTheme.colorScheme)
        }
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    private func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func clearCache() {
        // 이미지 캐시 삭제
        URLCache.shared.removeAllCachedResponses()
        
        // 임시 파일 삭제
        let tmpDir = FileManager.default.temporaryDirectory
        try? FileManager.default.contentsOfDirectory(at: tmpDir, includingPropertiesForKeys: nil).forEach {
            try? FileManager.default.removeItem(at: $0)
        }
    }
}

// MARK: - 로그인 뷰
struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isLoggedIn: Bool
    @Binding var userName: String
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 앱 로고
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .padding(.top, 40)
                
                Text("MachineGE")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("운동 기구 가이드")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // 소셜 로그인 버튼들
                VStack(spacing: 12) {
                    // Apple 로그인
                    Button {
                        // TODO: Apple 로그인 구현
                        simulateLogin(name: "Apple 사용자")
                    } label: {
                        HStack {
                            Image(systemName: "apple.logo")
                            Text("Apple로 계속하기")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primary)
                        .foregroundStyle(Color(UIColor.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Google 로그인
                    Button {
                        // TODO: Google 로그인 구현
                        simulateLogin(name: "Google 사용자")
                    } label: {
                        HStack {
                            Image(systemName: "g.circle.fill")
                            Text("Google로 계속하기")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // 카카오 로그인
                    Button {
                        // TODO: 카카오 로그인 구현
                        simulateLogin(name: "카카오 사용자")
                    } label: {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("카카오로 계속하기")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 비회원 계속하기
                Button {
                    dismiss()
                } label: {
                    Text("비회원으로 계속하기")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
        }
    }
    
    private func simulateLogin(name: String) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            userName = name
            isLoggedIn = true
            dismiss()
        }
    }
}

// MARK: - 메일 작성 뷰
struct MailComposerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(["support@machinege.app"])
        composer.setSubject("[MachineGE] 문의사항")
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let deviceInfo = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        let body = """
        
        
        ---
        앱 버전: \(appVersion)
        기기 정보: \(deviceInfo)
        """
        composer.setMessageBody(body, isHTML: false)
        
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposerView
        
        init(_ parent: MailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}

// MARK: - 후원 뷰
struct DonationView: View {
    @Environment(\.dismiss) private var dismiss
    
    let donationOptions = [
        ("☕️", "커피 한 잔", "$1.99"),
        ("🍕", "피자 한 조각", "$4.99"),
        ("🍔", "햄버거 세트", "$9.99"),
        ("🎉", "파티 후원", "$19.99")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.pink)
                    .padding(.top, 40)
                
                Text("개발자 후원하기")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("여러분의 후원은 더 나은 앱을 만드는 데\n큰 힘이 됩니다 💪")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 12) {
                    ForEach(donationOptions, id: \.1) { emoji, title, price in
                        Button {
                            // TODO: StoreKit 인앱 구매 구현
                        } label: {
                            HStack {
                                Text(emoji)
                                    .font(.title)
                                Text(title)
                                    .fontWeight(.medium)
                                Spacer()
                                Text(price)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.blue)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Text("후원 내역은 앱 개선 및 서버 유지에 사용됩니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 개인정보 처리방침 뷰
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("개인정보 처리방침")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("최종 수정일: 2025년 1월 1일")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Group {
                    sectionTitle("1. 수집하는 개인정보")
                    Text("본 앱은 서비스 제공을 위해 다음 정보를 수집합니다:\n• 이메일 주소 (로그인 시)\n• 닉네임\n• 리뷰 내용")
                    
                    sectionTitle("2. 개인정보의 이용 목적")
                    Text("수집된 정보는 다음 목적으로 이용됩니다:\n• 서비스 제공 및 개선\n• 사용자 문의 응대\n• 앱 이용 통계 분석")
                    
                    sectionTitle("3. 개인정보의 보관 기간")
                    Text("회원 탈퇴 시 즉시 삭제되며, 관련 법령에 따라 일정 기간 보관이 필요한 경우 해당 기간 동안 보관합니다.")
                    
                    sectionTitle("4. 문의처")
                    Text("개인정보 관련 문의: support@machinege.app")
                }
            }
            .padding()
        }
        .navigationTitle("개인정보 처리방침")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .padding(.top, 8)
    }
}

// MARK: - 이용약관 뷰
struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("이용약관")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("최종 수정일: 2025년 1월 1일")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Group {
                    sectionTitle("제1조 (목적)")
                    Text("본 약관은 MachineGE(이하 '앱')가 제공하는 서비스의 이용조건 및 절차에 관한 사항을 규정함을 목적으로 합니다.")
                    
                    sectionTitle("제2조 (서비스 내용)")
                    Text("앱은 운동 기구 정보 제공 서비스를 제공합니다.")
                    
                    sectionTitle("제3조 (이용자의 의무)")
                    Text("이용자는 다음 행위를 하여서는 안 됩니다:\n• 타인의 정보 도용\n• 앱의 정상적인 운영을 방해하는 행위\n• 기타 관련 법령에 위배되는 행위")
                    
                    sectionTitle("제4조 (면책조항)")
                    Text("앱에서 제공하는 운동 정보는 참고용이며, 실제 운동 시 전문가의 조언을 구하시기 바랍니다.")
                }
            }
            .padding()
        }
        .navigationTitle("이용약관")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .padding(.top, 8)
    }
}

// MARK: - 오픈소스 라이선스 뷰
struct OpenSourceLicenseView: View {
    let licenses = [
        ("SwiftSoup", "MIT License", "HTML 파싱 라이브러리"),
        ("LRUCache", "MIT License", "이미지 캐시 라이브러리")
    ]
    
    var body: some View {
        List {
            ForEach(licenses, id: \.0) { name, license, description in
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                    Text(license)
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("오픈소스 라이선스")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - AppTheme RawRepresentable for AppStorage
extension AppTheme: RawRepresentable {
    init?(rawValue: String) {
        switch rawValue {
        case "시스템 설정": self = .system
        case "라이트 모드": self = .light
        case "다크 모드": self = .dark
        default: return nil
        }
    }
}

#Preview {
    SettingsView()
}
