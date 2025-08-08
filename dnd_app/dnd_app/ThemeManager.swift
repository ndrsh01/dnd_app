import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode = false
    
    var preferredColorScheme: ColorScheme? {
        return isDarkMode ? .dark : .light
    }
    
    var colorScheme: ColorScheme {
        return isDarkMode ? .dark : .light
    }
    
    // Цвета для светлой темы
    static let lightBackgroundColor = Color(hex: "#fceeda")
    
    // Цвета для темной темы  
    static let darkBackgroundGradient = LinearGradient(
        colors: [
            Color.black,
            Color.orange.opacity(0.1),
            Color.purple.opacity(0.05)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Адаптивные цвета
    static func adaptiveBackground(for isDark: Bool) -> AnyView {
        if isDark {
            return AnyView(darkBackgroundGradient)
        } else {
            return AnyView(lightBackgroundColor)
        }
    }
    
    static func adaptiveCardBackground(for isDark: Bool) -> Color {
        return isDark ? Color(.systemGray6) : Color(.systemBackground)
    }
    
    static func adaptiveTextColor(for isDark: Bool) -> Color {
        return isDark ? .white : .primary
    }
    
    static func adaptiveSecondaryTextColor(for isDark: Bool) -> Color {
        return isDark ? .gray : .secondary
    }
    
    static func adaptiveBorderColor(for isDark: Bool) -> Color {
        return isDark ? Color(.systemGray4) : Color(.systemGray5)
    }
}
