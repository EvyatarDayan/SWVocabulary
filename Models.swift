import Foundation

struct Example: Codable, Equatable {
    let sv: String
    let en: String
}

struct TestWord: Codable, Identifiable, Equatable {
    let id: Int
    let swedish: String
    let english: String
    let sentence: String?
    let example: Example?
    
    init(id: Int, swedish: String, english: String, sentence: String? = nil, example: Example? = nil) {
        self.id = id
        self.swedish = swedish
        self.english = english
        self.sentence = sentence
        self.example = example
    }
    
    // Convenience initializer for creating words without full data
    init(swedish: String, english: String) {
        self.id = 0
        self.swedish = swedish
        self.english = english
        self.sentence = nil
        self.example = nil
    }
}

struct TestWordItemData: Codable, Identifiable, Equatable {
    let id: UUID
    let wordId: Int
    let swedish: String
    let english: String
    let userAnswer: String
    let isCorrect: Bool
    
    init(wordId: Int, swedish: String, english: String, userAnswer: String, isCorrect: Bool) {
        self.id = UUID()
        self.wordId = wordId
        self.swedish = swedish
        self.english = english
        self.userAnswer = userAnswer
        self.isCorrect = isCorrect
    }
}

struct TestHistoryItem: Codable, Identifiable, Equatable {
    let id: UUID
    let dateTaken: Date
    let words: [TestWordItemData]
    let score: Int
    let total: Int
    
    init(dateTaken: Date, words: [TestWordItemData], score: Int, total: Int) {
        self.id = UUID()
        self.dateTaken = dateTaken
        self.words = words
        self.score = score
        self.total = total
    }
}

struct WrongAnswerWord: Codable, Identifiable, Equatable {
    let id: UUID
    let swedish: String
    let english: String
    var correctCount: Int
    var wrongCount: Int
    
    init(swedish: String, english: String, correctCount: Int = 0, wrongCount: Int = 0) {
        self.id = UUID()
        self.swedish = swedish
        self.english = english
        self.correctCount = correctCount
        self.wrongCount = wrongCount
    }
}

struct PracticeProgressData: Codable {
    let wordId: Int
    let swedish: String
    let english: String
    let correctAnswer: String
    let options: [String]
    let selectedAnswer: String
    let showFeedback: Bool
    let isCorrect: Bool
    let questionCount: Int
    let isFromWrongAnswers: Bool
    let showWhy: Bool
    let exampleLanguage: String
}

struct PracticeHistoryItem: Codable, Identifiable, Equatable {
    let id: UUID
    let dateTaken: Date
    let questions: Int
    let correct: Int
    let wrong: Int
    let successPercentage: Int
    
    init(dateTaken: Date, questions: Int, correct: Int, wrong: Int, successPercentage: Int) {
        self.id = UUID()
        self.dateTaken = dateTaken
        self.questions = questions
        self.correct = correct
        self.wrong = wrong
        self.successPercentage = successPercentage
    }
}

// Unified history item that can represent both test and practice
enum HistoryItemType: String, Codable {
    case test
    case practice
}

struct UnifiedHistoryItem: Identifiable, Equatable {
    let id: UUID
    let type: HistoryItemType
    let dateTaken: Date
    let score: Int
    let total: Int
    
    // Test-specific
    let testItem: TestHistoryItem?
    
    // Practice-specific
    let practiceItem: PracticeHistoryItem?
    
    init(testItem: TestHistoryItem) {
        self.id = testItem.id
        self.type = .test
        self.dateTaken = testItem.dateTaken
        self.score = testItem.score
        self.total = testItem.total
        self.testItem = testItem
        self.practiceItem = nil
    }
    
    init(practiceItem: PracticeHistoryItem) {
        self.id = practiceItem.id
        self.type = .practice
        self.dateTaken = practiceItem.dateTaken
        self.score = practiceItem.correct
        self.total = practiceItem.questions
        self.testItem = nil
        self.practiceItem = practiceItem
    }
    
    static func == (lhs: UnifiedHistoryItem, rhs: UnifiedHistoryItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.type == rhs.type &&
               lhs.dateTaken == rhs.dateTaken &&
               lhs.score == rhs.score &&
               lhs.total == rhs.total
    }
}
