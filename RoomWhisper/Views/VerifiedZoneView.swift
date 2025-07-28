import SwiftUI

struct VerifiedZoneView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: VerifiedPost.Category?
    @State private var showingCreatePost = false
    @State private var searchText = ""
    
    var filteredPosts: [VerifiedPost] {
        var posts = appState.verifiedPosts
        
        // Filter by selected building if any
        if let building = appState.selectedBuilding {
            posts = posts.filter { $0.buildingId == building.id }
        }
        
        // Filter by category if selected
        if let category = selectedCategory {
            posts = posts.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            posts = posts.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort: pinned posts first, then by timestamp
        return posts.sorted { post1, post2 in
            if post1.isPinned && !post2.isPinned {
                return true
            } else if !post1.isPinned && post2.isPinned {
                return false
            } else {
                return post1.timestamp > post2.timestamp
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Official Zone")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Verified updates from staff and administration")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { showingCreatePost = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.whisperBlue)
                        }
                    }
                    
                    CategoryFilterBar(selectedCategory: $selectedCategory)
                }
                .padding()
                .background(.ultraThinMaterial)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search official posts...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Posts list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Active polls section
                        if !appState.polls.isEmpty {
                            PollsSection(polls: appState.polls.filter { !$0.isExpired })
                        }
                        
                        // Verified posts
                        ForEach(filteredPosts) { post in
                            VerifiedPostCard(post: post)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCreatePost) {
            CreateVerifiedPostView()
        }
    }
}

struct CategoryFilterBar: View {
    @Binding var selectedCategory: VerifiedPost.Category?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button(action: { selectedCategory = nil }) {
                    FilterChip(
                        title: "All",
                        icon: "list.bullet",
                        isSelected: selectedCategory == nil
                    )
                }
                
                ForEach(VerifiedPost.Category.allCases, id: \.self) { category in
                    Button(action: { selectedCategory = selectedCategory == category ? nil : category }) {
                        FilterChip(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: selectedCategory == category
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(isSelected ? .white : .gray)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            isSelected ? Color.whisperBlue : Color.gray.opacity(0.2),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}

struct PollsSection: View {
    let polls: [Poll]
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Polls")
                    .font(.headline)
                    .foregroundColor(.whisperBlue)
                
                Spacer()
                
                Text("\(polls.count) active")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach(polls) { poll in
                PollCard(poll: poll) { optionIndex in
                    appState.voteInPoll(pollId: poll.id, optionIndex: optionIndex)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct PollCard: View {
    let poll: Poll
    let onVote: (Int) -> Void
    @State private var selectedOption: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(poll.question)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
                        Text("by \(poll.createdBy)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Expires \(poll.expiresAt.formatted(.relative(presentation: .named)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.whisperYellow)
            }
            
            // Poll options
            VStack(spacing: 8) {
                ForEach(Array(poll.options.enumerated()), id: \.offset) { index, option in
                    PollOptionView(
                        option: option,
                        votes: poll.votes[index],
                        totalVotes: poll.totalVotes,
                        isSelected: selectedOption == index,
                        hasVoted: poll.hasVoted
                    ) {
                        if !poll.hasVoted {
                            selectedOption = index
                            onVote(index)
                        }
                    }
                }
            }
            
            // Total votes
            HStack {
                Text("\(poll.totalVotes) total votes")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !poll.hasVoted {
                    Text("Tap to vote")
                        .font(.caption)
                        .foregroundColor(.whisperBlue)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct PollOptionView: View {
    let option: String
    let votes: Int
    let totalVotes: Int
    let isSelected: Bool
    let hasVoted: Bool
    let onTap: () -> Void
    
    private var percentage: Double {
        guard totalVotes > 0 else { return 0 }
        return Double(votes) / Double(totalVotes)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(option)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if hasVoted || isSelected {
                    HStack(spacing: 4) {
                        Text("\(votes)")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Text("(\(Int(percentage * 100))%)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                    
                    if hasVoted || isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color.whisperBlue.opacity(0.3) : Color.whisperYellow.opacity(0.2))
                            .frame(width: max(0, CGFloat(percentage) * 200)) // Approximate width
                            .animation(.easeInOut(duration: 0.5), value: percentage)
                    }
                }
            )
        }
        .disabled(hasVoted)
        .buttonStyle(.plain)
    }
}

struct VerifiedPostCard: View {
    let post: VerifiedPost
    @State private var showingFullContent = false
    
    private var isLongContent: Bool {
        post.content.count > 200
    }
    
    private var displayContent: String {
        if showingFullContent || !isLongContent {
            return post.content
        } else {
            return String(post.content.prefix(200)) + "..."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with pin indicator
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        if post.isPinned {
                            Image(systemName: "pin.fill")
                                .foregroundColor(.whisperYellow)
                                .font(.caption)
                        }
                        
                        Text(post.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    HStack {
                        CategoryBadge(category: post.category)
                        
                        Spacer()
                        
                        Text(post.timestamp.formatted(.relative(presentation: .named)))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Content
            Text(displayContent)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            
            if isLongContent {
                Button(showingFullContent ? "Show Less" : "Show More") {
                    showingFullContent.toggle()
                }
                .font(.caption)
                .foregroundColor(.whisperBlue)
            }
            
            // Author info
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(post.authorRole)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    post.isPinned ? Color.whisperYellow.opacity(0.5) : Color.clear,
                    lineWidth: post.isPinned ? 2 : 0
                )
        )
    }
}

struct CategoryBadge: View {
    let category: VerifiedPost.Category
    
    var categoryColor: Color {
        switch category.color {
        case "blue": return .blue
        case "red": return .red
        case "orange": return .orange
        case "purple": return .purple
        case "green": return .green
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.caption2)
            Text(category.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(categoryColor, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct CreateVerifiedPostView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedCategory: VerifiedPost.Category = .announcement
    @State private var isPinned = false
    @State private var targetBuilding: Building?
    @State private var showingBuildingPicker = false
    
    var canPost: Bool {
        !title.isEmpty && !content.isEmpty && targetBuilding != nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Building selector
                    BuildingSelector(selectedBuilding: $targetBuilding) {
                        showingBuildingPicker = true
                    }
                    
                    // Category selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.headline)
                        
                        Menu {
                            ForEach(VerifiedPost.Category.allCases, id: \.self) { category in
                                Button(action: { selectedCategory = category }) {
                                    HStack {
                                        Image(systemName: category.icon)
                                        Text(category.rawValue)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                CategoryBadge(category: selectedCategory)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    // Title input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                        
                        TextField("Post title", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Content input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.headline)
                        
                        TextField("Post content", text: $content, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(4...10)
                    }
                    
                    // Pin toggle
                    Toggle("Pin this post", isOn: $isPinned)
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Create Official Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
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
        
        let post = VerifiedPost(
            id: UUID().uuidString,
            buildingId: building.id,
            title: title,
            content: content,
            authorName: "Staff Member", // In real app, get from current user
            authorRole: "Administrator",
            timestamp: Date(),
            isPinned: isPinned,
            category: selectedCategory
        )
        
        appState.verifiedPosts.insert(post, at: 0)
        dismiss()
    }
}

#Preview {
    VerifiedZoneView()
        .environmentObject(AppState())
        .environmentObject(LocationManager())
}