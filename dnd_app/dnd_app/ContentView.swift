import SwiftUI

// MARK: - Color Extension for Hex Support  
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView: View {
    @StateObject private var manager = QuoteManager()
    @StateObject private var spells = SpellsStore()
    @StateObject private var favorites = FavoriteSpellsManager()
    @StateObject private var themeManager = ThemeManager()

    var body: some View {
        TabView {
            QuoteView()
                .environmentObject(manager)
                .tabItem {
                    Label("Цитаты", systemImage: "quote.bubble")
                }

            RelationshipView()
                .tabItem {
                    Label("Отношения", systemImage: "heart.circle")
                }

            SpellsView(store: spells, favorites: favorites, themeManager: themeManager)
                .tabItem {
                    Label("Заклинания", systemImage: "wand.and.stars")
                }

            NotesView()
                .tabItem {
                    Label("Заметки", systemImage: "note.text")
                }

            CharacterSheetView()
                .tabItem {
                    Label("Персонаж", systemImage: "person.text.rectangle")
                }

            // SettingsView(themeManager: themeManager)
            //     .tabItem {
            //         Label("Настройки", systemImage: "gearshape.fill")
            //     }
        }
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#fceeda"),
                    Color(hex: "#fceeda").opacity(0.8),
                    Color(hex: "#fceeda")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .preferredColorScheme(themeManager.preferredColorScheme)
        .accentColor(.orange)
    }
}
