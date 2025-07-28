import SwiftUI

struct WhisperFeedView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedMoodFilter: Whisper.Mood?
    @State private var showingMemoryLayer = false
    @State private var searchText = ""
    
    var filteredWhispers: [Whisper] {
        var whispers = appState.whispers
        
        // Filter by selected building if any
        if let building = appState.selectedBuilding {
            whispers = whispers.filter { $0.buildingId == building.id }
        }
        
        // Filter by mood if selected
        if let mood = selectedMoodFilter {
            whispers = whispers.filter { $0.mood == mood }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            whispers = whispers.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
        
        return whispers
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with mode toggle and filters
                VStack(spacing: 16) {
                    HStack {
                        Text("Whispers")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: { showingMemoryLayer.toggle() }) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title3)
                                .foregroundColor(.whisperBlue)
                        }
                    }
                    
                    ModeToggle(isAnonymous: $appState.isAnonymousMode)
                    
                    MoodFilterBar(selectedMood: $selectedMoodFilter)
                }
                .padding()
                .background(.ultraThinMaterial)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search whispers...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Whispers list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredWhispers) { whisper in
                            WhisperCard(whisper: whisper) {
                                appState.toggleLike(for: whisper.id)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingMemoryLayer) {
            MemoryLayerView()
        }
    }
}

struct ModeToggle: View {
    @Binding var isAnonymous: Bool
    
    var body: some View {
        HStack {
            Button(action: { isAnonymous = true }) {
                HStack {
                    Image(systemName: "theatermasks.fill")
                    Text("Anonymous")
                        .fontWeight(.medium)
                }
                .foregroundColor(isAnonymous ? .white : .whisperBlue)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    isAnonymous ? Color.whisperBlue : Color.clear,
                    in: RoundedRectangle(cornerRadius: 20)
                )
            }
            
            Button(action: { isAnonymous = false }) {
                HStack {
                    Image(systemName: "person.circle.fill")
                    Text("Verified")
                        .fontWeight(.medium)
                }
                .foregroundColor(!isAnonymous ? .white : .whisperBlue)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    !isAnonymous ? Color.whisperBlue : Color.clear,
                    in: RoundedRectangle(cornerRadius: 20)
                )
            }
        }
        .padding(4)
        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 24))
    }
}

struct MoodFilterBar: View {
    @Binding var selectedMood: Whisper.Mood?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button(action: { selectedMood = nil }) {
                    Text("All")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(selectedMood == nil ? .white : .gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            selectedMood == nil ? Color.whisperBlue : Color.gray.opacity(0.2),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                }
                
                ForEach(Whisper.Mood.allCases, id: \.self) { mood in
                    Button(action: { selectedMood = selectedMood == mood ? nil : mood }) {
                        HStack(spacing: 4) {
                            Text(mood.rawValue)
                            Text(mood.name)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(selectedMood == mood ? .white : .gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            selectedMood == mood ? Color.whisperBlue : Color.gray.opacity(0.2),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct WhisperCard: View {
    let whisper: Whisper
    let onLike: () -> Void
    @State private var showingReplySheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with mood and timestamp
            HStack {
                HStack(spacing: 8) {
                    Text(whisper.mood.rawValue)
                        .font(.title2)
                    
                    Text(whisper.mood.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                }
                
                Spacer()
                
                Text(whisper.timestamp.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Content
            Text(whisper.content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            // Tags if any
            if !whisper.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(whisper.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .foregroundColor(.whisperBlue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.whisperBlue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Actions
            HStack(spacing: 24) {
                Button(action: onLike) {
                    HStack(spacing: 4) {
                        Image(systemName: whisper.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(whisper.isLiked ? .red : .gray)
                        Text("\(whisper.likes)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: { showingReplySheet = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.gray)
                        Text("\(whisper.replies)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .sheet(isPresented: $showingReplySheet) {
            ReplyView(whisper: whisper)
        }
    }
}

struct ReplyView: View {
    let whisper: Whisper
    @Environment(\.dismiss) private var dismiss
    @State private var replyText = ""
    @State private var selectedMood: Whisper.Mood = .happy
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Original whisper
                Text("Replying to:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                WhisperCard(whisper: whisper) {}
                    .disabled(true)
                
                // Reply composition
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Reply")
                        .font(.headline)
                    
                    MoodSelector(selectedMood: $selectedMood)
                    
                    TextField("Write your reply...", text: $replyText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Reply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        // Add reply logic here
                        dismiss()
                    }
                    .disabled(replyText.isEmpty)
                }
            }
        }
    }
}

struct MoodSelector: View {
    @Binding var selectedMood: Whisper.Mood
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Whisper.Mood.allCases, id: \.self) { mood in
                    Button(action: { selectedMood = mood }) {
                        VStack(spacing: 4) {
                            Text(mood.rawValue)
                                .font(.title2)
                            Text(mood.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(selectedMood == mood ? .white : .primary)
                        .padding(8)
                        .background(
                            selectedMood == mood ? Color.whisperBlue : Color.gray.opacity(0.2),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MemoryLayerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSemester = "Fall 2024"
    
    private let semesters = ["Fall 2024", "Spring 2024", "Fall 2023", "Spring 2023"]
    private let memoryEntries = [
        MemoryEntry(id: "1", buildingId: "1", content: "Finals week stress eating in the common room - we're all in this together! 🍕📚", timestamp: Date().addingTimeInterval(-86400 * 30), likes: 23, mood: .stressed, semester: "Fall", academicYear: "2024"),
        MemoryEntry(id: "2", buildingId: "1", content: "Snow day! Building snowmen in the courtyard instead of studying ⛄️", timestamp: Date().addingTimeInterval(-86400 * 120), likes: 45, mood: .excited, semester: "Spring", academicYear: "2024")
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Memory Layer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Discover the history and culture of your building through past whispers.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Semester picker
                Picker("Semester", selection: $selectedSemester) {
                    ForEach(semesters, id: \.self) { semester in
                        Text(semester).tag(semester)
                    }
                }
                .pickerStyle(.segmented)
                
                // Memory entries
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(memoryEntries) { entry in
                            MemoryEntryCard(entry: entry)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Building History")
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

struct MemoryEntryCard: View {
    let entry: MemoryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(entry.mood.rawValue)
                    .font(.title2)
                
                Text("\(entry.semester) \(entry.academicYear)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.whisperYellow.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                
                Spacer()
                
                Text(entry.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(entry.content)
                .font(.body)
            
            HStack {
                Label("\(entry.likes)", systemImage: "heart.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("📚 Archived Memory")
                    .font(.caption2)
                    .foregroundColor(.whisperBlue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.whisperBlue.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
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

#Preview {
    WhisperFeedView()
        .environmentObject(AppState())
        .environmentObject(LocationManager())
}