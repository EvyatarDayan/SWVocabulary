import SwiftUI

struct HistoryView: View {
    @StateObject private var testHistoryManager = TestHistoryManager.shared
    @StateObject private var practiceHistoryManager = PracticeHistoryManager.shared
    @State private var selectedItem: UnifiedHistoryItem?
    @State private var selectedFilter: FilterOption = .all
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    // Optional filter to show only test or practice items (used when opened from other views)
    var filterType: HistoryItemType? = nil
    
    // Callbacks when an item is selected (used when History is the main tab to switch and load)
    var onSelectTest: ((TestHistoryItem) -> Void)? = nil
    var onSelectPractice: ((PracticeHistoryItem) -> Void)? = nil
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case practices = "Practices"
        case tests = "Tests"
    }
    
    private var allHistoryItems: [UnifiedHistoryItem] {
        var items: [UnifiedHistoryItem] = []
        
        // Determine which items to show based on filterType (from parameter) or selectedFilter (from UI)
        let effectiveFilter: HistoryItemType?
        if let filterType = filterType {
            // If filterType is set (from parameter), use it
            effectiveFilter = filterType
        } else {
            // Otherwise, use the selectedFilter from UI
            switch selectedFilter {
            case .all:
                effectiveFilter = nil
            case .practices:
                effectiveFilter = .practice
            case .tests:
                effectiveFilter = .test
            }
        }
        
        // Add test items (only if no filter or filter is .test)
        if effectiveFilter == nil || effectiveFilter == .test {
            items.append(contentsOf: testHistoryManager.historyItems.map { UnifiedHistoryItem(testItem: $0) })
        }
        
        // Add practice items (only if no filter or filter is .practice)
        if effectiveFilter == nil || effectiveFilter == .practice {
            items.append(contentsOf: practiceHistoryManager.historyItems.map { UnifiedHistoryItem(practiceItem: $0) })
        }
        
        // Sort by date (most recent first)
        return items.sorted { $0.dateTaken > $1.dateTaken }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title - matching TestView and PracticeView style
            ZStack {
                // Centered title - separate for each case with individual padding control
                if filterType == .practice {
                    HStack {
                        Spacer()
                        Text("Practice History")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                } else if filterType == .test {
                    HStack {
                        Spacer()
                        Text("Test History")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                    .padding(.bottom, 20)
                } else {
                    HStack {
                        Spacer()
                        Text("History")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 65)
                    .padding(.bottom, 20)
                }
                
                // Close button - aligned to right (only show when used as modal, i.e., when filterType is set)
                if filterType != nil {
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Close")
                                .font(.body)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 5)
                    .padding(.bottom, 20)
                }
            }
            
            // Filter picker (show when filterType is nil, even if there are no history items)
            if filterType == nil {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(FilterOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            
            // Content
            contentView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var contentView: some View {
        if allHistoryItems.isEmpty {
            emptyStateView
        } else {
            resultsListView
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No History Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text(emptyStateMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 20)
        .padding(.bottom, 55) // leave room for tab bar
        .padding(.horizontal, 20)
    }
    
    private var resultsListView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(allHistoryItems) { item in
                    Button(action: {
                        selectedItem = item
                        if item.type == .test, let testItem = item.testItem {
                            onSelectTest?(testItem)
                            if filterType != nil { dismiss() }
                        } else if item.type == .practice, let practiceItem = item.practiceItem {
                            onSelectPractice?(practiceItem)
                            if filterType != nil { dismiss() }
                        }
                    }) {
                        HistoryResultRow(
                            item: item,
                            isAnimating: false,
                            filterType: filterType
                        )
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.bottom, 55) // Add padding for menu
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var emptyStateMessage: String {
        switch filterType {
        case .test:
            return "Complete a test to see your results here"
        case .practice:
            return "Complete a practice session to see your results here"
        case .none:
            return "Complete a test or practice session to see your results here"
        }
    }
}

struct HistoryResultRow: View {
    let item: UnifiedHistoryItem
    let isAnimating: Bool
    let filterType: HistoryItemType?
    @Environment(\.colorScheme) var colorScheme
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy 'at' HH:mm"
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Test type and date on same line (hide type text if filtered to single type)
            HStack(spacing: 6) {
                // Only show type text if not filtered to a single type
                if filterType == nil {
                    Text(item.type == .test ? "Test" : "Practice")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    Text("•")
                        .foregroundColor(.secondary)
                }
                
                Text(dateFormatter.string(from: item.dateTaken))
                    .font(.body)
                    .fontWeight(.medium)
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
        
            // Display text information with colored parts (same format for both test and practice)
            let questions = item.total
            let correct = item.score
            let wrong = item.total - item.score
            let percentage = item.total > 0 ? Int((Double(item.score) / Double(item.total)) * 100) : 0
            
            makeStyledPracticeText(
                questions: questions,
                correct: correct,
                wrong: wrong,
                percentage: percentage
            )
            .multilineTextAlignment(.center)
        }
        .padding(16)
        .background(colorScheme == .dark ? Color(.systemGray5) : Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 20)
        .scaleEffect(isAnimating ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.5), value: isAnimating)
    }
    
    // Helper function to create styled practice text with colors
    private func makeStyledPracticeText(questions: Int, correct: Int, wrong: Int, percentage: Int) -> Text {
        // Build AttributedString with different styles - all bold, smaller font
        // Dashes are black, text parts are colored
        
        // "Questions: X"
        var attributedString = AttributedString("Questions: \(questions)")
        attributedString.font = .system(size: 13, weight: .bold)
        attributedString.foregroundColor = .primary
        
        // " - " (black dash)
        var dash1 = AttributedString(" - ")
        dash1.font = .system(size: 13, weight: .bold)
        dash1.foregroundColor = .primary
        attributedString.append(dash1)
        
        // "Correct: X" in green (bold)
        var correctAttr = AttributedString("Correct: \(correct)")
        correctAttr.font = .system(size: 13, weight: .bold)
        correctAttr.foregroundColor = .green
        attributedString.append(correctAttr)
        
        // " - " (black dash)
        var dash2 = AttributedString(" - ")
        dash2.font = .system(size: 13, weight: .bold)
        dash2.foregroundColor = .primary
        attributedString.append(dash2)
        
        // "Wrong: X" in red (bold)
        var wrongAttr = AttributedString("Wrong: \(wrong)")
        wrongAttr.font = .system(size: 13, weight: .bold)
        wrongAttr.foregroundColor = .red
        attributedString.append(wrongAttr)
        
        // " - " (black dash)
        var dash3 = AttributedString(" - ")
        dash3.font = .system(size: 13, weight: .bold)
        dash3.foregroundColor = .primary
        attributedString.append(dash3)
        
        // "X%" in bold (black)
        var percentageAttr = AttributedString("\(percentage)%")
        percentageAttr.font = .system(size: 13, weight: .bold)
        percentageAttr.foregroundColor = .primary
        attributedString.append(percentageAttr)
        
        return Text(attributedString)
    }
}

#Preview {
    HistoryView()
}
