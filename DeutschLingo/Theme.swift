import SwiftUI

enum AppTheme {
    static let green = Color(hex: 0x58CC02)
    static let greenPressed = Color(hex: 0x46A302)
    static let greenDark = Color(hex: 0x58A700)
    static let blue = Color(hex: 0x1CB0F6)
    static let blueDark = Color(hex: 0x1899D6)
    static let gold = Color(hex: 0xFFC800)
    static let goldDark = Color(hex: 0xE5A100)
    static let heart = Color(hex: 0xFF4B4B)
    static let heartDark = Color(hex: 0xEA2B2B)
    static let streak = Color(hex: 0xFF9600)
    static let purple = Color(hex: 0xCE82FF)
    static let purpleDark = Color(hex: 0xA568CC)
    static let locked = Color(hex: 0xE5E5E5)
    static let lockedDark = Color(hex: 0xAFAFAF)

    static let background = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 19 / 255, green: 31 / 255, blue: 36 / 255, alpha: 1)
            : UIColor.white
    })

    static let surface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 32 / 255, green: 47 / 255, blue: 54 / 255, alpha: 1)
            : UIColor(red: 247 / 255, green: 247 / 255, blue: 247 / 255, alpha: 1)
    })

    static let text = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 241 / 255, green: 247 / 255, blue: 251 / 255, alpha: 1)
            : UIColor(red: 60 / 255, green: 60 / 255, blue: 60 / 255, alpha: 1)
    })

    static let muted = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 175 / 255, green: 175 / 255, blue: 175 / 255, alpha: 1)
            : UIColor(red: 175 / 255, green: 175 / 255, blue: 175 / 255, alpha: 1)
    })

    static let divider = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 55 / 255, green: 70 / 255, blue: 79 / 255, alpha: 1)
            : UIColor(red: 229 / 255, green: 229 / 255, blue: 229 / 255, alpha: 1)
    })

    static let card = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 32 / 255, green: 47 / 255, blue: 54 / 255, alpha: 1)
            : UIColor.white
    })
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

struct DuoButton: View {
    let title: String
    var color: Color = AppTheme.green
    var shadow: Color = AppTheme.greenDark
    var foreground: Color = .white
    var enabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: {
            guard enabled else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            Text(title.uppercased())
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(enabled ? foreground : AppTheme.muted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(enabled ? color : AppTheme.locked)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .offset(y: enabled ? -4 : 0)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(enabled ? shadow : AppTheme.lockedDark)
        )
        .disabled(!enabled)
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.12), value: enabled)
    }
}

struct StatChip: View {
    let icon: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tint)
            Text(value)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.text)
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
    }
}
