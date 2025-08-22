import SwiftUI

struct ContentView: View {
    @StateObject private var manager = QuoteManager()
    @StateObject private var favorites = Favorites()
    @StateObject private var themeManager = ThemeManager()

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
            
            CharacterView()
                .tabItem {
                    Label("Персонаж", systemImage: "person.text.rectangle.fill")
                }
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
