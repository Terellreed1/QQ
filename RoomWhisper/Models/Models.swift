import Foundation
import CoreLocation

// MARK: - User
struct User: Identifiable, Codable {
    let id: String
    var username: String
    var email: String
    var isVerified: Bool
    var role: UserRole?
    var joinedDate: Date
    var favoriteBuildings: [String]
    
    enum UserRole: String, Codable, CaseIterable {
        case student = "Student"
        case ra = "Resident Advisor"
        case faculty = "Faculty"
        case staff = "Staff"
        case admin = "Administrator"
    }
}

// MARK: - Building
struct Building: Identifiable, Codable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    var activeUsers: Int
    var whisperCount: Int
    var description: String?
    var imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, activeUsers, whisperCount, description, imageURL
        case latitude, longitude
    }
    
    init(id: String, name: String, coordinate: CLLocationCoordinate2D, activeUsers: Int, whisperCount: Int, description: String? = nil, imageURL: String? = nil) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.activeUsers = activeUsers
        self.whisperCount = whisperCount
        self.description = description
        self.imageURL = imageURL
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        activeUsers = try container.decode(Int.self, forKey: .activeUsers)
        whisperCount = try container.decode(Int.self, forKey: .whisperCount)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(activeUsers, forKey: .activeUsers)
        try container.encode(whisperCount, forKey: .whisperCount)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
}

// MARK: - Whisper
struct Whisper: Identifiable, Codable {
    let id: String
    let buildingId: String
    var content: String
    var mood: Mood
    var timestamp: Date
    var likes: Int
    var replies: Int
    var isLiked: Bool = false
    var tags: [String] = []
    var isFutureWhisper: Bool = false
    var deliveryDate: Date?
    
    enum Mood: String, Codable, CaseIterable {
        case happy = "😊"
        case excited = "🎉"
        case chill = "😎"
        case focused = "📚"
        case tired = "😴"
        case confused = "🤔"
        case stressed = "😰"
        case grateful = "🙏"
        
        var color: String {
            switch self {
            case .happy: return "yellow"
            case .excited: return "orange"
            case .chill: return "blue"
            case .focused: return "green"
            case .tired: return "purple"
            case .confused: return "gray"
            case .stressed: return "red"
            case .grateful: return "pink"
            }
        }
        
        var name: String {
            switch self {
            case .happy: return "Happy"
            case .excited: return "Excited"
            case .chill: return "Chill"
            case .focused: return "Focused"
            case .tired: return "Tired"
            case .confused: return "Confused"
            case .stressed: return "Stressed"
            case .grateful: return "Grateful"
            }
        }
    }
}

// MARK: - Verified Post
struct VerifiedPost: Identifiable, Codable {
    let id: String
    let buildingId: String
    var title: String
    var content: String
    var authorName: String
    var authorRole: String
    var timestamp: Date
    var isPinned: Bool
    var category: Category
    var attachments: [String] = []
    
    enum Category: String, Codable, CaseIterable {
        case announcement = "Announcement"
        case safety = "Safety"
        case maintenance = "Maintenance"
        case event = "Event"
        case academic = "Academic"
        case emergency = "Emergency"
        
        var color: String {
            switch self {
            case .announcement: return "blue"
            case .safety: return "red"
            case .maintenance: return "orange"
            case .event: return "purple"
            case .academic: return "green"
            case .emergency: return "red"
            }
        }
        
        var icon: String {
            switch self {
            case .announcement: return "megaphone.fill"
            case .safety: return "shield.fill"
            case .maintenance: return "wrench.fill"
            case .event: return "calendar.badge.plus"
            case .academic: return "book.fill"
            case .emergency: return "exclamationmark.triangle.fill"
            }
        }
    }
}

// MARK: - Poll
struct Poll: Identifiable, Codable {
    let id: String
    let buildingId: String
    var question: String
    var options: [String]
    var votes: [Int]
    var createdBy: String
    var expiresAt: Date
    var hasVoted: Bool = false
    
    var totalVotes: Int {
        votes.reduce(0, +)
    }
    
    var isExpired: Bool {
        Date() > expiresAt
    }
}

// MARK: - Memory Layer Entry
struct MemoryEntry: Identifiable, Codable {
    let id: String
    let buildingId: String
    var content: String
    var timestamp: Date
    var likes: Int
    var mood: Whisper.Mood
    var isArchived: Bool = true
    var semester: String
    var academicYear: String
}

// MARK: - Future Whisper
struct FutureWhisper: Identifiable, Codable {
    let id: String
    let buildingId: String
    var content: String
    var createdAt: Date
    var deliveryDate: Date
    var targetAudience: String // e.g., "Future residents", "Next semester students"
    var isDelivered: Bool = false
}