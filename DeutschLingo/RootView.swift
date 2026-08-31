import SwiftUI

struct OnboardingView: View {
    @Environment(ProgressStore.self) private var store
    @State private var page = 0
    @State private var name = ""
    @State private var goal = 20

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                welcome.tag(0)
                goalPage.tag(1)
                namePage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? AppTheme.green : AppTheme.locked)
                        .frame(width: index == page ? 22 : 8, height: 8)
                }
            }
            .padding(.bottom, 16)

            DuoButton(
                title: page == 2 ? "Start learning" : "Continue",
                enabled: page != 2 || !name.trimmingCharacters(in: .whitespaces).isEmpty || true
            ) {
                if page < 2 {
                    withAnimation { page += 1 }
                } else {
                    store.completeOnboarding(name: name, goal: goal)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    private var welcome: some View {
        VStack(spacing: 24) {
            Spacer()
            MascotOwl(mood: .cheer, size: 180)
            Text("Hallo! I'm Otto.")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.text)
            Text("I'll help you learn German with short lessons, streaks, and a little friendly pressure.")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            Spacer()
        }
    }

    private var goalPage: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Set a daily goal")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.text)
            Text("A little every day beats a lot once a week.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.muted)
            VStack(spacing: 12) {
                goalRow(10, "Casual", "5 minutes")
                goalRow(20, "Regular", "10 minutes")
                goalRow(30, "Serious", "15 minutes")
            }
            .padding(.horizontal, 24)
            Spacer()
        }
    }

    private func goalRow(_ value: Int, _ title: String, _ subtitle: String) -> some View {
        Button {
            goal = value
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                    Text("\(value) XP · \(subtitle)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.muted)
                }
                Spacer()
                if goal == value {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.green)
                        .font(.title2)
                }
            }
            .foregroundStyle(AppTheme.text)
            .padding(16)
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(goal == value ? AppTheme.green : AppTheme.divider, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var namePage: some View {
        VStack(spacing: 20) {
            Spacer()
            MascotOwl(mood: .idle, size: 120)
            Text("What should I call you?")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.text)
            TextField("Your name", text: $name)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding()
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.divider, lineWidth: 2)
                )
                .padding(.horizontal, 24)
            Spacer()
        }
    }
}

struct RootView: View {
    @Environment(ProgressStore.self) private var store

    var body: some View {
        Group {
            if store.hasOnboarded {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: store.hasOnboarded)
    }
}

struct MainTabView: View {
    @Environment(ProgressStore.self) private var store

    var body: some View {
        TabView {
            LearnView()
                .tabItem { Label("Learn", systemImage: "map.fill") }
            PracticeView()
                .tabItem { Label("Practice", systemImage: "dumbbell.fill") }
            LeagueView()
                .tabItem { Label("League", systemImage: "shield.fill") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
        .tint(AppTheme.green)
        .onAppear { store.regenerateHearts() }
    }
}
