import Foundation

enum Curriculum {
    static let units: [CourseUnit] = [
        greetings, introductions, food, numbers, people, travel, verbs, cafe
    ]

    static func lesson(id: String) -> Lesson? {
        units.flatMap(\.lessons).first { $0.id == id }
    }

    static func unit(containing lessonID: String) -> CourseUnit? {
        units.first { unit in unit.lessons.contains { $0.id == lessonID } }
    }

    static func isUnlocked(lessonID: String, completed: Set<String>) -> Bool {
        let all = units.flatMap(\.lessons)
        guard let index = all.firstIndex(where: { $0.id == lessonID }) else { return false }
        if index == 0 { return true }
        return completed.contains(all[index - 1].id)
    }
}

private func mc(
    _ id: String,
    _ prompt: String,
    _ lang: PromptLanguage,
    _ options: [String],
    correct: Int,
    speak: String? = nil,
    tip: String? = nil
) -> Exercise {
    .multipleChoice(
        MultipleChoice(
            id: id,
            prompt: prompt,
            promptLanguage: lang,
            options: options,
            correctIndex: correct,
            speakText: speak ?? (lang == .german ? prompt : options[correct]),
            tip: tip
        )
    )
}

private func listen(
    _ id: String,
    german: String,
    options: [String],
    correct: Int
) -> Exercise {
    .listenChoose(
        MultipleChoice(
            id: id,
            prompt: "What do you hear?",
            promptLanguage: .english,
            options: options,
            correctIndex: correct,
            speakText: german,
            tip: nil
        )
    )
}

private func bank(
    _ id: String,
    prompt: String,
    tokens: [String],
    correct: [String],
    speak: String? = nil
) -> Exercise {
    .wordBank(WordBank(id: id, prompt: prompt, tokens: tokens, correct: correct, speakText: speak ?? correct.joined(separator: " ")))
}

private func blank(
    _ id: String,
    before: String,
    after: String,
    translation: String,
    options: [String],
    correct: Int,
    speak: String? = nil
) -> Exercise {
    .fillBlank(
        FillBlank(
            id: id,
            before: before,
            after: after,
            translation: translation,
            options: options,
            correctIndex: correct,
            speakText: speak ?? "\(before) \(options[correct]) \(after)".replacingOccurrences(of: "  ", with: " ")
        )
    )
}

private func match(_ id: String, _ pairs: [(String, String)]) -> Exercise {
    .matchPairs(
        MatchPairs(
            id: id,
            pairs: pairs.map { VocabEntry(german: $0.0, english: $0.1, hint: nil) }
        )
    )
}

private let greetings = CourseUnit(
    id: "greetings",
    number: 1,
    title: "Greetings",
    germanTitle: "Begrüßungen",
    subtitle: "Say hello, goodbye, and thanks",
    symbol: "hand.wave.fill",
    colorHex: 0x58CC02,
    lessons: [
        Lesson(
            id: "u1-l1",
            title: "Hallo!",
            symbol: "sun.max.fill",
            xpReward: 10,
            exercises: [
                mc("u1l1e1", "Hello", .english, ["Hallo", "Tschüss", "Bitte", "Nein"], correct: 0, speak: "Hallo"),
                mc("u1l1e2", "Guten Tag", .german, ["Good night", "Good day", "Thank you", "Please"], correct: 1, speak: "Guten Tag"),
                listen("u1l1e3", german: "Guten Morgen", options: ["Good evening", "Good morning", "Goodbye", "Excuse me"], correct: 1),
                mc("u1l1e4", "Goodbye (casual)", .english, ["Bitte", "Danke", "Tschüss", "Ja"], correct: 2, speak: "Tschüss"),
                bank("u1l1e5", prompt: "Good night", tokens: ["Nacht", "Gute", "Tag", "Morgen"], correct: ["Gute", "Nacht"]),
                match("u1l1e6", [("Hallo", "Hello"), ("Tschüss", "Bye"), ("Guten Morgen", "Good morning"), ("Guten Abend", "Good evening")])
            ]
        ),
        Lesson(
            id: "u1-l2",
            title: "How are you?",
            symbol: "face.smiling.fill",
            xpReward: 10,
            exercises: [
                mc("u1l2e1", "Wie geht's?", .german, ["What's your name?", "How are you?", "Where are you?", "Who are you?"], correct: 1, speak: "Wie geht's?"),
                mc("u1l2e2", "Fine, thanks", .english, ["Sehr gut", "Gut, danke", "Nicht so gut", "Bitte schön"], correct: 1, speak: "Gut, danke"),
                listen("u1l2e3", german: "Sehr gut", options: ["Very good", "Not good", "See you", "Good night"], correct: 0),
                blank("u1l2e4", before: "Gut,", after: "", translation: "Fine, thanks", options: ["danke", "bitte", "hallo", "nein"], correct: 0),
                bank("u1l2e5", prompt: "How are you?", tokens: ["geht's", "Wie", "heißt", "du"], correct: ["Wie", "geht's"]),
                mc("u1l2e6", "Not so well", .english, ["Sehr gut", "Gut, danke", "Nicht so gut", "Freut mich"], correct: 2, speak: "Nicht so gut")
            ]
        ),
        Lesson(
            id: "u1-l3",
            title: "Please & thanks",
            symbol: "heart.fill",
            xpReward: 10,
            exercises: [
                mc("u1l3e1", "Thank you", .english, ["Bitte", "Danke", "Ja", "Nein"], correct: 1, speak: "Danke"),
                mc("u1l3e2", "Bitte", .german, ["Sorry", "Please / You're welcome", "Hello", "Goodbye"], correct: 1, speak: "Bitte", tip: "Bitte can mean please or you're welcome."),
                mc("u1l3e3", "Yes", .english, ["Nein", "Ja", "Doch", "Hallo"], correct: 1, speak: "Ja"),
                listen("u1l3e4", german: "Entschuldigung", options: ["Congratulations", "Excuse me", "Good luck", "See you soon"], correct: 1),
                bank("u1l3e5", prompt: "Thank you very much", tokens: ["Vielen", "Dank", "Bitte", "schön"], correct: ["Vielen", "Dank"], speak: "Vielen Dank"),
                match("u1l3e6", [("Danke", "Thank you"), ("Bitte", "Please"), ("Ja", "Yes"), ("Nein", "No")])
            ]
        ),
        Lesson(
            id: "u1-l4",
            title: "Unit 1 review",
            symbol: "star.fill",
            xpReward: 15,
            exercises: [
                listen("u1l4e1", german: "Guten Abend", options: ["Good morning", "Good evening", "Good night", "Good day"], correct: 1),
                mc("u1l4e2", "Auf Wiedersehen", .german, ["See you later", "Goodbye", "Welcome", "Cheers"], correct: 1, speak: "Auf Wiedersehen"),
                bank("u1l4e3", prompt: "Excuse me", tokens: ["Entschuldigung", "Bitte", "Danke", "Hallo"], correct: ["Entschuldigung"]),
                blank("u1l4e4", before: "Wie", after: "?", translation: "How are you?", options: ["geht's", "heißt", "bist", "kommst"], correct: 0),
                mc("u1l4e5", "You're welcome", .english, ["Danke schön", "Bitte schön", "Guten Tag", "Tschüss"], correct: 1, speak: "Bitte schön"),
                match("u1l4e6", [("Guten Tag", "Good day"), ("Gute Nacht", "Good night"), ("Vielen Dank", "Thank you very much"), ("Entschuldigung", "Excuse me")])
            ]
        )
    ],
    vocab: [
        VocabEntry(german: "Hallo", english: "Hello", hint: nil),
        VocabEntry(german: "Guten Morgen", english: "Good morning", hint: nil),
        VocabEntry(german: "Guten Tag", english: "Good day", hint: nil),
        VocabEntry(german: "Guten Abend", english: "Good evening", hint: nil),
        VocabEntry(german: "Gute Nacht", english: "Good night", hint: nil),
        VocabEntry(german: "Tschüss", english: "Bye", hint: "casual"),
        VocabEntry(german: "Auf Wiedersehen", english: "Goodbye", hint: "more formal"),
        VocabEntry(german: "Wie geht's?", english: "How are you?", hint: "informal"),
        VocabEntry(german: "Danke", english: "Thank you", hint: nil),
        VocabEntry(german: "Bitte", english: "Please / You're welcome", hint: nil),
        VocabEntry(german: "Ja", english: "Yes", hint: nil),
        VocabEntry(german: "Nein", english: "No", hint: nil),
        VocabEntry(german: "Entschuldigung", english: "Excuse me / Sorry", hint: nil)
    ]
)

private let introductions = CourseUnit(
    id: "introductions",
    number: 2,
    title: "Introductions",
    germanTitle: "Vorstellen",
    subtitle: "Names, origins, and meeting people",
    symbol: "person.fill",
    colorHex: 0x1CB0F6,
    lessons: [
        Lesson(
            id: "u2-l1",
            title: "My name is",
            symbol: "textformat",
            xpReward: 10,
            exercises: [
                mc("u2l1e1", "Wie heißt du?", .german, ["How old are you?", "What's your name?", "Where do you live?", "How are you?"], correct: 1, speak: "Wie heißt du?"),
                mc("u2l1e2", "My name is Anna", .english, ["Ich bin Anna", "Ich heiße Anna", "Ich habe Anna", "Ich komme Anna"], correct: 1, speak: "Ich heiße Anna"),
                listen("u2l1e3", german: "Freut mich", options: ["I'm sorry", "Nice to meet you", "See you tomorrow", "I don't know"], correct: 1),
                blank("u2l1e4", before: "Ich", after: "Max.", translation: "My name is Max.", options: ["heiße", "gehe", "esse", "habe"], correct: 0),
                bank("u2l1e5", prompt: "What's your name?", tokens: ["heißt", "du", "Wie", "bist"], correct: ["Wie", "heißt", "du"]),
                mc("u2l1e6", "I am a student", .english, ["Ich bin Student", "Ich habe Student", "Ich heiße Student", "Ich esse Student"], correct: 0, speak: "Ich bin Student")
            ]
        ),
        Lesson(
            id: "u2-l2",
            title: "Where from?",
            symbol: "globe.europe.africa.fill",
            xpReward: 10,
            exercises: [
                mc("u2l2e1", "Woher kommst du?", .german, ["Where are you going?", "Where are you from?", "Where do you live?", "Who are you?"], correct: 1, speak: "Woher kommst du?"),
                mc("u2l2e2", "I am from Germany", .english, ["Ich wohne Deutschland", "Ich komme aus Deutschland", "Ich bin Deutschland", "Ich heiße Deutschland"], correct: 1, speak: "Ich komme aus Deutschland"),
                listen("u2l2e3", german: "Ich komme aus Österreich", options: ["I live in Austria", "I am from Austria", "I speak Austrian", "I go to Austria"], correct: 1),
                blank("u2l2e4", before: "Ich komme aus", after: ".", translation: "I am from Switzerland.", options: ["der Schweiz", "Schweiz", "die Schweiz", "dem Schweiz"], correct: 0, speak: "Ich komme aus der Schweiz"),
                bank("u2l2e5", prompt: "Where are you from?", tokens: ["kommst", "du", "Woher", "bist"], correct: ["Woher", "kommst", "du"]),
                mc("u2l2e6", "the USA", .english, ["die USA", "der USA", "das USA", "den USA"], correct: 3, speak: "den USA", tip: "You say: Ich komme aus den USA.")
            ]
        ),
        Lesson(
            id: "u2-l3",
            title: "I speak…",
            symbol: "mouth.fill",
            xpReward: 10,
            exercises: [
                mc("u2l3e1", "I speak German", .english, ["Ich lerne Deutsch", "Ich spreche Deutsch", "Ich heiße Deutsch", "Ich mag Deutsch"], correct: 1, speak: "Ich spreche Deutsch"),
                mc("u2l3e2", "Sprechen Sie Englisch?", .german, ["Do you speak English?", "Are you English?", "Where is England?", "I speak English"], correct: 0, speak: "Sprechen Sie Englisch?", tip: "Sie is the formal you."),
                listen("u2l3e3", german: "Ich spreche ein bisschen Deutsch", options: ["I speak German fluently", "I speak a little German", "I don't speak German", "I am learning English"], correct: 1),
                blank("u2l3e4", before: "Ich", after: "Englisch.", translation: "I speak English.", options: ["spreche", "heiße", "komme", "bin"], correct: 0),
                bank("u2l3e5", prompt: "I speak a little German", tokens: ["spreche", "ein", "bisschen", "Deutsch", "Ich", "viel"], correct: ["Ich", "spreche", "ein", "bisschen", "Deutsch"]),
                match("u2l3e6", [("Deutsch", "German"), ("Englisch", "English"), ("ein bisschen", "a little"), ("sprechen", "to speak")])
            ]
        ),
        Lesson(
            id: "u2-l4",
            title: "Unit 2 review",
            symbol: "star.fill",
            xpReward: 15,
            exercises: [
                mc("u2l4e1", "Freut mich", .german, ["I'm tired", "Nice to meet you", "I'm hungry", "I'm lost"], correct: 1, speak: "Freut mich"),
                bank("u2l4e2", prompt: "My name is Lena", tokens: ["heiße", "Ich", "Lena", "bin"], correct: ["Ich", "heiße", "Lena"]),
                listen("u2l4e3", german: "Ich komme aus Berlin", options: ["I live in Berlin", "I am from Berlin", "I like Berlin", "I go to Berlin"], correct: 1),
                blank("u2l4e4", before: "Wie", after: "du?", translation: "What's your name?", options: ["heißt", "geht's", "bist", "kommst"], correct: 0),
                mc("u2l4e5", "I am from Austria", .english, ["Ich komme aus Österreich", "Ich wohne Österreich", "Ich bin aus Schweiz", "Ich heiße Österreich"], correct: 0, speak: "Ich komme aus Österreich"),
                match("u2l4e6", [("Ich heiße", "My name is"), ("Ich bin", "I am"), ("Woher kommst du?", "Where are you from?"), ("Freut mich", "Nice to meet you")])
            ]
        )
    ],
    vocab: [
        VocabEntry(german: "Ich heiße…", english: "My name is…", hint: nil),
        VocabEntry(german: "Wie heißt du?", english: "What's your name?", hint: "informal"),
        VocabEntry(german: "Ich bin…", english: "I am…", hint: nil),
        VocabEntry(german: "Freut mich", english: "Nice to meet you", hint: nil),
        VocabEntry(german: "Woher kommst du?", english: "Where are you from?", hint: nil),
        VocabEntry(german: "Ich komme aus…", english: "I am from…", hint: nil),
        VocabEntry(german: "Ich spreche…", english: "I speak…", hint: nil),
        VocabEntry(german: "ein bisschen", english: "a little", hint: nil)
    ]
)

private let food = CourseUnit(
    id: "food",
    number: 3,
    title: "Food & drink",
    germanTitle: "Essen & Trinken",
    subtitle: "Order coffee, bread, and water",
    symbol: "fork.knife",
    colorHex: 0xFF9600,
    lessons: [
        Lesson(
            id: "u3-l1",
            title: "Basics",
            symbol: "cup.and.saucer.fill",
            xpReward: 10,
            exercises: [
                mc("u3l1e1", "das Wasser", .german, ["the bread", "the water", "the coffee", "the tea"], correct: 1, speak: "das Wasser", tip: "das = neuter the."),
                mc("u3l1e2", "the coffee", .english, ["der Tee", "der Kaffee", "die Milch", "das Bier"], correct: 1, speak: "der Kaffee"),
                listen("u3l1e3", german: "das Brot", options: ["the cheese", "the bread", "the apple", "the wine"], correct: 1),
                match("u3l1e4", [("der Kaffee", "coffee"), ("der Tee", "tea"), ("das Wasser", "water"), ("die Milch", "milk")]),
                mc("u3l1e5", "der Apfel", .german, ["the apple", "the cheese", "the beer", "the wine"], correct: 0, speak: "der Apfel"),
                blank("u3l1e6", before: "Ich trinke", after: ".", translation: "I drink water.", options: ["Wasser", "Brot", "Käse", "Apfel"], correct: 0)
            ]
        ),
        Lesson(
            id: "u3-l2",
            title: "I eat, I drink",
            symbol: "takeoutbag.and.cup.and.straw.fill",
            xpReward: 10,
            exercises: [
                mc("u3l2e1", "I eat bread", .english, ["Ich trinke Brot", "Ich esse Brot", "Ich habe Brot", "Ich bin Brot"], correct: 1, speak: "Ich esse Brot"),
                mc("u3l2e2", "Ich trinke Kaffee", .german, ["I eat coffee", "I drink coffee", "I like coffee", "I want coffee"], correct: 1, speak: "Ich trinke Kaffee"),
                listen("u3l2e3", german: "Ich esse einen Apfel", options: ["I eat an apple", "I drink an apple", "I have the apple", "I want cheese"], correct: 0),
                bank("u3l2e4", prompt: "I drink tea", tokens: ["trinke", "Tee", "Ich", "esse", "Kaffee"], correct: ["Ich", "trinke", "Tee"]),
                blank("u3l2e5", before: "Ich", after: "Käse.", translation: "I eat cheese.", options: ["esse", "trinke", "bin", "heiße"], correct: 0),
                match("u3l2e6", [("essen", "to eat"), ("trinken", "to drink"), ("der Käse", "cheese"), ("das Bier", "beer")])
            ]
        ),
        Lesson(
            id: "u3-l3",
            title: "I would like",
            symbol: "birthday.cake.fill",
            xpReward: 10,
            exercises: [
                mc("u3l3e1", "Ich hätte gern…", .german, ["I don't want…", "I would like…", "I already have…", "I am eating…"], correct: 1, speak: "Ich hätte gern", tip: "Polite way to order."),
                bank("u3l3e2", prompt: "I would like a coffee", tokens: ["hätte", "gern", "einen", "Kaffee", "Ich", "das"], correct: ["Ich", "hätte", "gern", "einen", "Kaffee"]),
                listen("u3l3e3", german: "Die Rechnung, bitte", options: ["A table, please", "The check, please", "More water, please", "I'm ready"], correct: 1),
                mc("u3l3e4", "the wine", .english, ["das Bier", "der Wein", "die Milch", "der Tee"], correct: 1, speak: "der Wein"),
                blank("u3l3e5", before: "Ich hätte gern", after: ", bitte.", translation: "I would like water, please.", options: ["Wasser", "Hallo", "Danke", "Ja"], correct: 0),
                mc("u3l3e6", "Together or separately?", .english, ["Zusammen oder getrennt?", "Links oder rechts?", "Ja oder nein?", "Tee oder Kaffee?"], correct: 0, speak: "Zusammen oder getrennt?")
            ]
        ),
        Lesson(
            id: "u3-l4",
            title: "Unit 3 review",
            symbol: "star.fill",
            xpReward: 15,
            exercises: [
                listen("u3l4e1", german: "Ich hätte gern einen Kaffee", options: ["I would like a coffee", "I drink tea", "I eat bread", "The check please"], correct: 0),
                mc("u3l4e2", "die Milch", .german, ["the milk", "the cheese", "the apple", "the beer"], correct: 0, speak: "die Milch"),
                bank("u3l4e3", prompt: "The check, please", tokens: ["Rechnung", "Die", "bitte", "Wasser"], correct: ["Die", "Rechnung", "bitte"]),
                match("u3l4e4", [("das Brot", "bread"), ("der Apfel", "apple"), ("der Wein", "wine"), ("Ich esse", "I eat")]),
                blank("u3l4e5", before: "Ich", after: "Bier.", translation: "I drink beer.", options: ["trinke", "esse", "bin", "heiße"], correct: 0),
                mc("u3l4e6", "I would like tea", .english, ["Ich hätte gern Tee", "Ich esse Tee", "Ich bin Tee", "Ich heiße Tee"], correct: 0, speak: "Ich hätte gern Tee")
            ]
        )
    ],
    vocab: [
        VocabEntry(german: "das Wasser", english: "water", hint: "neuter"),
        VocabEntry(german: "der Kaffee", english: "coffee", hint: "masculine"),
        VocabEntry(german: "der Tee", english: "tea", hint: "masculine"),
        VocabEntry(german: "das Brot", english: "bread", hint: "neuter"),
        VocabEntry(german: "der Apfel", english: "apple", hint: "masculine"),
        VocabEntry(german: "die Milch", english: "milk", hint: "feminine"),
        VocabEntry(german: "der Käse", english: "cheese", hint: "masculine"),
        VocabEntry(german: "Ich esse", english: "I eat", hint: nil),
        VocabEntry(german: "Ich trinke", english: "I drink", hint: nil),
        VocabEntry(german: "Ich hätte gern", english: "I would like", hint: "polite")
    ]
)

private let numbers = CourseUnit(
    id: "numbers",
    number: 4,
    title: "Numbers",
    germanTitle: "Zahlen",
    subtitle: "Count to ten and ask prices",
    symbol: "number",
    colorHex: 0xCE82FF,
    lessons: [
        Lesson(
            id: "u4-l1",
            title: "1 to 5",
            symbol: "1.circle.fill",
            xpReward: 10,
            exercises: [
                mc("u4l1e1", "eins", .german, ["one", "two", "three", "zero"], correct: 0, speak: "eins"),
                mc("u4l1e2", "two", .english, ["eins", "zwei", "drei", "vier"], correct: 1, speak: "zwei"),
                listen("u4l1e3", german: "drei", options: ["two", "three", "four", "five"], correct: 1),
                match("u4l1e4", [("eins", "one"), ("zwei", "two"), ("drei", "three"), ("vier", "four")]),
                mc("u4l1e5", "five", .english, ["vier", "fünf", "sechs", "sieben"], correct: 1, speak: "fünf"),
                blank("u4l1e6", before: "eins, zwei,", after: "", translation: "one, two, three", options: ["drei", "vier", "acht", "zehn"], correct: 0)
            ]
        ),
        Lesson(
            id: "u4-l2",
            title: "6 to 10",
            symbol: "10.circle.fill",
            xpReward: 10,
            exercises: [
                mc("u4l2e1", "sechs", .german, ["six", "seven", "eight", "sixteen"], correct: 0, speak: "sechs"),
                listen("u4l2e2", german: "sieben", options: ["six", "seven", "nine", "ten"], correct: 1),
                mc("u4l2e3", "eight", .english, ["acht", "neun", "zehn", "elf"], correct: 0, speak: "acht"),
                match("u4l2e4", [("sechs", "six"), ("sieben", "seven"), ("acht", "eight"), ("neun", "nine")]),
                mc("u4l2e5", "zehn", .german, ["nine", "ten", "eleven", "twelve"], correct: 1, speak: "zehn"),
                bank("u4l2e6", prompt: "nine", tokens: ["neun", "zehn", "eins", "zwei"], correct: ["neun"])
            ]
        ),
        Lesson(
            id: "u4-l3",
            title: "How much?",
            symbol: "eurosign.circle.fill",
            xpReward: 10,
            exercises: [
                mc("u4l3e1", "Wie viel kostet das?", .german, ["What is that?", "How much does that cost?", "How many are there?", "Where is that?"], correct: 1, speak: "Wie viel kostet das?"),
                listen("u4l3e2", german: "Das kostet fünf Euro", options: ["That costs four euros", "That costs five euros", "That costs ten euros", "I have five euros"], correct: 1),
                bank("u4l3e3", prompt: "How much does that cost?", tokens: ["viel", "kostet", "das", "Wie", "wo"], correct: ["Wie", "viel", "kostet", "das"]),
                blank("u4l3e4", before: "Das kostet", after: "Euro.", translation: "That costs ten euros.", options: ["zehn", "eins", "Wasser", "bitte"], correct: 0),
                mc("u4l3e5", "I have two apples", .english, ["Ich habe zwei Äpfel", "Ich esse zwei Äpfel", "Ich bin zwei Äpfel", "Ich möchte zwei Apfel"], correct: 0, speak: "Ich habe zwei Äpfel"),
                match("u4l3e6", [("Wie viel?", "How much?"), ("Euro", "euro"), ("kosten", "to cost"), ("zehn", "ten")])
            ]
        )
    ],
    vocab: [
        VocabEntry(german: "eins", english: "one", hint: nil),
        VocabEntry(german: "zwei", english: "two", hint: nil),
        VocabEntry(german: "drei", english: "three", hint: nil),
        VocabEntry(german: "vier", english: "four", hint: nil),
        VocabEntry(german: "fünf", english: "five", hint: nil),
        VocabEntry(german: "sechs", english: "six", hint: nil),
        VocabEntry(german: "sieben", english: "seven", hint: nil),
        VocabEntry(german: "acht", english: "eight", hint: nil),
        VocabEntry(german: "neun", english: "nine", hint: nil),
        VocabEntry(german: "zehn", english: "ten", hint: nil),
        VocabEntry(german: "Wie viel kostet das?", english: "How much does that cost?", hint: nil)
    ]
)

private let people = CourseUnit(
    id: "people",
    number: 5,
    title: "People",
    germanTitle: "Menschen",
    subtitle: "Family, friends, and articles",
    symbol: "person.3.fill",
    colorHex: 0xFF4B4B,
    lessons: [
        Lesson(
            id: "u5-l1",
            title: "Family",
            symbol: "figure.2.and.child.holdinghands",
            xpReward: 10,
            exercises: [
                mc("u5l1e1", "die Mutter", .german, ["the father", "the mother", "the sister", "the child"], correct: 1, speak: "die Mutter"),
                mc("u5l1e2", "the father", .english, ["die Frau", "der Vater", "der Bruder", "das Kind"], correct: 1, speak: "der Vater"),
                listen("u5l1e3", german: "die Schwester", options: ["the brother", "the sister", "the friend", "the family"], correct: 1),
                match("u5l1e4", [("die Mutter", "mother"), ("der Vater", "father"), ("die Schwester", "sister"), ("der Bruder", "brother")]),
                mc("u5l1e5", "das Kind", .german, ["the man", "the woman", "the child", "the friend"], correct: 2, speak: "das Kind"),
                bank("u5l1e6", prompt: "This is my family", tokens: ["ist", "meine", "Familie", "Das", "der"], correct: ["Das", "ist", "meine", "Familie"])
            ]
        ),
        Lesson(
            id: "u5-l2",
            title: "Friends",
            symbol: "person.2.fill",
            xpReward: 10,
            exercises: [
                mc("u5l2e1", "der Freund", .german, ["the girlfriend", "the (male) friend", "the child", "the man"], correct: 1, speak: "der Freund", tip: "der Freund can also mean boyfriend."),
                mc("u5l2e2", "the woman", .english, ["der Mann", "die Frau", "das Kind", "die Familie"], correct: 1, speak: "die Frau"),
                listen("u5l2e3", german: "die Freundin", options: ["the (female) friend", "the mother", "the sister", "the teacher"], correct: 0),
                blank("u5l2e4", before: "Das ist", after: ".", translation: "This is my friend. (male)", options: ["mein Freund", "meine Freund", "mein Freundin", "die Freund"], correct: 0),
                bank("u5l2e5", prompt: "He is a man", tokens: ["ist", "ein", "Mann", "Er", "Sie"], correct: ["Er", "ist", "ein", "Mann"]),
                match("u5l2e6", [("der Mann", "the man"), ("die Frau", "the woman"), ("der Freund", "the friend"), ("die Familie", "the family")])
            ]
        ),
        Lesson(
            id: "u5-l3",
            title: "Articles",
            symbol: "textformat.abc",
            xpReward: 15,
            exercises: [
                mc("u5l3e1", "Which article is masculine?", .english, ["die", "das", "der", "den"], correct: 2, speak: "der"),
                mc("u5l3e2", "die is used with", .english, ["masculine nouns", "feminine nouns", "neuter nouns", "plural only"], correct: 1),
                listen("u5l3e3", german: "der, die, das", options: ["a, an, the", "the (m, f, n)", "yes, no, please", "one, two, three"], correct: 1),
                blank("u5l3e4", before: "", after: "Wasser", translation: "the water", options: ["das", "der", "die", "den"], correct: 0),
                mc("u5l3e5", "the coffee", .english, ["die Kaffee", "das Kaffee", "der Kaffee", "den Kaffee"], correct: 2, speak: "der Kaffee"),
                match("u5l3e6", [("der", "masculine the"), ("die", "feminine the"), ("das", "neuter the"), ("ein", "a / an")])
            ]
        )
    ],
    vocab: [
        VocabEntry(german: "die Mutter", english: "the mother", hint: "feminine"),
        VocabEntry(german: "der Vater", english: "the father", hint: "masculine"),
        VocabEntry(german: "die Schwester", english: "the sister", hint: nil),
        VocabEntry(german: "der Bruder", english: "the brother", hint: nil),
        VocabEntry(german: "das Kind", english: "the child", hint: "neuter"),
        VocabEntry(german: "die Familie", english: "the family", hint: nil),
        VocabEntry(german: "der Freund", english: "the (male) friend", hint: nil),
        VocabEntry(german: "die Freundin", english: "the (female) friend", hint: nil),
        VocabEntry(german: "der Mann", english: "the man", hint: nil),
        VocabEntry(german: "die Frau", english: "the woman", hint: nil)
    ]
)

private let travel = CourseUnit(
    id: "travel",
    number: 6,
    title: "Travel",
    germanTitle: "Reisen",
    subtitle: "Find the station, hotel, and restroom",
    symbol: "airplane",
    colorHex: 0x1CB0F6,
    lessons: [
        Lesson(
            id: "u6-l1",
            title: "Where is…?",
            symbol: "mappin.and.ellipse",
            xpReward: 10,
            exercises: [
                mc("u6l1e1", "Wo ist…?", .german, ["Who is…?", "Where is…?", "What is…?", "How is…?"], correct: 1, speak: "Wo ist"),
                mc("u6l1e2", "the train station", .english, ["das Hotel", "der Bahnhof", "der Flughafen", "die Toilette"], correct: 1, speak: "der Bahnhof"),
                listen("u6l1e3", german: "Wo ist der Bahnhof?", options: ["Where is the hotel?", "Where is the station?", "Where is the airport?", "Where is the restroom?"], correct: 1),
                bank("u6l1e4", prompt: "Where is the hotel?", tokens: ["ist", "das", "Hotel", "Wo", "der"], correct: ["Wo", "ist", "das", "Hotel"]),
                mc("u6l1e5", "die Toilette", .german, ["the ticket", "the restroom", "the street", "the city"], correct: 1, speak: "die Toilette"),
                match("u6l1e6", [("der Bahnhof", "train station"), ("das Hotel", "hotel"), ("der Flughafen", "airport"), ("die Toilette", "restroom")])
            ]
        ),
        Lesson(
            id: "u6-l2",
            title: "Directions",
            symbol: "arrow.triangle.turn.up.right.diamond.fill",
            xpReward: 10,
            exercises: [
                mc("u6l2e1", "links", .german, ["right", "left", "straight ahead", "back"], correct: 1, speak: "links"),
                mc("u6l2e2", "right", .english, ["links", "rechts", "geradeaus", "hier"], correct: 1, speak: "rechts"),
                listen("u6l2e3", german: "geradeaus", options: ["left", "right", "straight ahead", "stop"], correct: 2),
                bank("u6l2e4", prompt: "Go left, please", tokens: ["links", "bitte", "Gehen", "Sie", "rechts"], correct: ["Gehen", "Sie", "links", "bitte"]),
                blank("u6l2e5", before: "Es ist", after: ".", translation: "It is on the right.", options: ["rechts", "Wasser", "danke", "drei"], correct: 0),
                match("u6l2e6", [("links", "left"), ("rechts", "right"), ("geradeaus", "straight ahead"), ("hier", "here")])
            ]
        ),
        Lesson(
            id: "u6-l3",
            title: "Tickets",
            symbol: "ticket.fill",
            xpReward: 15,
            exercises: [
                mc("u6l3e1", "die Fahrkarte", .german, ["the suitcase", "the ticket", "the passport", "the map"], correct: 1, speak: "die Fahrkarte"),
                listen("u6l3e2", german: "Eine Fahrkarte nach Berlin, bitte", options: ["A ticket to Berlin, please", "A hotel in Berlin, please", "A coffee in Berlin, please", "The station in Berlin"], correct: 0),
                bank("u6l3e3", prompt: "I'm looking for the airport", tokens: ["suche", "den", "Flughafen", "Ich", "Bahnhof"], correct: ["Ich", "suche", "den", "Flughafen"]),
                mc("u6l3e4", "I don't understand", .english, ["Ich verstehe nicht", "Ich weiß nicht", "Ich bin nicht", "Ich komme nicht"], correct: 0, speak: "Ich verstehe nicht"),
                blank("u6l3e5", before: "Sprechen Sie", after: "?", translation: "Do you speak English?", options: ["Englisch", "Deutsch", "Wasser", "links"], correct: 0),
                match("u6l3e6", [("die Fahrkarte", "ticket"), ("Ich suche", "I'm looking for"), ("Ich verstehe nicht", "I don't understand"), ("bitte", "please")])
            ]
        )
    ],
    vocab: [
        VocabEntry(german: "Wo ist…?", english: "Where is…?", hint: nil),
        VocabEntry(german: "der Bahnhof", english: "train station", hint: nil),
        VocabEntry(german: "das Hotel", english: "hotel", hint: nil),
        VocabEntry(german: "der Flughafen", english: "airport", hint: nil),
        VocabEntry(german: "die Toilette", english: "restroom", hint: nil),
        VocabEntry(german: "links", english: "left", hint: nil),
        VocabEntry(german: "rechts", english: "right", hint: nil),
        VocabEntry(german: "geradeaus", english: "straight ahead", hint: nil),
        VocabEntry(german: "die Fahrkarte", english: "ticket", hint: nil),
        VocabEntry(german: "Ich verstehe nicht", english: "I don't understand", hint: nil)
    ]
)

private let verbs = CourseUnit(
    id: "verbs",
    number: 7,
    title: "Everyday verbs",
    germanTitle: "Verben",
    subtitle: "Live, learn, go, and have",
    symbol: "bolt.fill",
    colorHex: 0x58CC02,
    lessons: [
        Lesson(
            id: "u7-l1",
            title: "I am / I have",
            symbol: "person.fill",
            xpReward: 10,
            exercises: [
                mc("u7l1e1", "I am tired", .english, ["Ich habe müde", "Ich bin müde", "Ich gehe müde", "Ich lerne müde"], correct: 1, speak: "Ich bin müde"),
                mc("u7l1e2", "Ich habe Zeit", .german, ["I am time", "I have time", "I need time", "I like time"], correct: 1, speak: "Ich habe Zeit"),
                listen("u7l1e3", german: "Ich bin hungrig", options: ["I am thirsty", "I am hungry", "I am tired", "I am happy"], correct: 1),
                bank("u7l1e4", prompt: "I am happy", tokens: ["bin", "glücklich", "Ich", "habe", "müde"], correct: ["Ich", "bin", "glücklich"]),
                blank("u7l1e5", before: "Ich", after: "Durst.", translation: "I am thirsty. (I have thirst)", options: ["habe", "bin", "gehe", "lerne"], correct: 0, speak: "Ich habe Durst"),
                match("u7l1e6", [("Ich bin", "I am"), ("Ich habe", "I have"), ("müde", "tired"), ("hungrig", "hungry")])
            ]
        ),
        Lesson(
            id: "u7-l2",
            title: "Learn & live",
            symbol: "book.fill",
            xpReward: 10,
            exercises: [
                mc("u7l2e1", "Ich lerne Deutsch", .german, ["I teach German", "I learn German", "I speak German", "I like German"], correct: 1, speak: "Ich lerne Deutsch"),
                mc("u7l2e2", "I live in Berlin", .english, ["Ich gehe in Berlin", "Ich wohne in Berlin", "Ich bin Berlin", "Ich habe Berlin"], correct: 1, speak: "Ich wohne in Berlin"),
                listen("u7l2e3", german: "Ich lerne jeden Tag", options: ["I learn every day", "I live every day", "I go every day", "I eat every day"], correct: 0),
                bank("u7l2e4", prompt: "I am learning German", tokens: ["lerne", "Deutsch", "Ich", "spreche", "Wohnen"], correct: ["Ich", "lerne", "Deutsch"]),
                blank("u7l2e5", before: "Ich", after: "in München.", translation: "I live in Munich.", options: ["wohne", "lerne", "habe", "heiße"], correct: 0),
                match("u7l2e6", [("lernen", "to learn"), ("wohnen", "to live"), ("jeden Tag", "every day"), ("Deutsch", "German")])
            ]
        ),
        Lesson(
            id: "u7-l3",
            title: "Going places",
            symbol: "figure.walk",
            xpReward: 15,
            exercises: [
                mc("u7l3e1", "Ich gehe ins Café", .german, ["I am the café", "I go to the café", "I drink the café", "I see the café"], correct: 1, speak: "Ich gehe ins Café"),
                listen("u7l3e2", german: "Ich gehe nach Hause", options: ["I go home", "I am at home", "I leave the house", "I have a house"], correct: 0),
                bank("u7l3e3", prompt: "I go to the station", tokens: ["gehe", "zum", "Bahnhof", "Ich", "Hotel"], correct: ["Ich", "gehe", "zum", "Bahnhof"]),
                mc("u7l3e4", "today", .english, ["gestern", "heute", "morgen", "jetzt"], correct: 1, speak: "heute"),
                blank("u7l3e5", before: "Ich gehe", after: "ins Restaurant.", translation: "I am going to the restaurant today.", options: ["heute", "Wasser", "müde", "drei"], correct: 0),
                match("u7l3e6", [("gehen", "to go"), ("heute", "today"), ("morgen", "tomorrow"), ("nach Hause", "home")])
            ]
        )
    ],
    vocab: [
        VocabEntry(german: "Ich bin", english: "I am", hint: nil),
        VocabEntry(german: "Ich habe", english: "I have", hint: nil),
        VocabEntry(german: "müde", english: "tired", hint: nil),
        VocabEntry(german: "hungrig", english: "hungry", hint: nil),
        VocabEntry(german: "lernen", english: "to learn", hint: nil),
        VocabEntry(german: "wohnen", english: "to live", hint: nil),
        VocabEntry(german: "gehen", english: "to go", hint: nil),
        VocabEntry(german: "heute", english: "today", hint: nil),
        VocabEntry(german: "morgen", english: "tomorrow", hint: nil)
    ]
)

private let cafe = CourseUnit(
    id: "cafe",
    number: 8,
    title: "At the café",
    germanTitle: "Im Café",
    subtitle: "A full beginner conversation",
    symbol: "cup.and.saucer.fill",
    colorHex: 0xFFC800,
    lessons: [
        Lesson(
            id: "u8-l1",
            title: "Ordering",
            symbol: "list.bullet",
            xpReward: 15,
            exercises: [
                listen("u8l1e1", german: "Was möchten Sie?", options: ["What would you like?", "How much is it?", "Where are you from?", "Do you understand?"], correct: 0),
                mc("u8l1e2", "For here or to go?", .english, ["Mit oder ohne?", "Zum Hieressen oder zum Mitnehmen?", "Zusammen oder getrennt?", "Tee oder Kaffee?"], correct: 1, speak: "Zum Hieressen oder zum Mitnehmen?"),
                bank("u8l1e3", prompt: "A coffee with milk, please", tokens: ["Kaffee", "mit", "Milch", "Einen", "bitte", "ohne"], correct: ["Einen", "Kaffee", "mit", "Milch", "bitte"]),
                mc("u8l1e4", "without sugar", .english, ["mit Zucker", "ohne Zucker", "kein Kaffee", "viel Milch"], correct: 1, speak: "ohne Zucker"),
                blank("u8l1e5", before: "Das ist alles,", after: ".", translation: "That's all, thank you.", options: ["danke", "bitte", "hallo", "nein"], correct: 0),
                match("u8l1e6", [("Was möchten Sie?", "What would you like?"), ("zum Mitnehmen", "to go"), ("mit Milch", "with milk"), ("ohne Zucker", "without sugar")])
            ]
        ),
        Lesson(
            id: "u8-l2",
            title: "Paying",
            symbol: "creditcard.fill",
            xpReward: 15,
            exercises: [
                mc("u8l2e1", "Kann ich mit Karte zahlen?", .german, ["Can I pay by card?", "Do you have a card?", "Where is the card?", "I need a ticket"], correct: 0, speak: "Kann ich mit Karte zahlen?"),
                listen("u8l2e2", german: "Bar oder Karte?", options: ["Bread or coffee?", "Cash or card?", "Here or to go?", "Tea or milk?"], correct: 1),
                bank("u8l2e3", prompt: "The check, please", tokens: ["Die", "Rechnung", "bitte", "Karte"], correct: ["Die", "Rechnung", "bitte"]),
                mc("u8l2e4", "Keep the change", .english, ["Stimmt so", "Kein Problem", "Gute Nacht", "Auf Wiedersehen"], correct: 0, speak: "Stimmt so"),
                blank("u8l2e5", before: "Das macht", after: "Euro.", translation: "That comes to eight euros.", options: ["acht", "Wasser", "bitte", "links"], correct: 0),
                match("u8l2e6", [("zahlen", "to pay"), ("die Karte", "card"), ("bar", "cash"), ("die Rechnung", "the check")])
            ]
        ),
        Lesson(
            id: "u8-l3",
            title: "Final challenge",
            symbol: "flag.checkered",
            xpReward: 20,
            exercises: [
                listen("u8l3e1", german: "Guten Tag, ich hätte gern einen Kaffee", options: ["Hello, I would like a coffee", "Good night, I drink tea", "Excuse me, where is the café?", "Thanks, the check please"], correct: 0),
                bank("u8l3e2", prompt: "I don't understand. Do you speak English?", tokens: ["verstehe", "nicht", "Sprechen", "Sie", "Englisch", "Ich"], correct: ["Ich", "verstehe", "nicht", "Sprechen", "Sie", "Englisch"]),
                mc("u8l3e3", "Where is the restroom?", .english, ["Wo ist die Toilette?", "Wo ist der Bahnhof?", "Wie viel kostet das?", "Wie heißt du?"], correct: 0, speak: "Wo ist die Toilette?"),
                blank("u8l3e4", before: "Ich komme aus", after: ".", translation: "I am from Germany.", options: ["Deutschland", "Kaffee", "danke", "links"], correct: 0),
                mc("u8l3e5", "Nice to meet you. My name is Otto.", .english, ["Freut mich. Ich heiße Otto.", "Wie geht's. Ich bin Otto.", "Danke. Ich esse Otto.", "Bitte. Ich wohne Otto."], correct: 0, speak: "Freut mich. Ich heiße Otto."),
                match("u8l3e6", [("Guten Tag", "Hello"), ("Ich hätte gern", "I would like"), ("Wo ist…?", "Where is…?"), ("Vielen Dank", "Thank you very much")])
            ]
        )
    ],
    vocab: [
        VocabEntry(german: "Was möchten Sie?", english: "What would you like?", hint: "formal"),
        VocabEntry(german: "zum Mitnehmen", english: "to go", hint: nil),
        VocabEntry(german: "ohne Zucker", english: "without sugar", hint: nil),
        VocabEntry(german: "Die Rechnung, bitte", english: "The check, please", hint: nil),
        VocabEntry(german: "Kann ich mit Karte zahlen?", english: "Can I pay by card?", hint: nil),
        VocabEntry(german: "Stimmt so", english: "Keep the change", hint: nil),
        VocabEntry(german: "Das macht…", english: "That comes to…", hint: nil)
    ]
)
