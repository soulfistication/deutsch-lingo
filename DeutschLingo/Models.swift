import Foundation

enum PromptLanguage: String, Codable {
    case english
    case german
}

struct CourseUnit: Identifiable, Hashable {
    let id: String
    let number: Int
    let title: String
    let germanTitle: String
    let subtitle: String
    let symbol: String
    let colorHex: UInt32
    let lessons: [Lesson]
    let vocab: [VocabEntry]
}

struct Lesson: Identifiable, Hashable {
    let id: String
    let title: String
    let symbol: String
    let xpReward: Int
    let exercises: [Exercise]
}

struct VocabEntry: Identifiable, Hashable {
    var id: String { german }
    let german: String
    let english: String
    let hint: String?
}

enum Exercise: Identifiable, Hashable {
    case multipleChoice(MultipleChoice)
    case listenChoose(MultipleChoice)
    case wordBank(WordBank)
    case fillBlank(FillBlank)
    case matchPairs(MatchPairs)

    var id: String {
        switch self {
        case .multipleChoice(let item): item.id
        case .listenChoose(let item): item.id
        case .wordBank(let item): item.id
        case .fillBlank(let item): item.id
        case .matchPairs(let item): item.id
        }
    }

    var speakText: String? {
        switch self {
        case .multipleChoice(let item), .listenChoose(let item):
            return item.speakText
        case .wordBank(let item):
            return item.speakText
        case .fillBlank(let item):
            return item.speakText
        case .matchPairs:
            return nil
        }
    }
}

struct MultipleChoice: Hashable, Identifiable {
    let id: String
    let prompt: String
    let promptLanguage: PromptLanguage
    let options: [String]
    let correctIndex: Int
    let speakText: String?
    let tip: String?
}

struct WordBank: Hashable, Identifiable {
    let id: String
    let prompt: String
    let tokens: [String]
    let correct: [String]
    let speakText: String?
}

struct FillBlank: Hashable, Identifiable {
    let id: String
    let before: String
    let after: String
    let translation: String
    let options: [String]
    let correctIndex: Int
    let speakText: String?
}

struct MatchPairs: Hashable, Identifiable {
    let id: String
    let pairs: [VocabEntry]
}

extension CourseUnit {
    var color: UInt32 { colorHex }
}
