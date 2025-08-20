import SwiftUI

struct ContentView: View {
    @StateObject private var manager = QuoteManager()
    @StateObject private var spells = CompendiumStore()
    @StateObject private var favorites = Favorites()
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
        .commonBackground()
        .preferredColorScheme(themeManager.preferredColorScheme)
        .accentColor(.orange)

    }
}
