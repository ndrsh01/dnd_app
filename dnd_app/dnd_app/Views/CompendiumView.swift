import SwiftUI

struct CompendiumView: View {
    @StateObject private var store = CompendiumStore()
    @StateObject private var favorites = Favorites()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.988, green: 0.933, blue: 0.855),
                        Color(red: 0.988, green: 0.933, blue: 0.855).opacity(0.9),
                        Color(red: 0.988, green: 0.933, blue: 0.855)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Main list
                    List {
                        NavigationLink(destination: SpellsTabView(store: store, favorites: favorites, themeManager: themeManager)) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                    .foregroundColor(.purple)
                                    .font(.title2)
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Заклинания")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Магические заклинания и их описания")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color(.systemBackground))
                        .listRowSeparator(.hidden)

                        NavigationLink(destination: BackgroundsTabView(store: store, favorites: favorites, themeManager: themeManager)) {
                            HStack {
                                Image(systemName: "person.3.sequence")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Предыстории")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Происхождение и история персонажа")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color(.systemBackground))
                        .listRowSeparator(.hidden)

                        NavigationLink(destination: FeatsTabView(store: store, favorites: favorites, themeManager: themeManager)) {
                            HStack {
                                Image(systemName: "star.circle")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Черты")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Особые способности и умения")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color(.systemBackground))
                        .listRowSeparator(.hidden)

                        NavigationLink(destination: BestiaryTabView()) {
                            HStack {
                                Image(systemName: "pawprint.circle")
                                    .foregroundColor(.green)
                                    .font(.title2)
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Бестиарий")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Монстры и существа")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color(.systemBackground))
                        .listRowSeparator(.hidden)

                        NavigationLink(destination: FavoritesTabView(store: store, favorites: favorites, themeManager: themeManager)) {
                            HStack {
                                Image(systemName: "heart.circle")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Избранное")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Сохраненные элементы")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color(.systemBackground))
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Компендиум")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Spells Tab View
struct SpellsTabView: View {
    @ObservedObject var store: CompendiumStore
    let favorites: Favorites
    let themeManager: ThemeManager
    @State private var showingFilters = false
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Поиск заклинаний...", text: $searchText)
                    .onChange(of: searchText) { 
                        store.updateSpellSearchText(searchText)
                    }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top)
            
            // Results
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(store.filteredSpells) { spell in
                        CompendiumSpellCard(spell: spell, favorites: favorites)
                            .id("\(spell.id)-\(favorites.spells.isFavorite(spell.name))")
                    }
                }
                .padding(.top)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingFilters = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.orange)
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            SpellFiltersView(store: store)
        }
    }
}

// MARK: - Backgrounds Tab View
struct BackgroundsTabView: View {
    @ObservedObject var store: CompendiumStore
    let favorites: Favorites
    let themeManager: ThemeManager
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Поиск предысторий...", text: $searchText)
                    .onChange(of: searchText) { 
                        store.updateBackgroundSearchText(searchText)
                    }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top)
            
            // Results
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(store.filteredBackgrounds) { background in
                        BackgroundCard(background: background, favorites: favorites)
                    }
                }
                .padding(.top)
            }
        }
    }
}

// MARK: - Feats Tab View
struct FeatsTabView: View {
    @ObservedObject var store: CompendiumStore
    let favorites: Favorites
    let themeManager: ThemeManager
    @State private var showingFilters = false
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Поиск черт...", text: $searchText)
                    .onChange(of: searchText) { 
                        store.updateFeatSearchText(searchText)
                    }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top)
            
            // Results
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(store.filteredFeats) { feat in
                        FeatCard(feat: feat, favorites: favorites)
                            .id("\(feat.id)-\(favorites.feats.isFavorite(feat.name))")
                    }
                }
                .padding(.top)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingFilters = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.orange)
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            FeatFiltersView(store: store)
        }
    }
}

// MARK: - Bestiary Tab View
struct BestiaryTabView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("Бестиарий")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Скоро здесь появится бестиарий с монстрами и существами")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// MARK: - Spell Filters View
struct SpellFiltersView: View {
    @ObservedObject var store: CompendiumStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.988, green: 0.933, blue: 0.855)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Уровень заклинания
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Уровень заклинания")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                                ForEach(0...9, id: \.self) { level in
                                    FilterButton(
                                        title: level == 0 ? "Заговоры" : "\(level) уровень",
                                        isSelected: store.spellFilters.selectedLevels.contains(level)
                                    ) {
                                        store.toggleSpellLevelFilter(level)
                                    }
                                }
                            }
                        }
                        
                        // Школа магии
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Школа магии")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                                let schoolNames = [
                                    ("evocation", "Воплощение"),
                                    ("conjuration", "Вызов"),
                                    ("illusion", "Иллюзия"),
                                    ("necromancy", "Некромантия"),
                                    ("abjuration", "Ограждение"),
                                    ("enchantment", "Очарование"),
                                    ("transmutation", "Преобразование"),
                                    ("divination", "Прорицание")
                                ]
                                
                                ForEach(schoolNames, id: \.0) { (key, displayName) in
                                    FilterButton(
                                        title: displayName,
                                        isSelected: store.spellFilters.selectedSchools.contains(key)
                                    ) {
                                        store.toggleSpellSchoolFilter(key)
                                    }
                                }
                            }
                        }
                        
                        // Класс персонажа
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Класс персонажа")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                                let classNames = [
                                    ("bard", "Бард"),
                                    ("sorcerer", "Волшебник"),
                                    ("druid", "Друид"),
                                    ("cleric", "Жрец"),
                                    ("warlock", "Колдун"),
                                    ("paladin", "Паладин"),
                                    ("ranger", "Следопыт"),
                                    ("wizard", "Чародей")
                                ]
                                
                                ForEach(classNames, id: \.0) { (key, displayName) in
                                    FilterButton(
                                        title: displayName,
                                        isSelected: store.spellFilters.selectedClasses.contains(key)
                                    ) {
                                        store.toggleSpellClassFilter(key)
                                    }
                                }
                            }
                        }
                        
                        // Дополнительные фильтры
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Дополнительные фильтры")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Только концентрация")
                                        .font(.body)
                                    Spacer()
                                    Toggle("", isOn: .init(
                                        get: { store.spellFilters.concentrationOnly },
                                        set: { _ in store.toggleSpellConcentrationFilter() }
                                    ))
                                    .toggleStyle(SwitchToggleStyle())
                                }
                                
                                HStack {
                                    Text("Только ритуалы")
                                        .font(.body)
                                    Spacer()
                                    Toggle("", isOn: .init(
                                        get: { store.spellFilters.ritualOnly },
                                        set: { _ in store.toggleSpellRitualFilter() }
                                    ))
                                    .toggleStyle(SwitchToggleStyle())
                                }
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Фильтры заклинаний")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Сбросить") {
                        store.clearSpellFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Feat Filters View
struct FeatFiltersView: View {
    @ObservedObject var store: CompendiumStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.988, green: 0.933, blue: 0.855)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Категории черт
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Категории черт")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                                ForEach(store.availableFeatCategories, id: \.self) { category in
                                    FilterButton(
                                        title: category,
                                        isSelected: store.featFilters.selectedCategories.contains(category)
                                    ) {
                                        store.toggleFeatCategoryFilter(category)
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Фильтры черт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Сбросить") {
                        store.clearFeatFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}



// MARK: - Favorites Tab View
struct FavoritesTabView: View {
    @ObservedObject var store: CompendiumStore
    let favorites: Favorites
    let themeManager: ThemeManager
    @State private var spellsCollapsed = false
    @State private var featsCollapsed = false
    @State private var backgroundsCollapsed = false
    
    @State private var favoriteSpells: [Spell] = []
    @State private var favoriteFeats: [Feat] = []
    @State private var favoriteBackgrounds: [Background] = []
    
    @MainActor
    private func updateFavorites() {
        favoriteSpells = store.spells.filter { favorites.spells.isFavorite($0.name) }
        favoriteFeats = store.feats.filter { favorites.feats.isFavorite($0.name) }
        favoriteBackgrounds = store.backgrounds.filter { favorites.backgrounds.isFavorite($0.name) }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.988, green: 0.933, blue: 0.855),
                    Color(red: 0.988, green: 0.933, blue: 0.855).opacity(0.9),
                    Color(red: 0.988, green: 0.933, blue: 0.855)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if favoriteSpells.isEmpty && favoriteFeats.isEmpty && favoriteBackgrounds.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Нет избранного")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Добавь заклинания, черты и предыстории в избранное для быстрого доступа")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if !favoriteSpells.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Button(action: { spellsCollapsed.toggle() }) {
                                        HStack {
                                            Text("Избранные заклинания (\(favoriteSpells.count))")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: spellsCollapsed ? "chevron.down" : "chevron.up")
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if !spellsCollapsed {
                                        ForEach(favoriteSpells) { spell in
                                            CompendiumSpellCard(spell: spell, favorites: favorites)
                                                .id("\(spell.id)-\(favorites.spells.isFavorite(spell.name))")
                                        }
                                    }
                                }
                            }
                            
                            if !favoriteFeats.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Button(action: { featsCollapsed.toggle() }) {
                                        HStack {
                                            Text("Избранные черты (\(favoriteFeats.count))")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: featsCollapsed ? "chevron.down" : "chevron.up")
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if !featsCollapsed {
                                        ForEach(favoriteFeats) { feat in
                                            FeatCard(feat: feat, favorites: favorites)
                                                .id("\(feat.id)-\(favorites.feats.isFavorite(feat.name))")
                                        }
                                    }
                                }
                            }
                            
                            if !favoriteBackgrounds.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Button(action: { backgroundsCollapsed.toggle() }) {
                                        HStack {
                                            Text("Избранные предыстории (\(favoriteBackgrounds.count))")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: backgroundsCollapsed ? "chevron.down" : "chevron.up")
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if !backgroundsCollapsed {
                                        ForEach(favoriteBackgrounds) { background in
                                            BackgroundCard(background: background, favorites: favorites)
                                                .id("\(background.id)-\(favorites.backgrounds.isFavorite(background.name))")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
            }
        }
        .onAppear {
            updateFavorites()
        }
        .onChange(of: favorites.spells.favorites) {
            updateFavorites()
        }
        .onChange(of: favorites.feats.favorites) {
            updateFavorites()
        }
        .onChange(of: favorites.backgrounds.favorites) {
            updateFavorites()
        }
    }
}





// MARK: - Background Card
struct BackgroundCard: View {
    let background: Background
    @ObservedObject var favorites: Favorites
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with name and expand button
            HStack {
                Text(background.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            favorites.backgrounds.toggle(background.name)
                        }
                    }) {
                        Image(systemName: favorites.backgrounds.isFavorite(background.name) ? "heart.fill" : "heart")
                            .foregroundColor(favorites.backgrounds.isFavorite(background.name) ? .red : .gray)
                            .font(.title2)
                            .scaleEffect(favorites.backgrounds.isFavorite(background.name) ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: favorites.backgrounds.isFavorite(background.name))
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.orange)
                            .font(.title3)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Expanded details (description)
            if isExpanded {
                Text(background.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}










