import SwiftUI
import Combine

enum Tab: String, CaseIterable {
    case campus, whispers, create, verified, profile
}

class AppState: ObservableObject {
    @Published var selectedTab: Tab = .campus
    @Published var selectedBuilding: Building?
    @Published var currentUser: User?
    @Published var isAnonymousMode: Bool = true
    @Published var whispers: [Whisper] = []
    @Published var verifiedPosts: [VerifiedPost] = []
    @Published var polls: [Poll] = []
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample buildings
        let buildings = [
            Building(id: "1", name: "Smith Hall", coordinate: .init(latitude: 40.7580, longitude: -73.9855), activeUsers: 24, whisperCount: 156),
            Building(id: "2", name: "Johnson Library", coordinate: .init(latitude: 40.7590, longitude: -73.9845), activeUsers: 18, whisperCount: 89),
            Building(id: "3", name: "Davis Center", coordinate: .init(latitude: 40.7570, longitude: -73.9865), activeUsers: 31, whisperCount: 203)
        ]
        
        // Sample whispers
        whispers = [
            Whisper(
                id: "1",
                buildingId: "1",
                content: "Anyone else notice the amazing sunset view from the 4th floor?",
                mood: .happy,
                timestamp: Date().addingTimeInterval(-3600),
                likes: 12,
                replies: 3
            ),
            Whisper(
                id: "2",
                buildingId: "1",
                content: "Study group forming for tomorrow's exam. DM if interested!",
                mood: .focused,
                timestamp: Date().addingTimeInterval(-7200),
                likes: 8,
                replies: 5
            ),
            Whisper(
                id: "3",
                buildingId: "2",
                content: "The coffee machine on floor 2 is finally working again! ☕️",
                mood: .excited,
                timestamp: Date().addingTimeInterval(-1800),
                likes: 15,
                replies: 2
            )
        ]
        
        // Sample verified posts
        verifiedPosts = [
            VerifiedPost(
                id: "1",
                buildingId: "1",
                title: "Fire Drill Scheduled",
                content: "Mandatory fire drill tomorrow at 2:00 PM. Please evacuate promptly when alarms sound.",
                authorName: "RA Johnson",
                authorRole: "Resident Advisor",
                timestamp: Date().addingTimeInterval(-3600),
                isPinned: true,
                category: .safety
            ),
            VerifiedPost(
                id: "2",
                buildingId: "1",
                title: "Laundry Room Maintenance",
                content: "Washers 3 and 4 will be out of service this weekend for repairs.",
                authorName: "Facilities Team",
                authorRole: "Maintenance",
                timestamp: Date().addingTimeInterval(-7200),
                isPinned: false,
                category: .maintenance
            )
        ]
        
        // Sample polls
        polls = [
            Poll(
                id: "1",
                buildingId: "1",
                question: "What time should we have the floor movie night?",
                options: ["7 PM", "8 PM", "9 PM"],
                votes: [12, 18, 8],
                createdBy: "Floor Representative",
                expiresAt: Date().addingTimeInterval(86400)
            )
        ]
    }
    
    func addWhisper(_ whisper: Whisper) {
        whispers.insert(whisper, at: 0)
    }
    
    func toggleLike(for whisperId: String) {
        if let index = whispers.firstIndex(where: { $0.id == whisperId }) {
            whispers[index].likes += whispers[index].isLiked ? -1 : 1
            whispers[index].isLiked.toggle()
        }
    }
    
    func voteInPoll(pollId: String, optionIndex: Int) {
        if let index = polls.firstIndex(where: { $0.id == pollId }) {
            polls[index].votes[optionIndex] += 1
        }
    }
}