import SwiftUI

struct MainTabView: View {
    @StateObject private var dataManager = DataManager()
    
    var body: some View {
        TabView {
            QuotesView()
                .environmentObject(dataManager)
                .tabItem {
                    Image(systemName: "quote.bubble")
                    Text("Цитаты")
                }
            
            CharactersView()
                .environmentObject(dataManager)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Персонажи")
                }
            
            DiceView()
                .environmentObject(dataManager)
                .tabItem {
                    Image(systemName: "dice")
                    Text("Кости")
                }
            
            SpellsView()
                .environmentObject(dataManager)
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Заклинания")
                }
            
            SettingsView()
                .environmentObject(dataManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Настройки")
                }
        }
        .accentColor(.orange)
    }
}

#Preview {
    MainTabView()
}
