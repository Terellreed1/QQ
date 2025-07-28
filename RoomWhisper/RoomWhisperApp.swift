import SwiftUI

@main
struct RoomWhisperApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(locationManager)
                .preferredColorScheme(.light)
        }
    }
}