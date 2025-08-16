import SwiftUI

// MARK: - Common Styles

struct CommonButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let isPrimary: Bool
    
    init(backgroundColor: Color = .orange, foregroundColor: Color = .white, isPrimary: Bool = true) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.isPrimary = isPrimary
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded))
            .fontWeight(.medium)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(
                        color: backgroundColor.opacity(0.3),
                        radius: configuration.isPressed ? 2 : 4,
                        x: 0,
                        y: configuration.isPressed ? 1 : 2
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded))
            .fontWeight(.medium)
            .foregroundColor(.orange)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.1))
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.headline, design: .rounded))
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CommonTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.body, design: .rounded))
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

struct CommonSearchFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.body, design: .rounded))
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
            .cornerRadius(12)
    }
}

// MARK: - Common Views

struct CommonButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: CommonButtonStyle
    
    init(_ title: String, icon: String? = nil, style: CommonButtonStyle = CommonButtonStyle(), action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                        .dynamicTypeSize(.small ... .xLarge)
                }
                Text(title)
            }
        }
        .buttonStyle(style)
    }
}

struct CommonSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                        .dynamicTypeSize(.small ... .xLarge)
                }
                Text(title)
            }
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

struct CommonCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .modifier(CardStyle())
    }
}

struct CommonSectionHeader: View {
    let title: String
    let icon: String?
    
    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.headline)
                    .dynamicTypeSize(.small ... .xLarge)
                    .foregroundColor(.orange)
            }
            Text(title)
        }
        .modifier(SectionHeaderStyle())
    }
}

// MARK: - Common Spacing

struct CommonSpacing {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 20
    static let extraLarge: CGFloat = 24
}

// MARK: - Common Colors

struct CommonColors {
    static let primary = Color.orange
    static let secondary = Color.blue
    static let success = Color.green
    static let warning = Color.yellow
    static let error = Color.red
    static let background = Color(hex: "#fceeda")
    static let cardBackground = Color(.systemBackground)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
}

// MARK: - Common Fonts

struct CommonFonts {
    static let title = Font.system(.title, design: .rounded).weight(.bold)
    static let title2 = Font.system(.title2, design: .rounded).weight(.semibold)
    static let title3 = Font.system(.title3, design: .rounded).weight(.medium)
    static let headline = Font.system(.headline, design: .rounded).weight(.semibold)
    static let body = Font.system(.body, design: .rounded)
    static let subheadline = Font.system(.subheadline, design: .rounded).weight(.medium)
    static let caption = Font.system(.caption, design: .rounded)
}

// MARK: - Extensions

extension View {
    func commonCard() -> some View {
        self.modifier(CardStyle())
    }
    
    func commonTextField() -> some View {
        self.modifier(CommonTextFieldStyle())
    }
    
    func commonSearchField() -> some View {
        self.modifier(CommonSearchFieldStyle())
    }
    
    func commonSectionHeader() -> some View {
        self.modifier(SectionHeaderStyle())
    }
}


