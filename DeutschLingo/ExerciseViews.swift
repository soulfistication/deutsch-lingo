import SwiftUI

struct MultipleChoiceView: View {
    let item: MultipleChoice
    let listening: Bool
    let feedback: LessonSessionView.Feedback?
    let onResolved: (ExerciseOutcome) -> Void

    @State private var selected: Int?

    private var locked: Bool { feedback != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(listening ? "Tap what you hear" : (item.promptLanguage == .german ? "What does this mean?" : "Translate this"))
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.text)
                .padding(.horizontal, 24)
                .padding(.top, 12)

            HStack(alignment: .center, spacing: 12) {
                if let speak = item.speakText {
                    SpeakButton(text: speak, large: listening)
                }
                if !listening {
                    Text(item.prompt)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.text)
                }
            }
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                ForEach(item.options.indices, id: \.self) { i in
                    option(i)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
            footer
        }
        .onAppear {
            selected = nil
            if listening, let speak = item.speakText {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    SpeechService.shared.speak(speak)
                }
            }
        }
    }

    private func option(_ i: Int) -> some View {
        let isSelected = selected == i
        let isCorrect = i == item.correctIndex
        var border = AppTheme.divider
        var fill = AppTheme.card
        if locked, isCorrect {
            border = AppTheme.green
            fill = AppTheme.green.opacity(0.12)
        } else if locked, isSelected, !isCorrect {
            border = AppTheme.heart
            fill = AppTheme.heart.opacity(0.12)
        } else if isSelected {
            border = AppTheme.blue
            fill = AppTheme.blue.opacity(0.1)
        }

        return Button {
            guard !locked else { return }
            selected = i
        } label: {
            Text(item.options[i])
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(fill)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(border, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .disabled(locked)
    }

    private var footer: some View {
        FeedbackFooter(
            canCheck: selected != nil,
            feedback: feedback,
            correctAnswer: item.options[item.correctIndex],
            tip: item.tip
        ) {
            guard let selected else { return }
            if selected == item.correctIndex {
                onResolved(.correct)
            } else {
                onResolved(.wrong(item.options[item.correctIndex]))
            }
        } continueAction: {
            onResolved(.continueAfterFeedback)
        }
    }
}

struct WordBankView: View {
    let item: WordBank
    let feedback: LessonSessionView.Feedback?
    let onResolved: (ExerciseOutcome) -> Void

    @State private var bank: [BankToken] = []
    @State private var built: [BankToken] = []
    @State private var didSetup = false

    struct BankToken: Identifiable, Equatable {
        let id: UUID
        let text: String
    }

    private var locked: Bool { feedback != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Build this sentence")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.text)
                .padding(.horizontal, 24)
                .padding(.top, 12)

            HStack(spacing: 10) {
                if let speak = item.speakText { SpeakButton(text: speak) }
                Text(item.prompt)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.text)
            }
            .padding(.horizontal, 24)

            sentenceSlot
                .padding(.horizontal, 24)

            FlowLayout(spacing: 8) {
                ForEach(bank) { token in
                    chip(token, inBank: true)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .onAppear {
                if !didSetup {
                    bank = item.tokens.shuffled().map { BankToken(id: UUID(), text: $0) }
                    didSetup = true
                }
            }

            Spacer()
            FeedbackFooter(
                canCheck: !built.isEmpty,
                feedback: feedback,
                correctAnswer: item.correct.joined(separator: " "),
                tip: nil
            ) {
                let answer = built.map(\.text)
                if answer == item.correct {
                    onResolved(.correct)
                } else {
                    onResolved(.wrong(item.correct.joined(separator: " ")))
                }
            } continueAction: {
                onResolved(.continueAfterFeedback)
            }
        }
    }

    private var sentenceSlot: some View {
        VStack(alignment: .leading, spacing: 10) {
            if built.isEmpty {
                Text("Tap the words below")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.muted)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(built) { token in
                        chip(token, inBank: false)
                    }
                }
            }
            Rectangle()
                .fill(AppTheme.divider)
                .frame(height: 2)
        }
        .frame(minHeight: 72, alignment: .bottom)
    }

    private func chip(_ token: BankToken, inBank: Bool) -> some View {
        Button {
            guard !locked else { return }
            if inBank {
                bank.removeAll { $0.id == token.id }
                built.append(token)
            } else {
                built.removeAll { $0.id == token.id }
                bank.append(token)
            }
        } label: {
            Text(token.text)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppTheme.divider, lineWidth: 2)
                )
                .shadow(color: AppTheme.divider.opacity(0.8), radius: 0, y: 3)
        }
        .buttonStyle(.plain)
        .disabled(locked)
    }
}

struct FillBlankView: View {
    let item: FillBlank
    let feedback: LessonSessionView.Feedback?
    let onResolved: (ExerciseOutcome) -> Void
    @State private var selected: Int?

    private var locked: Bool { feedback != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Fill in the blank")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.text)
                .padding(.horizontal, 24)
                .padding(.top, 12)

            HStack(spacing: 10) {
                if let speak = item.speakText { SpeakButton(text: speak) }
                Text(item.translation)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.muted)
            }
            .padding(.horizontal, 24)

            HStack(spacing: 6) {
                if !item.before.isEmpty {
                    Text(item.before)
                }
                Text(selected.map { item.options[$0] } ?? "______")
                    .foregroundStyle(AppTheme.blue)
                    .underline()
                if !item.after.isEmpty {
                    Text(item.after)
                }
            }
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundStyle(AppTheme.text)
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                ForEach(item.options.indices, id: \.self) { i in
                    Button {
                        guard !locked else { return }
                        selected = i
                    } label: {
                        Text(item.options[i])
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.text)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(selected == i ? AppTheme.blue.opacity(0.12) : AppTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(border(for: i), lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(locked)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
            FeedbackFooter(
                canCheck: selected != nil,
                feedback: feedback,
                correctAnswer: "\(item.before) \(item.options[item.correctIndex]) \(item.after)".replacingOccurrences(of: "  ", with: " "),
                tip: nil
            ) {
                guard let selected else { return }
                if selected == item.correctIndex {
                    onResolved(.correct)
                } else {
                    onResolved(.wrong(item.options[item.correctIndex]))
                }
            } continueAction: {
                onResolved(.continueAfterFeedback)
            }
        }
    }

    private func border(for i: Int) -> Color {
        if locked, i == item.correctIndex { return AppTheme.green }
        if locked, selected == i { return AppTheme.heart }
        if selected == i { return AppTheme.blue }
        return AppTheme.divider
    }
}

struct MatchPairsView: View {
    let item: MatchPairs
    let onResolved: (ExerciseOutcome) -> Void

    @State private var left: [VocabEntry]
    @State private var right: [VocabEntry]
    @State private var selectedLeft: String?
    @State private var selectedRight: String?
    @State private var matched: Set<String> = []
    @State private var wrongFlash = false

    init(item: MatchPairs, onResolved: @escaping (ExerciseOutcome) -> Void) {
        self.item = item
        self.onResolved = onResolved
        _left = State(initialValue: item.pairs.shuffled())
        _right = State(initialValue: item.pairs.shuffled())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Tap the matching pairs")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.text)
                .padding(.horizontal, 24)
                .padding(.top, 12)

            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 10) {
                    ForEach(left) { entry in
                        pairButton(entry.german, isLeft: true, matched: matched.contains(entry.german), selected: selectedLeft == entry.german)
                    }
                }
                VStack(spacing: 10) {
                    ForEach(right) { entry in
                        pairButton(entry.english, isLeft: false, matched: matched.contains(entry.german), selected: selectedRight == entry.english)
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
            Text("Match all pairs to continue")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.muted)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 28)
        }
    }

    private func pairButton(_ title: String, isLeft: Bool, matched: Bool, selected: Bool) -> some View {
        Button {
            guard !matched else { return }
            if isLeft {
                selectedLeft = title
            } else {
                selectedRight = title
            }
            evaluate()
        } label: {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(matched ? AppTheme.greenDark : AppTheme.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(matched ? AppTheme.green.opacity(0.15) : (selected ? AppTheme.blue.opacity(0.12) : AppTheme.card))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(matched ? AppTheme.green : (selected ? AppTheme.blue : AppTheme.divider), lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .disabled(matched)
        .opacity(matched ? 0.7 : 1)
    }

    private func evaluate() {
        guard let l = selectedLeft, let r = selectedRight else { return }
            if item.pairs.contains(where: { $0.german == l && $0.english == r }) {
            matched.insert(l)
            selectedLeft = nil
            selectedRight = nil
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            if matched.count == item.pairs.count {
                onResolved(.correct)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    onResolved(.continueAfterFeedback)
                }
            }
        } else {
            wrongFlash = true
            onResolved(.miss)
            selectedLeft = nil
            selectedRight = nil
        }
    }
}

struct FeedbackFooter: View {
    let canCheck: Bool
    let feedback: LessonSessionView.Feedback?
    let correctAnswer: String
    let tip: String?
    let checkAction: () -> Void
    let continueAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            if let feedback {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isCorrect(feedback) ? "Nice!" : "Correct answer:")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                        if !isCorrect(feedback) {
                            Text(correctAnswer)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        } else if let tip, !tip.isEmpty {
                            Text(tip)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                    }
                    Spacer()
                    Image(systemName: isCorrect(feedback) ? "checkmark.circle.fill" : "multiply.circle.fill")
                        .font(.system(size: 28, weight: .bold))
                }
                .foregroundStyle(isCorrect(feedback) ? AppTheme.greenDark : AppTheme.heartDark)
                DuoButton(
                    title: "Continue",
                    color: isCorrect(feedback) ? AppTheme.green : AppTheme.heart,
                    shadow: isCorrect(feedback) ? AppTheme.greenDark : AppTheme.heartDark,
                    action: continueAction
                )
            } else {
                DuoButton(title: "Check", enabled: canCheck, action: checkAction)
            }
        }
        .padding(20)
        .background(
            (feedback.map { isCorrect($0) ? AppTheme.green.opacity(0.12) : AppTheme.heart.opacity(0.12) } ?? AppTheme.background)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func isCorrect(_ feedback: LessonSessionView.Feedback) -> Bool {
        if case .correct = feedback { return true }
        return false
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, origin) in result.origins.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (origins: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var origins: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var usedWidth: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            usedWidth = max(usedWidth, x)
        }
        return (origins, CGSize(width: usedWidth, height: y + rowHeight))
    }
}
