import SwiftUI
import MapKit

struct CampusMapView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationManager: LocationManager
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7580, longitude: -73.9855),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var showingBuildingDetail = false
    @State private var selectedBuilding: Building?
    
    // Sample buildings data
    private let buildings = [
        Building(id: "1", name: "Smith Hall", coordinate: .init(latitude: 40.7580, longitude: -73.9855), activeUsers: 24, whisperCount: 156),
        Building(id: "2", name: "Johnson Library", coordinate: .init(latitude: 40.7590, longitude: -73.9845), activeUsers: 18, whisperCount: 89),
        Building(id: "3", name: "Davis Center", coordinate: .init(latitude: 40.7570, longitude: -73.9865), activeUsers: 31, whisperCount: 203),
        Building(id: "4", name: "Thompson Dining", coordinate: .init(latitude: 40.7585, longitude: -73.9875), activeUsers: 45, whisperCount: 312),
        Building(id: "5", name: "Wilson Gym", coordinate: .init(latitude: 40.7565, longitude: -73.9835), activeUsers: 12, whisperCount: 78)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: buildings) { building in
                    MapAnnotation(coordinate: building.coordinate) {
                        BuildingAnnotationView(building: building) {
                            selectedBuilding = building
                            showingBuildingDetail = true
                        }
                    }
                }
                .ignoresSafeArea()
                
                VStack {
                    // Header with location info
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Campus Explorer")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.whisperBlue)
                            
                            if let currentBuilding = locationManager.currentBuilding {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.whisperYellow)
                                    Text("Currently in \(currentBuilding.name)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                HStack {
                                    Image(systemName: "location.slash")
                                        .foregroundColor(.gray)
                                    Text("Location not detected")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            locationManager.requestLocation()
                        }) {
                            Image(systemName: "location.circle.fill")
                                .font(.title2)
                                .foregroundColor(.whisperBlue)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding()
                    
                    Spacer()
                    
                    // Active buildings summary
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(buildings.prefix(3)) { building in
                                BuildingSummaryCard(building: building) {
                                    selectedBuilding = building
                                    showingBuildingDetail = true
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedBuilding) { building in
            BuildingDetailView(building: building)
        }
    }
}

struct BuildingAnnotationView: View {
    let building: Building
    let onTap: () -> Void
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Outer glow effect
                Circle()
                    .fill(Color.whisperBlue.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .scaleEffect(pulseScale)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseScale)
                
                // Main building indicator
                Circle()
                    .fill(Color.whisperBlue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
                
                // Activity indicator
                VStack(spacing: 2) {
                    Text("\(building.activeUsers)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("online")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .onAppear {
            pulseScale = 1.2
        }
    }
}

struct BuildingSummaryCard: View {
    let building: Building
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(building.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.whisperYellow)
                        .frame(width: 8, height: 8)
                }
                
                HStack {
                    Label("\(building.activeUsers)", systemImage: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Label("\(building.whisperCount)", systemImage: "bubble.left.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(width: 160, height: 80)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct BuildingDetailView: View {
    let building: Building
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Hero section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(building.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            ActivityIndicator(count: building.activeUsers, icon: "person.2.fill", color: .whisperBlue)
                            ActivityIndicator(count: building.whisperCount, icon: "bubble.left.fill", color: .whisperYellow)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    
                    // Quick actions
                    HStack(spacing: 16) {
                        ActionButton(title: "View Whispers", icon: "bubble.left.fill", color: .whisperBlue) {
                            appState.selectedBuilding = building
                            appState.selectedTab = .whispers
                            dismiss()
                        }
                        
                        ActionButton(title: "Create Post", icon: "plus.circle.fill", color: .whisperYellow) {
                            appState.selectedBuilding = building
                            appState.selectedTab = .create
                            dismiss()
                        }
                    }
                    
                    // Recent activity preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(appState.whispers.filter { $0.buildingId == building.id }.prefix(3)) { whisper in
                                WhisperPreviewCard(whisper: whisper)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Building Details")
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

struct ActivityIndicator: View {
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text("\(count)")
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct WhisperPreviewCard: View {
    let whisper: Whisper
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(whisper.mood.rawValue)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(whisper.content)
                    .font(.body)
                    .lineLimit(2)
                
                HStack {
                    Text(whisper.timestamp.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Label("\(whisper.likes)", systemImage: "heart.fill")
                        Label("\(whisper.replies)", systemImage: "bubble.right.fill")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CampusMapView()
        .environmentObject(AppState())
        .environmentObject(LocationManager())
}