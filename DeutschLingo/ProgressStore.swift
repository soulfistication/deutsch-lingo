import Foundation
import SwiftUI

@Observable
final class ProgressStore {
    static let heartsMax = 5
    static let heartRegenMinutes = 20

    var hasOnboarded: Bool
    var displayName: String
    var dailyGoal: Int
    var prefersDarkMode: Bool

    var xp: Int
    var weeklyXP: Int
    var gems: Int
    var hearts: Int
    var streak: Int
    var longestStreak: Int
    var lastActiveDay: Date?
    var lastHeartAt: Date
    var dailyXP: Int
    var dailyXPDay: Date?
    var weeklyXPWeekStart: Date?

    var completedLessonIDs: Set<String>
    var lessonStars: [String: Int]
    var practicedToday: Bool

    private let defaults = UserDefaults.standard
    private let calendar = Calendar.current

    init() {
        hasOnboarded = defaults.bool(forKey: "hasOnboarded")
        displayName = defaults.string(forKey: "displayName") ?? "You"
        dailyGoal = defaults.object(forKey: "dailyGoal") as? Int ?? 20
        prefersDarkMode = defaults.bool(forKey: "prefersDarkMode")
        xp = defaults.integer(forKey: "xp")
        weeklyXP = defaults.integer(forKey: "weeklyXP")
        gems = defaults.object(forKey: "gems") as? Int ?? 50
        hearts = defaults.object(forKey: "hearts") as? Int ?? ProgressStore.heartsMax
        streak = defaults.integer(forKey: "streak")
        longestStreak = defaults.integer(forKey: "longestStreak")
        lastActiveDay = defaults.object(forKey: "lastActiveDay") as? Date
        lastHeartAt = defaults.object(forKey: "lastHeartAt") as? Date ?? Date()
        dailyXP = defaults.integer(forKey: "dailyXP")
        dailyXPDay = defaults.object(forKey: "dailyXPDay") as? Date
        weeklyXPWeekStart = defaults.object(forKey: "weeklyXPWeekStart") as? Date
        practicedToday = defaults.bool(forKey: "practicedToday")
        let ids = defaults.stringArray(forKey: "completedLessonIDs") ?? []
        completedLessonIDs = Set(ids)
        if let data = defaults.data(forKey: "lessonStars"),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            lessonStars = decoded
        } else {
            lessonStars = [:]
        }
        rollDaysIfNeeded()
        regenerateHearts()
    }

    var dailyProgress: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(1, Double(dailyXP) / Double(dailyGoal))
    }

    var completedCount: Int { completedLessonIDs.count }

    var totalLessons: Int { Curriculum.units.flatMap(\.lessons).count }

    func isLessonUnlocked(_ id: String) -> Bool {
        Curriculum.isUnlocked(lessonID: id, completed: completedLessonIDs)
    }

    func stars(for lessonID: String) -> Int {
        lessonStars[lessonID] ?? 0
    }

    func completeOnboarding(name: String, goal: Int) {
        displayName = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "You" : name
        dailyGoal = goal
        hasOnboarded = true
        persist()
    }

    func completeLesson(id: String, correct: Int, total: Int) -> LessonResult {
        regenerateHearts()
        let accuracy = total == 0 ? 1 : Double(correct) / Double(total)
        let earnedStars = accuracy >= 1 ? 3 : accuracy >= 0.7 ? 2 : 1
        let previous = lessonStars[id] ?? 0
        let firstClear = !completedLessonIDs.contains(id)
        completedLessonIDs.insert(id)
        lessonStars[id] = max(previous, earnedStars)

        var gained = Curriculum.lesson(id: id)?.xpReward ?? 10
        if earnedStars == 3 { gained += 5 }
        if !firstClear { gained = max(5, gained / 2) }

        addXP(gained)
        if firstClear { gems += 2 }
        noteActivity()
        persist()
        return LessonResult(xp: gained, stars: earnedStars, accuracy: accuracy, firstClear: firstClear)
    }

    func missAnswer() {
        regenerateHearts()
        if hearts > 0 {
            hearts -= 1
            lastHeartAt = Date()
            persist()
        }
    }

    func refillHeartFromPractice() {
        regenerateHearts()
        hearts = min(ProgressStore.heartsMax, hearts + 1)
        practicedToday = true
        addXP(5)
        noteActivity()
        persist()
    }

    func regenerateHearts() {
        guard hearts < ProgressStore.heartsMax else { return }
        let elapsed = Date().timeIntervalSince(lastHeartAt)
        let gained = Int(elapsed / Double(ProgressStore.heartRegenMinutes * 60))
        if gained > 0 {
            hearts = min(ProgressStore.heartsMax, hearts + gained)
            lastHeartAt = lastHeartAt.addingTimeInterval(Double(gained * ProgressStore.heartRegenMinutes * 60))
            persist()
        }
    }

    var nextHeartDate: Date? {
        guard hearts < ProgressStore.heartsMax else { return nil }
        return lastHeartAt.addingTimeInterval(Double(ProgressStore.heartRegenMinutes * 60))
    }

    func addGems(_ amount: Int) {
        gems += amount
        persist()
    }

    func buyHeartsIfPossible() -> Bool {
        guard gems >= 10, hearts < ProgressStore.heartsMax else { return false }
        gems -= 10
        hearts = ProgressStore.heartsMax
        persist()
        return true
    }

    func toggleDarkMode() {
        prefersDarkMode.toggle()
        persist()
    }

    func resetProgress() {
        xp = 0
        weeklyXP = 0
        gems = 50
        hearts = ProgressStore.heartsMax
        streak = 0
        longestStreak = 0
        lastActiveDay = nil
        lastHeartAt = Date()
        dailyXP = 0
        dailyXPDay = Date()
        practicedToday = false
        completedLessonIDs = []
        lessonStars = [:]
        persist()
    }

    private func addXP(_ amount: Int) {
        rollDaysIfNeeded()
        xp += amount
        weeklyXP += amount
        dailyXP += amount
    }

    private func noteActivity() {
        rollDaysIfNeeded()
        let today = calendar.startOfDay(for: Date())
        if let last = lastActiveDay.map({ calendar.startOfDay(for: $0) }) {
            if last == today {
                // already counted today
            } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today), last == yesterday {
                streak += 1
            } else {
                streak = 1
            }
        } else {
            streak = max(1, streak)
        }
        lastActiveDay = today
        longestStreak = max(longestStreak, streak)
    }

    private func rollDaysIfNeeded() {
        let today = calendar.startOfDay(for: Date())
        if let day = dailyXPDay.map({ calendar.startOfDay(for: $0) }), day != today {
            dailyXP = 0
            practicedToday = false
        }
        dailyXPDay = today

        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? today
        if let stored = weeklyXPWeekStart, stored != weekStart {
            weeklyXP = 0
        }
        weeklyXPWeekStart = weekStart

        if let last = lastActiveDay.map({ calendar.startOfDay(for: $0) }), last != today {
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today), last != yesterday {
                // streak breaks only when they next practice; keep showing until then
            }
        }
    }

    private func persist() {
        defaults.set(hasOnboarded, forKey: "hasOnboarded")
        defaults.set(displayName, forKey: "displayName")
        defaults.set(dailyGoal, forKey: "dailyGoal")
        defaults.set(prefersDarkMode, forKey: "prefersDarkMode")
        defaults.set(xp, forKey: "xp")
        defaults.set(weeklyXP, forKey: "weeklyXP")
        defaults.set(gems, forKey: "gems")
        defaults.set(hearts, forKey: "hearts")
        defaults.set(streak, forKey: "streak")
        defaults.set(longestStreak, forKey: "longestStreak")
        defaults.set(lastActiveDay, forKey: "lastActiveDay")
        defaults.set(lastHeartAt, forKey: "lastHeartAt")
        defaults.set(dailyXP, forKey: "dailyXP")
        defaults.set(dailyXPDay, forKey: "dailyXPDay")
        defaults.set(weeklyXPWeekStart, forKey: "weeklyXPWeekStart")
        defaults.set(practicedToday, forKey: "practicedToday")
        defaults.set(Array(completedLessonIDs), forKey: "completedLessonIDs")
        if let data = try? JSONEncoder().encode(lessonStars) {
            defaults.set(data, forKey: "lessonStars")
        }
    }
}

struct LessonResult {
    let xp: Int
    let stars: Int
    let accuracy: Double
    let firstClear: Bool
}

struct LeagueEntry: Identifiable {
    let id: String
    let name: String
    let xp: Int
    let isUser: Bool
}

enum LeagueBoard {
    static func entries(userName: String, weeklyXP: Int) -> [LeagueEntry] {
        var rows = [
            LeagueEntry(id: "mara", name: "Mara", xp: 240, isUser: false),
            LeagueEntry(id: "jonas", name: "Jonas", xp: 190, isUser: false),
            LeagueEntry(id: "sofia", name: "Sofia", xp: 155, isUser: false),
            LeagueEntry(id: "lukas", name: "Lukas", xp: 120, isUser: false),
            LeagueEntry(id: "nina", name: "Nina", xp: 95, isUser: false),
            LeagueEntry(id: "ben", name: "Ben", xp: 70, isUser: false),
            LeagueEntry(id: "emma", name: "Emma", xp: 45, isUser: false)
        ]
        rows.append(LeagueEntry(id: "user", name: userName, xp: weeklyXP, isUser: true))
        return rows.sorted { $0.xp > $1.xp }
    }
}
