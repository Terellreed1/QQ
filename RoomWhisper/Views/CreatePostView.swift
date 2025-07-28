import SwiftUI

struct CreatePostView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var postContent = ""
    @State private var selectedMood: Whisper.Mood = .happy
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var isFutureWhisper = false
    @State private var deliveryDate = Date().addingTimeInterval(86400 * 30) // 30 days from now
    @State private var targetBuilding: Building?
    @State private var showingBuildingPicker = false
    @State private var isCreatingPoll = false
    @State private var pollQuestion = ""
    @State private var pollOptions = ["", ""]
    
    private let maxCharacters = 280
    
    var remainingCharacters: Int {
        maxCharacters - postContent.count
    }
    
    var canPost: Bool {
        !postContent.isEmpty && remainingCharacters >= 0 && targetBuilding != nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Post type toggle
                    PostTypeSelector(
                        isAnonymous: $appState.isAnonymousMode,
                        isFutureWhisper: $isFutureWhisper,
                        isCreatingPoll: $isCreatingPoll
                    )
                    
                    // Building selector
                    BuildingSelector(selectedBuilding: $targetBuilding) {
                        showingBuildingPicker = true
                    }
                    
                    if isCreatingPoll {
                        PollCreationView(
                            question: $pollQuestion,
                            options: $pollOptions
                        )
                    } else {
                        // Regular post creation
                        PostCreationView(
                            content: $postContent,
                            selectedMood: $selectedMood,
                            tags: $tags,
                            isFutureWhisper: isFutureWhisper,
                            deliveryDate: $deliveryDate,
                            remainingCharacters: remainingCharacters
                        )
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle(isCreatingPoll ? "Create Poll" : (isFutureWhisper ? "Future Whisper" : "New Whisper"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isCreatingPoll ? "Post Poll" : "Post") {
                        createPost()
                    }
                    .disabled(!canPost)
                    .fontWeight(.semibold)
                    .foregroundColor(canPost ? .whisperBlue : .gray)
                }
            }
        }
        .sheet(isPresented: $showingBuildingPicker) {
            BuildingPickerView(selectedBuilding: $targetBuilding)
        }
    }
    
    private func createPost() {
        guard let building = targetBuilding else { return }
        
        if isCreatingPoll {
            let poll = Poll(
                id: UUID().uuidString,
                buildingId: building.id,
                question: pollQuestion,
                options: pollOptions.filter { !$0.isEmpty },
                votes: Array(repeating: 0, count: pollOptions.filter { !$0.isEmpty }.count),
                createdBy: appState.isAnonymousMode ? "Anonymous" : "User",
                expiresAt: Date().addingTimeInterval(86400 * 7) // 7 days
            )
            appState.polls.append(poll)
        } else {
            let whisper = Whisper(
                id: UUID().uuidString,
                buildingId: building.id,
                content: postContent,
                mood: selectedMood,
                timestamp: Date(),
                likes: 0,
                replies: 0,
                tags: tags,
                isFutureWhisper: isFutureWhisper,
                deliveryDate: isFutureWhisper ? deliveryDate : nil
            )
            appState.addWhisper(whisper)
        }
        
        // Switch to the appropriate tab to see the post
        if appState.isAnonymousMode {
            appState.selectedTab = .whispers
        } else {
            appState.selectedTab = .verified
        }
        
        dismiss()
    }
}

struct PostTypeSelector: View {
    @Binding var isAnonymous: Bool
    @Binding var isFutureWhisper: Bool
    @Binding var isCreatingPoll: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Post Type")
                .font(.headline)
            
            // Anonymous vs Verified toggle
            HStack {
                Button(action: { isAnonymous = true }) {
                    PostTypeButton(
                        title: "Anonymous",
                        subtitle: "Post anonymously",
                        icon: "theatermasks.fill",
                        isSelected: isAnonymous
                    )
                }
                
                Button(action: { isAnonymous = false }) {
                    PostTypeButton(
                        title: "Verified",
                        subtitle: "Post with identity",
                        icon: "checkmark.shield.fill",
                        isSelected: !isAnonymous
                    )
                }
            }
            
            // Special post types
            VStack(spacing: 8) {
                ToggleRow(
                    title: "Future Whisper",
                    subtitle: "Send a message to future residents",
                    icon: "clock.arrow.circlepath",
                    isOn: $isFutureWhisper
                )
                
                ToggleRow(
                    title: "Create Poll",
                    subtitle: "Ask the community a question",
                    icon: "chart.bar.fill",
                    isOn: $isCreatingPoll
                )
            }
        }
    }
}

struct PostTypeButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? .white : .whisperBlue)
            
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            isSelected ? Color.whisperBlue : Color.gray.opacity(0.1),
            in: RoundedRectangle(cornerRadius: 12)
        )
    }
}

struct ToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.whisperBlue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct BuildingSelector: View {
    @Binding var selectedBuilding: Building?
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target Building")
                .font(.headline)
            
            Button(action: onTap) {
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.whisperBlue)
                    
                    Text(selectedBuilding?.name ?? "Select a building")
                        .foregroundColor(selectedBuilding != nil ? .primary : .secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

struct PostCreationView: View {
    @Binding var content: String
    @Binding var selectedMood: Whisper.Mood
    @Binding var tags: [String]
    let isFutureWhisper: Bool
    @Binding var deliveryDate: Date
    let remainingCharacters: Int
    
    @State private var newTag = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Mood selector
            VStack(alignment: .leading, spacing: 12) {
                Text("Mood")
                    .font(.headline)
                
                MoodSelector(selectedMood: $selectedMood)
            }
            
            // Content input
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Your Message")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(remainingCharacters)")
                        .font(.caption)
                        .foregroundColor(remainingCharacters < 20 ? .red : .secondary)
                }
                
                TextField("What's happening in your building?", text: $content, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(4...10)
            }
            
            // Tags
            VStack(alignment: .leading, spacing: 12) {
                Text("Tags (Optional)")
                    .font(.headline)
                
                if !tags.isEmpty {
                    TagsView(tags: $tags)
                }
                
                HStack {
                    TextField("Add a tag", text: $newTag)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            addTag()
                        }
                    
                    Button("Add", action: addTag)
                        .disabled(newTag.isEmpty)
                }
            }
            
            // Future whisper date picker
            if isFutureWhisper {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Delivery Date")
                        .font(.headline)
                    
                    DatePicker(
                        "When should this whisper be delivered?",
                        selection: $deliveryDate,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                }
            }
        }
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) && tags.count < 5 {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
}

struct PollCreationView: View {
    @Binding var question: String
    @Binding var options: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Poll Question")
                    .font(.headline)
                
                TextField("What would you like to ask?", text: $question, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Answer Options")
                        .font(.headline)
                    
                    Spacer()
                    
                    if options.count < 6 {
                        Button("Add Option") {
                            options.append("")
                        }
                        .font(.caption)
                        .foregroundColor(.whisperBlue)
                    }
                }
                
                ForEach(options.indices, id: \.self) { index in
                    HStack {
                        TextField("Option \(index + 1)", text: $options[index])
                            .textFieldStyle(.roundedBorder)
                        
                        if options.count > 2 {
                            Button(action: { options.remove(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TagsView: View {
    @Binding var tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    HStack(spacing: 4) {
                        Text("#\(tag)")
                            .font(.caption)
                            .foregroundColor(.whisperBlue)
                        
                        Button(action: { removeTag(tag) }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.whisperBlue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
}

struct BuildingPickerView: View {
    @Binding var selectedBuilding: Building?
    @Environment(\.dismiss) private var dismiss
    
    // Sample buildings
    private let buildings = [
        Building(id: "1", name: "Smith Hall", coordinate: .init(latitude: 40.7580, longitude: -73.9855), activeUsers: 24, whisperCount: 156),
        Building(id: "2", name: "Johnson Library", coordinate: .init(latitude: 40.7590, longitude: -73.9845), activeUsers: 18, whisperCount: 89),
        Building(id: "3", name: "Davis Center", coordinate: .init(latitude: 40.7570, longitude: -73.9865), activeUsers: 31, whisperCount: 203),
        Building(id: "4", name: "Thompson Dining", coordinate: .init(latitude: 40.7585, longitude: -73.9875), activeUsers: 45, whisperCount: 312),
        Building(id: "5", name: "Wilson Gym", coordinate: .init(latitude: 40.7565, longitude: -73.9835), activeUsers: 12, whisperCount: 78)
    ]
    
    var body: some View {
        NavigationView {
            List(buildings) { building in
                Button(action: {
                    selectedBuilding = building
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(building.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Label("\(building.activeUsers)", systemImage: "person.2.fill")
                                Label("\(building.whisperCount)", systemImage: "bubble.left.fill")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedBuilding?.id == building.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.whisperBlue)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Select Building")
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

#Preview {
    CreatePostView()
        .environmentObject(AppState())
        .environmentObject(LocationManager())
}