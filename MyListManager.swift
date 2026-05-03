import Foundation
import Combine

struct MyListWord: Identifiable, Codable {
    let id: UUID
    let swedish: String
    let english: String
    let dateAdded: Date
    
    init(swedish: String, english: String) {
        self.id = UUID()
        self.swedish = swedish
        self.english = english
        self.dateAdded = Date()
    }
}

class MyListManager: ObservableObject {
    static let shared = MyListManager()
    
    @Published private var myListWords: [MyListWord] = []
    
    private let myListKey = "myListWords"
    
    private init() {
        loadMyList()
    }
    
    func addToMyList(swedish: String, english: String) {
        // Check if word already exists
        if !myListWords.contains(where: { word in
            word.swedish.lowercased() == swedish.lowercased() &&
            word.english.lowercased() == english.lowercased()
        }) {
            let newWord = MyListWord(swedish: swedish, english: english)
            myListWords.append(newWord)
            saveMyList()
        }
    }
    
    func removeFromMyList(swedish: String, english: String) {
        let initialCount = myListWords.count
        myListWords.removeAll { word in
            word.swedish.lowercased() == swedish.lowercased() &&
            word.english.lowercased() == english.lowercased()
        }
        
        if myListWords.count < initialCount {
            saveMyList()
        }
    }
    
    func isInMyList(swedish: String, english: String) -> Bool {
        return myListWords.contains { word in
            word.swedish.lowercased() == swedish.lowercased() &&
            word.english.lowercased() == english.lowercased()
        }
    }
    
    func getMyListWords() -> [MyListWord] {
        return myListWords.sorted { $0.dateAdded > $1.dateAdded } // Most recent first
    }
    
    func getMyListCount() -> Int {
        return myListWords.count
    }
    
    func clearMyList() {
        myListWords = []
        UserDefaults.standard.removeObject(forKey: myListKey)
    }
    
    private func saveMyList() {
        do {
            let encoded = try JSONEncoder().encode(myListWords)
            UserDefaults.standard.set(encoded, forKey: myListKey)
        } catch {
            print("❌ Failed to save my list: \(error)")
        }
    }
    
    private func loadMyList() {
        guard let data = UserDefaults.standard.data(forKey: myListKey) else {
            return
        }
        
        do {
            myListWords = try JSONDecoder().decode([MyListWord].self, from: data)
        } catch {
            print("❌ Failed to load my list: \(error)")
            myListWords = []
        }
    }
}
