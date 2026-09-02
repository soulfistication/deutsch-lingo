import SwiftUI

struct LearnView: View {
    @Environment(ProgressStore.self) private var store
    @State private var selectedLesson: Lesson?
    @State private var guidebookUnit: CourseUnit?
    @State private var showHearts = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Curriculum.units) { unit in
                        unitHeader(unit)
                        path(for: unit)
                            .padding(.bottom, 28)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        Text("🇩🇪")
                        Text("German")
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundStyle(AppTheme.text)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        StatChip(icon: "flame.fill", value: "\(store.streak)", tint: AppTheme.streak)
                        StatChip(icon: "diamond.fill", value: "\(store.gems)", tint: AppTheme.blue)
                        Button {
                            showHearts = true
                        } label: {
                            StatChip(icon: "heart.fill", value: "\(store.hearts)", tint: AppTheme.heart)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .fullScreenCover(item: $selectedLesson) { lesson in
                LessonSessionView(lesson: lesson)
            }
            .sheet(item: $guidebookUnit) { unit in
                GuidebookView(unit: unit)
            }
            .sheet(isPresented: $showHearts) {
                HeartsSheet()
                    .presentationDetents([.medium])
            }
        }
    }

    private func unitHeader(_ unit: CourseUnit) -> some View {
        let color = Color(hex: unit.colorHex)
        return HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("UNIT \(unit.number)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.85))
                Text(unit.title.uppercased())
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                Text(unit.subtitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
            }
            Spacer()
            Button {
                guidebookUnit = unit
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "book.fill")
                    Text("GUIDE")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.55), lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 8)
        .shadow(color: color.opacity(0.35), radius: 8, y: 4)
    }

    private func path(for unit: CourseUnit) -> some View {
        VStack(spacing: 22) {
            ForEach(Array(unit.lessons.enumerated()), id: \.element.id) { index, lesson in
                let offsets: [CGFloat] = [0, -56, -86, -40, 20, 64, 86, 40]
                LessonNode(
                    lesson: lesson,
                    unitColor: Color(hex: unit.colorHex),
                    unlocked: store.isLessonUnlocked(lesson.id),
                    completed: store.completedLessonIDs.contains(lesson.id),
                    stars: store.stars(for: lesson.id),
                    isCurrent: store.isLessonUnlocked(lesson.id) && !store.completedLessonIDs.contains(lesson.id)
                ) {
                    if store.hearts == 0 {
                        showHearts = true
                    } else if store.isLessonUnlocked(lesson.id) {
                        selectedLesson = lesson
                    }
                }
                .offset(x: offsets[index % offsets.count])
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
    }
}

struct LessonNode: View {
    let lesson: Lesson
    let unitColor: Color
    let unlocked: Bool
    let completed: Bool
    let stars: Int
    let isCurrent: Bool
    let action: () -> Void

    @State private var pulse = false

    var body: some View {
        VStack(spacing: 8) {
            Button(action: action) {
                ZStack {
                    Circle()
                        .fill(shadowColor)
                        .frame(width: 74, height: 74)
                        .offset(y: 5)
                    Circle()
                        .fill(fillColor)
                        .frame(width: 74, height: 74)
                    Circle()
                        .stroke(.white.opacity(unlocked ? 0.35 : 0.15), lineWidth: 4)
                        .frame(width: 62, height: 62)
                    Image(systemName: unlocked ? lesson.symbol : "lock.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(isCurrent && pulse ? 1.06 : 1)
            }
            .buttonStyle(.plain)
            .disabled(!unlocked)
            .accessibilityLabel(lesson.title)

            if completed {
                HStack(spacing: 2) {
                    ForEach(1...3, id: \.self) { i in
                        Image(systemName: i <= stars ? "star.fill" : "star")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(i <= stars ? AppTheme.gold : AppTheme.lockedDark)
                    }
                }
            } else if isCurrent {
                Text("START")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(unitColor)
            } else {
                Text(unlocked ? lesson.title : "Locked")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(AppTheme.muted)
            }
        }
        .onAppear {
            if isCurrent {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
        }
    }

    private var fillColor: Color {
        if completed { return AppTheme.gold }
        if unlocked { return unitColor }
        return AppTheme.lockedDark
    }

    private var shadowColor: Color {
        if completed { return AppTheme.goldDark }
        if unlocked { return unitColor.opacity(0.7) }
        return Color(hex: 0x8C8C8C)
    }
}

struct GuidebookView: View {
    let unit: CourseUnit
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(unit.vocab) { entry in
                HStack(spacing: 12) {
                    SpeakButton(text: entry.german)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.german)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text(entry.english)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.muted)
                    }
                    Spacer()
                    if let hint = entry.hint {
                        Text(hint)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.muted)
                    }
                }
                .listRowBackground(AppTheme.card)
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle(unit.germanTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct HeartsSheet: View {
    @Environment(ProgressStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.heart)
            Text(store.hearts == 0 ? "You're out of hearts" : "Hearts")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
            Text("You have \(store.hearts) of \(ProgressStore.heartsMax). Missed answers cost a heart. They refill every \(ProgressStore.heartRegenMinutes) minutes, or refill now with gems.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let next = store.nextHeartDate {
                Text("Next heart at \(next.formatted(date: .omitted, time: .shortened))")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.muted)
            }

            DuoButton(title: "Refill for 10 gems", color: AppTheme.blue, shadow: AppTheme.blueDark, enabled: store.gems >= 10 && store.hearts < ProgressStore.heartsMax) {
                _ = store.buyHeartsIfPossible()
                dismiss()
            }
            Button("Practice instead") { dismiss() }
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.blue)
            Spacer()
        }
        .padding(24)
        .onAppear { store.regenerateHearts() }
    }
}
