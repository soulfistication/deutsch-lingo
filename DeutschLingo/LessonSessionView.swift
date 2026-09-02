import SwiftUI

struct LessonSessionView: View {
    let lesson: Lesson
    @Environment(ProgressStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var queue: [Exercise]
    @State private var index = 0
    @State private var correctCount = 0
    @State private var answered = 0
    @State private var retriedIDs: Set<String> = []
    @State private var feedback: Feedback?
    @State private var result: LessonResult?
    @State private var showOutOfHearts = false
    @State private var shakeWrong = false

    enum Feedback {
        case correct
        case wrong(String)
    }

    init(lesson: Lesson) {
        self.lesson = lesson
        _queue = State(initialValue: lesson.exercises)
    }

    private var progress: Double {
        guard !queue.isEmpty else { return 1 }
        return Double(index) / Double(queue.count)
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            if let result {
                LessonCompleteView(lesson: lesson, result: result) {
                    dismiss()
                }
            } else if queue.indices.contains(index) {
                VStack(spacing: 0) {
                    header
                    ExerciseHost(
                        exercise: queue[index],
                        feedback: feedback,
                        onResolved: handle
                    )
                }
            }
        }
        .sheet(isPresented: $showOutOfHearts) {
            HeartsSheet()
                .presentationDetents([.medium])
                .onDisappear {
                    if store.hearts == 0 { dismiss() }
                }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
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
                        .fill(AppTheme.green)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 16)
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(AppTheme.heart)
                Text("\(store.hearts)")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppTheme.heart)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    private func handle(_ outcome: ExerciseOutcome) {
        switch outcome {
        case .correct:
            feedback = .correct
            correctCount += 1
            answered += 1
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .wrong(let answer):
            feedback = .wrong(answer)
            answered += 1
            store.missAnswer()
            shakeWrong.toggle()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            let current = queue[index]
            if !retriedIDs.contains(current.id) {
                retriedIDs.insert(current.id)
                queue.append(current)
            }
            if store.hearts == 0 {
                showOutOfHearts = true
            }
        case .miss:
            store.missAnswer()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            if store.hearts == 0 {
                showOutOfHearts = true
            }
        case .continueAfterFeedback:
            feedback = nil
            if index + 1 >= queue.count {
                result = store.completeLesson(id: lesson.id, correct: correctCount, total: max(answered, 1))
            } else {
                index += 1
            }
        }
    }
}

enum ExerciseOutcome {
    case correct
    case wrong(String)
    case miss
    case continueAfterFeedback
}

struct LessonCompleteView: View {
    let lesson: Lesson
    let result: LessonResult
    let done: () -> Void

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            ConfettiView().opacity(0.9)
            VStack(spacing: 18) {
                Spacer()
                MascotOwl(mood: .cheer, size: 150)
                Text(result.stars == 3 ? "Perfect!" : "Lesson complete")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppTheme.text)
                Text(lesson.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.muted)
                HStack(spacing: 6) {
                    ForEach(1...3, id: \.self) { i in
                        Image(systemName: i <= result.stars ? "star.fill" : "star")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(i <= result.stars ? AppTheme.gold : AppTheme.lockedDark)
                    }
                }
                HStack(spacing: 12) {
                    resultChip("bolt.fill", "+\(result.xp) XP", AppTheme.gold)
                    resultChip("target", "\(Int(result.accuracy * 100))%", AppTheme.blue)
                }
                .padding(.top, 8)
                Spacer()
                DuoButton(title: "Continue", action: done)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
            }
        }
    }

    private func resultChip(_ icon: String, _ text: String, _ color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.system(size: 16, weight: .heavy, design: .rounded))
        .foregroundStyle(color)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}

struct ExerciseHost: View {
    let exercise: Exercise
    let feedback: LessonSessionView.Feedback?
    let onResolved: (ExerciseOutcome) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch exercise {
                case .multipleChoice(let item):
                    MultipleChoiceView(item: item, listening: false, feedback: feedback, onResolved: onResolved)
                case .listenChoose(let item):
                    MultipleChoiceView(item: item, listening: true, feedback: feedback, onResolved: onResolved)
                case .wordBank(let item):
                    WordBankView(item: item, feedback: feedback, onResolved: onResolved)
                case .fillBlank(let item):
                    FillBlankView(item: item, feedback: feedback, onResolved: onResolved)
                case .matchPairs(let item):
                    MatchPairsView(item: item, onResolved: onResolved)
                }
            }
            .id(exercise.id)
        }
    }
}
