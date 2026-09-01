import SwiftUI

struct MascotOwl: View {
    enum Mood {
        case idle, happy, sad, cheer

        var eyeScale: CGFloat {
            switch self {
            case .sad: 0.85
            case .cheer: 1.08
            default: 1
            }
        }

        var mouthTrim: CGFloat {
            switch self {
            case .sad: 0.35
            default: 0.7
            }
        }
    }

    var mood: Mood = .idle
    var size: CGFloat = 160

    var body: some View {
        ZStack {
            // body
            Ellipse()
                .fill(AppTheme.green)
                .frame(width: size * 0.92, height: size)
                .offset(y: size * 0.04)
                .shadow(color: AppTheme.greenDark.opacity(0.35), radius: 10, y: 8)

            // belly
            Ellipse()
                .fill(Color.white.opacity(0.95))
                .frame(width: size * 0.52, height: size * 0.48)
                .offset(y: size * 0.18)

            // face plate
            Ellipse()
                .fill(Color.white)
                .frame(width: size * 0.78, height: size * 0.52)
                .offset(y: -size * 0.16)

            eyes
            beak
            brows
        }
        .frame(width: size, height: size)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: mood)
        .accessibilityHidden(true)
    }

    private var eyes: some View {
        HStack(spacing: size * 0.08) {
            eye
            eye
        }
        .offset(y: -size * 0.18)
        .scaleEffect(mood.eyeScale)
    }

    private var eye: some View {
        ZStack {
            Circle()
                .fill(AppTheme.text)
                .frame(width: size * 0.22, height: size * 0.22)
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(x: -size * 0.04, y: -size * 0.04)
        }
    }

    private var beak: some View {
        Triangle()
            .fill(AppTheme.gold)
            .frame(width: size * 0.16, height: size * 0.14)
            .rotationEffect(.degrees(180))
            .offset(y: -size * 0.02)
            .shadow(color: AppTheme.goldDark.opacity(0.4), radius: 0, y: 1)
    }

    @ViewBuilder
    private var brows: some View {
        if mood == .sad {
            HStack(spacing: size * 0.22) {
                Capsule().fill(AppTheme.text).frame(width: size * 0.12, height: 3).rotationEffect(.degrees(18))
                Capsule().fill(AppTheme.text).frame(width: size * 0.12, height: 3).rotationEffect(.degrees(-18))
            }
            .offset(y: -size * 0.34)
        } else if mood == .cheer {
            Text("✦")
                .font(.system(size: size * 0.18))
                .offset(y: -size * 0.52)
                .foregroundStyle(AppTheme.gold)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct SpeakButton: View {
    let text: String
    var large: Bool = false

    var body: some View {
        Button {
            SpeechService.shared.speak(text)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: large ? 28 : 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: large ? 72 : 44, height: large ? 72 : 44)
                .background(AppTheme.blue)
                .clipShape(RoundedRectangle(cornerRadius: large ? 18 : 12, style: .continuous))
                .shadow(color: AppTheme.blueDark.opacity(0.45), radius: 0, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Play pronunciation")
    }
}

struct ConfettiView: View {
    @State private var pieces: [Piece] = []

    struct Piece: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var color: Color
        var speed: CGFloat
        var wobble: CGFloat
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                for piece in pieces {
                    var y = piece.y + CGFloat(t.truncatingRemainder(dividingBy: 4)) * piece.speed
                    y = y.truncatingRemainder(dividingBy: size.height + 40)
                    let x = piece.x + sin(t * 2 + piece.wobble) * 12
                    let rect = CGRect(x: x, y: y - 20, width: piece.size, height: piece.size * 1.4)
                    context.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(piece.color))
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            let colors: [Color] = [AppTheme.green, AppTheme.gold, AppTheme.blue, AppTheme.heart, AppTheme.purple]
            pieces = (0..<42).map { i in
                Piece(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: -200...800),
                    size: CGFloat.random(in: 6...12),
                    color: colors[i % colors.count],
                    speed: CGFloat.random(in: 40...90),
                    wobble: CGFloat.random(in: 0...6)
                )
            }
        }
    }
}
