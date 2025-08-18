import SwiftUI

struct ContentView: View {
    @StateObject private var manager = QuoteManager()
    @StateObject private var favorites = FavoriteSpellsManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var characterStore = CharacterStore()

    var body: some View {
        TabView {
            JSONQuoteView()
                .tabItem {
                    Label("Цитаты", systemImage: "quote.bubble")
                }

            RelationshipView()
                .tabItem {
                    Label("Отношения", systemImage: "heart.circle")
                }

            CompendiumView()
                .tabItem {
                    Label("Компендиум", systemImage: "book.fill")
                }

            NotesView()
                .tabItem {
                    Label("Заметки", systemImage: "note.text")
                }

            CharacterSheetView(characterStore: characterStore)
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
                    Color("BackgroundColor"),
                    Color("BackgroundColor").opacity(0.8),
                    Color("BackgroundColor")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .preferredColorScheme(themeManager.preferredColorScheme)
        .accentColor(.orange)

    }
}
