import SwiftUI

struct SettingsView: View {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @StateObject private var wrongAnswersManager = WrongAnswersManager.shared
    @StateObject private var wordStateManager = WordStateManager.shared
    @StateObject private var testHistoryManager = TestHistoryManager.shared
    @StateObject private var practiceHistoryManager = PracticeHistoryManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingClearCacheAlert = false
    @State private var showingClearHistoryAlert = false
    @State private var showingNotificationSettings = false
    @State private var showingLearningTips = false
    @State private var showingTermsPrivacy = false
    @State private var showingHelpSupport = false
    @State private var showingAbout = false
    
    private var notificationSubtitle: String {
        if notificationManager.notificationsEnabled {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: notificationManager.notificationTime)
            return "Every day at \(timeString)"
        } else {
            return "Configure notification time"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title - matching TestView and PracticeView style
            ZStack {
                // Centered title
                HStack {
                    Spacer()
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.appRed)
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 5)
            .padding(.bottom, 20)
            
            // Content
            ScrollView {
                VStack(spacing: 0) {
                
                // MODE Section
                SettingsSection(header: "MODE") {
                    SettingsRow(
                        icon: "moon.fill",
                    iconColor: .appRed,
                        title: "Dark Mode",
                        subtitle: "Enable dark mode",
                        accessory: .toggle(isOn: $darkModeEnabled)
                    )
                }
                
                // SCHEDULE Section
                SettingsSection(header: "SCHEDULE") {
                    SettingsRow(
                        icon: "clock",
                    iconColor: .appRed,
                        title: "Schedule Notifications",
                        subtitle: notificationSubtitle,
                        accessory: .chevron(action: {
                            showingNotificationSettings = true
                        })
                    )
                }
                
                // LEARNING Section
                SettingsSection(header: "LEARNING") {
                    SettingsRow(
                        icon: "lightbulb.fill",
                    iconColor: .appRed,
                        title: "Learning Tips",
                        subtitle: "Effective learning strategies",
                        accessory: .chevron(action: {
                            showingLearningTips = true
                        })
                    )
                }
                
                // SUPPORT Section
                SettingsSection(header: "SUPPORT") {
                    SettingsRow(
                        icon: "questionmark.circle.fill",
                    iconColor: .appRed,
                        title: "Help & Support",
                        subtitle: "Get help and contact support",
                        accessory: .chevron(action: {
                            showingHelpSupport = true
                        })
                    )
                    
                    SettingsRow(
                        icon: "doc.text.fill",
                    iconColor: .appRed,
                        title: "Terms & Privacy",
                        subtitle: "View terms and privacy policy",
                        accessory: .chevron(action: {
                            showingTermsPrivacy = true
                        })
                    )
                    
                    SettingsRow(
                        icon: "info.circle.fill",
                    iconColor: .appRed,
                        title: "About",
                        subtitle: "App version and information",
                        accessory: .chevron(action: {
                            showingAbout = true
                        })
                    )
                }
                
                // CACHE Section
                SettingsSection(header: "CACHE") {
                SettingsRow(
                    icon: "trash.fill",
                    iconColor: .appRed,
                    title: "Clear Cache",
                    subtitle: "Clear word states cache",
                    accessory: .button(
                        badge: nil,
                        action: {
                            showingClearCacheAlert = true
                        }
                    )
                )
                    
                    SettingsRow(
                        icon: "clock.arrow.circlepath",
                        iconColor: .appRed,
                        title: "Clear History",
                        subtitle: "Delete test/practice history",
                        accessory: .button(
                            badge: nil,
                            action: {
                                showingClearHistoryAlert = true
                            }
                        )
                    )
                }
                
                    Spacer(minLength: 20)
                }
                .padding(.bottom, 55) // Add padding for menu
            }
        }
        .background(Color(.systemGroupedBackground))
        .clipped()
        .alert("Clear Cache", isPresented: $showingClearCacheAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                wrongAnswersManager.clearAllWrongAnswers()
                wordStateManager.clearAllWordStates()
            }
        } message: {
            Text("This will clear all saved wrong answers and word states (weak, learning, review, mastered). This action cannot be undone.")
        }
        .alert("Clear History", isPresented: $showingClearHistoryAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                testHistoryManager.clearAllHistory()
                practiceHistoryManager.clearAllHistory()
            }
        } message: {
            Text("This will delete all test and practice history records. This action cannot be undone.")
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsModal()
        }
        .sheet(isPresented: $showingLearningTips) {
            LearningTipsView()
        }
        .sheet(isPresented: $showingTermsPrivacy) {
            TermsPrivacyView()
        }
        .sheet(isPresented: $showingHelpSupport) {
            HelpSupportView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}

struct SettingsSection<Content: View>: View {
    let header: String
    let content: Content
    
    init(header: String, @ViewBuilder content: () -> Content) {
        self.header = header
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.appRed)
                .textCase(.uppercase)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 8)
            
                VStack(spacing: 8) {
                content
            }
            .padding(.horizontal, 20)
        }
    }
}

enum SettingsRowAccessory {
    case toggle(isOn: Binding<Bool>)
    case chevron(action: (() -> Void)? = nil)
    case button(badge: String?, action: () -> Void)
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let accessory: SettingsRowAccessory
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon - simple style without circle
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 30, height: 30)
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.appRed)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Accessory
            switch accessory {
            case .toggle(let isOn):
                Toggle("", isOn: isOn)
                    .labelsHidden()
            case .chevron:
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .opacity(0.7)
            case .button(let badge, _):
                HStack(spacing: 8) {
                    if let badge = badge, !badge.isEmpty {
                        Text(badge)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.appRed)
                            .cornerRadius(12)
                    }
                    Text("Clear")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appRed)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .contentShape(Rectangle())
        .onTapGesture {
            switch accessory {
            case .chevron(let action):
                if let action = action {
                    action()
                }
            case .button(_, let action):
                action()
            case .toggle:
                break
            }
        }
    }
}

#Preview {
    SettingsView()
}
