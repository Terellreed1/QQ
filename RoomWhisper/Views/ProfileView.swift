import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingSettings = false
    @State private var showingAbout = false
    @State private var showingFutureWhispers = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    ProfileHeaderView()
                    
                    // Quick stats
                    StatsView()
                    
                    // Menu sections
                    VStack(spacing: 16) {
                        MenuSection(title: "Content") {
                            MenuRow(
                                icon: "clock.arrow.circlepath",
                                title: "Future Whispers",
                                subtitle: "Messages you've scheduled",
                                action: { showingFutureWhispers = true }
                            )
                            
                            MenuRow(
                                icon: "heart.fill",
                                title: "Liked Posts",
                                subtitle: "Your favorite whispers",
                                action: {}
                            )
                            
                            MenuRow(
                                icon: "bookmark.fill",
                                title: "Saved Buildings",
                                subtitle: "Your favorite locations",
                                action: {}
                            )
                        }
                        
                        MenuSection(title: "Preferences") {
                            MenuRow(
                                icon: "bell.fill",
                                title: "Notifications",
                                subtitle: "Manage your alerts",
                                action: {}
                            )
                            
                            MenuRow(
                                icon: "location.fill",
                                title: "Location Settings",
                                subtitle: "Privacy and permissions",
                                action: {}
                            )
                            
                            MenuRow(
                                icon: "theatermasks.fill",
                                title: "Anonymous Mode",
                                subtitle: "Default posting preference",
                                action: {}
                            )
                        }
                        
                        MenuSection(title: "Support") {
                            MenuRow(
                                icon: "questionmark.circle.fill",
                                title: "Help & FAQ",
                                subtitle: "Get help using Room Whisper",
                                action: {}
                            )
                            
                            MenuRow(
                                icon: "info.circle.fill",
                                title: "About",
                                subtitle: "App version and info",
                                action: { showingAbout = true }
                            )
                            
                            MenuRow(
                                icon: "gear.fill",
                                title: "Settings",
                                subtitle: "Account and app settings",
                                action: { showingSettings = true }
                            )
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingFutureWhispers) {
            FutureWhispersView()
        }
    }
}

struct ProfileHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.whisperBlue, .whisperYellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Text("👤")
                    .font(.largeTitle)
            }
            
            VStack(spacing: 4) {
                Text("Campus Explorer")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Student • Joined Fall 2024")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Quick action buttons
            HStack(spacing: 16) {
                ActionButton(
                    title: "Edit Profile",
                    icon: "pencil",
                    color: .whisperBlue
                ) {}
                
                ActionButton(
                    title: "Share Profile",
                    icon: "square.and.arrow.up",
                    color: .whisperYellow
                ) {}
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

struct StatsView: View {
    var body: some View {
        HStack(spacing: 0) {
            StatItem(title: "Whispers", value: "47")
            
            Divider()
                .frame(height: 40)
            
            StatItem(title: "Likes Given", value: "312")
            
            Divider()
                .frame(height: 40)
            
            StatItem(title: "Buildings", value: "8")
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.whisperBlue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MenuSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.whisperBlue)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                content
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.whisperBlue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .buttonStyle(.plain)
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var locationEnabled = true
    @State private var anonymousByDefault = true
    
    var body: some View {
        NavigationView {
            List {
                Section("Privacy") {
                    Toggle("Allow Location Access", isOn: $locationEnabled)
                    Toggle("Anonymous Mode by Default", isOn: $anonymousByDefault)
                }
                
                Section("Notifications") {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        NavigationLink("Notification Settings") {
                            Text("Detailed notification settings")
                        }
                    }
                }
                
                Section("Account") {
                    Button("Sign Out") {}
                        .foregroundColor(.red)
                    
                    Button("Delete Account") {}
                        .foregroundColor(.red)
                }
                
                Section("App") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // App icon and info
                    VStack(spacing: 16) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.whisperBlue)
                        
                        VStack(spacing: 8) {
                            Text("Room Whisper")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Version 1.0.0")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Connect with your campus community")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    
                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About Room Whisper")
                            .font(.headline)
                        
                        Text("Room Whisper is a location-based social network designed specifically for college campuses. Share anonymous thoughts, discover what's happening in your building, and stay connected with official updates from staff and administration.")
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Features include anonymous posting, verified official updates, mood tagging, real-time activity tracking, and a unique memory layer that preserves campus culture for future students.")
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Contact info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contact & Support")
                            .font(.headline)
                        
                        Link("Privacy Policy", destination: URL(string: "https://roomwhisper.app/privacy")!)
                            .foregroundColor(.whisperBlue)
                        
                        Link("Terms of Service", destination: URL(string: "https://roomwhisper.app/terms")!)
                            .foregroundColor(.whisperBlue)
                        
                        Link("Support", destination: URL(string: "mailto:support@roomwhisper.app")!)
                            .foregroundColor(.whisperBlue)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FutureWhispersView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let futureWhispers = [
        FutureWhisper(
            id: "1",
            buildingId: "1",
            content: "Good luck with finals! The study room on floor 3 is the best spot for late-night cramming. ☕️📚",
            createdAt: Date().addingTimeInterval(-86400 * 7),
            deliveryDate: Date().addingTimeInterval(86400 * 120),
            targetAudience: "Future residents"
        ),
        FutureWhisper(
            id: "2",
            buildingId: "2",
            content: "Pro tip: The vending machine on floor 2 sometimes gives free snacks if you press B4 twice! 🤫",
            createdAt: Date().addingTimeInterval(-86400 * 14),
            deliveryDate: Date().addingTimeInterval(86400 * 90),
            targetAudience: "Next semester students"
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if futureWhispers.isEmpty {
                        EmptyStateView(
                            icon: "clock.arrow.circlepath",
                            title: "No Future Whispers",
                            subtitle: "You haven't created any messages for future residents yet."
                        )
                    } else {
                        ForEach(futureWhispers) { whisper in
                            FutureWhisperCard(whisper: whisper)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Future Whispers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FutureWhisperCard: View {
    let whisper: FutureWhisper
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.whisperYellow)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Future Whisper")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.whisperYellow)
                    
                    Text("Delivers \(whisper.deliveryDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(whisper.isDelivered ? "Delivered" : "Pending")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        whisper.isDelivered ? Color.green : Color.orange,
                        in: RoundedRectangle(cornerRadius: 8)
                    )
            }
            
            Text(whisper.content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Text("Target: \(whisper.targetAudience)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Created \(whisper.createdAt.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.whisperYellow.opacity(0.3), lineWidth: 1)
        )
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
        .environmentObject(LocationManager())
}