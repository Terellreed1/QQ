import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            CampusMapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Campus")
                }
                .tag(Tab.campus)
            
            WhisperFeedView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Whispers")
                }
                .tag(Tab.whispers)
            
            CreatePostView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Create")
                }
                .tag(Tab.create)
            
            VerifiedZoneView()
                .tabItem {
                    Image(systemName: "checkmark.shield.fill")
                    Text("Official")
                }
                .tag(Tab.verified)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(Tab.profile)
        }
        .accentColor(.whisperBlue)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.whisperBlue)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.whisperBlue)
        ]
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(LocationManager())
}