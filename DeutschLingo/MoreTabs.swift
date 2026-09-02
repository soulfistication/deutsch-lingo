import SwiftUI

struct PracticeView: View {
    @Environment(ProgressStore.self) private var store
    @State private var sessionLesson: Lesson?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                MascotOwl(mood: .idle, size: 140)
                Text("Practice")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppTheme.text)
                Text("Review what you've learned. Finish a round to earn XP and refill a heart.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Daily goal")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppTheme.muted)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(AppTheme.locked)
                            Capsule()
                                .fill(AppTheme.gold)
                                .frame(width: geo.size.width * store.dailyProgress)
                        }
                    }
                    .frame(height: 14)
                    Text("\(store.dailyXP) / \(store.dailyGoal) XP")
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppTheme.text)
                }
                .padding(20)
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.divider, lineWidth: 2)
                )
                .padding(.horizontal, 24)

                Spacer()
                DuoButton(title: "Start practice") {
                    sessionLesson = makePracticeLesson()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Practice")
            .fullScreenCover(item: $sessionLesson) { lesson in
                PracticeSessionView(lesson: lesson)
            }
        }
    }

    private func makePracticeLesson() -> Lesson {
        let completed = Curriculum.units.flatMap(\.lessons).filter { store.completedLessonIDs.contains($0.id) }
        let pool = (completed.isEmpty ? [Curriculum.units[0].lessons[0]] : completed).flatMap(\.exercises)
        let picked = Array(pool.shuffled().prefix(8))
        return Lesson(id: "practice-\(UUID().uuidString)", title: "Practice", symbol: "dumbbell.fill", xpReward: 5, exercises: picked)
    }
}

struct PracticeSessionView: View {
    let lesson: Lesson
    @Environment(ProgressStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var index = 0
    @State private var feedback: LessonSessionView.Feedback?
    @State private var finished = false
    @State private var correctCount = 0

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            if finished {
                VStack(spacing: 18) {
                    Spacer()
                    MascotOwl(mood: .happy, size: 140)
                    Text("Nice review")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                    Text("+\(lesson.xpReward) XP  ·  +1 heart")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.muted)
                    Spacer()
                    DuoButton(title: "Done") { dismiss() }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 28)
                }
            } else if lesson.exercises.indices.contains(index) {
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundStyle(AppTheme.muted)
                                .frame(width: 36, height: 36)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(AppTheme.locked)
                                Capsule()
                                    .fill(AppTheme.blue)
                                    .frame(width: geo.size.width * Double(index) / Double(max(lesson.exercises.count, 1)))
                            }
                        }
                        .frame(height: 16)
                    }
                    .padding(.horizontal, 16)
                    ExerciseHost(exercise: lesson.exercises[index], feedback: feedback, onResolved: handle)
                }
            }
        }
    }

    private func handle(_ outcome: ExerciseOutcome) {
        switch outcome {
        case .correct:
            feedback = .correct
            correctCount += 1
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .wrong(let answer):
            feedback = .wrong(answer)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .miss:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .continueAfterFeedback:
            feedback = nil
            if index + 1 >= lesson.exercises.count {
                store.refillHeartFromPractice()
                finished = true
            } else {
                index += 1
            }
        }
    }
}

struct LeagueView: View {
    @Environment(ProgressStore.self) private var store

    private var rows: [LeagueEntry] {
        LeagueBoard.entries(userName: store.displayName, weeklyXP: store.weeklyXP)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 8) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.gold)
                        Text("Emerald League")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                        Text("Weekly XP resets every Monday")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.muted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                ForEach(Array(rows.enumerated()), id: \.element.id) { index, entry in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundStyle(index < 3 ? AppTheme.gold : AppTheme.muted)
                            .frame(width: 28)
                        Circle()
                            .fill(entry.isUser ? AppTheme.green : AppTheme.blue.opacity(0.25))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(String(entry.name.prefix(1)))
                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                                    .foregroundStyle(entry.isUser ? .white : AppTheme.text)
                            )
                        Text(entry.name)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                        Spacer()
                        Text("\(entry.xp) XP")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundStyle(AppTheme.muted)
                    }
                    .listRowBackground(entry.isUser ? AppTheme.green.opacity(0.12) : AppTheme.card)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("League")
        }
    }
}

struct ProfileView: View {
    @Environment(ProgressStore.self) private var store
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        MascotOwl(mood: .idle, size: 72)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.displayName)
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                            Text("Learning German")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppTheme.muted)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Stats") {
                    stat("Total XP", "\(store.xp)", "bolt.fill", AppTheme.gold)
                    stat("Streak", "\(store.streak) days", "flame.fill", AppTheme.streak)
                    stat("Longest streak", "\(store.longestStreak) days", "crown.fill", AppTheme.purple)
                    stat("Lessons", "\(store.completedCount) / \(store.totalLessons)", "checkmark.seal.fill", AppTheme.green)
                    stat("Gems", "\(store.gems)", "diamond.fill", AppTheme.blue)
                }

                Section("Achievements") {
                    achievement("First step", "Finish your first lesson", store.completedCount >= 1)
                    achievement("On fire", "Reach a 3-day streak", store.longestStreak >= 3)
                    achievement("Dedicated", "Reach a 7-day streak", store.longestStreak >= 7)
                    achievement("Scholar", "Earn 100 XP", store.xp >= 100)
                    achievement("Hallo!", "Complete Unit 1", unitComplete("greetings"))
                    achievement("Perfectionist", "Get 3 stars on any lesson", store.lessonStars.values.contains { $0 >= 3 })
                }

                Section("Settings") {
                    Toggle("Dark mode", isOn: Binding(
                        get: { store.prefersDarkMode },
                        set: { _ in store.toggleDarkMode() }
                    ))
                    Picker("Daily goal", selection: Binding(
                        get: { store.dailyGoal },
                        set: { store.completeOnboarding(name: store.displayName, goal: $0) }
                    )) {
                        Text("10 XP").tag(10)
                        Text("20 XP").tag(20)
                        Text("30 XP").tag(30)
                    }
                    Button("Reset progress", role: .destructive) {
                        confirmReset = true
                    }
                }
            }
            .navigationTitle("Profile")
            .confirmationDialog("Reset all progress?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset", role: .destructive) { store.resetProgress() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func unitComplete(_ id: String) -> Bool {
        guard let unit = Curriculum.units.first(where: { $0.id == id }) else { return false }
        return unit.lessons.allSatisfy { store.completedLessonIDs.contains($0.id) }
    }

    private func stat(_ title: String, _ value: String, _ icon: String, _ tint: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .frame(width: 28)
            Text(title)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.muted)
        }
    }

    private func achievement(_ title: String, _ subtitle: String, _ unlocked: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: unlocked ? "medal.fill" : "lock.fill")
                .foregroundStyle(unlocked ? AppTheme.gold : AppTheme.muted)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.muted)
            }
            Spacer()
        }
        .opacity(unlocked ? 1 : 0.55)
    }
}
