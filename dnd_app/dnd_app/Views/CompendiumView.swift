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
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        NavigationLink(destination: SpellsTabView(store: store, favorites: favorites, themeManager: themeManager)) {
                            CompendiumItem(
                                icon: "wand.and.stars",
                                color: .purple,
                                title: "Заклинания",
                                subtitle: "Магические заклинания и их описания"
                            )
                        }

                        NavigationLink(destination: BackgroundsTabView(store: store, favorites: favorites, themeManager: themeManager)) {
                            CompendiumItem(
                                icon: "person.3.sequence",
                                color: .blue,
                                title: "Предыстории",
                                subtitle: "Происхождение и история персонажа"
                            )
                        }

                        NavigationLink(destination: FeatsTabView(store: store, favorites: favorites, themeManager: themeManager)) {
                            CompendiumItem(
                                icon: "star.circle",
                                color: .orange,
                                title: "Черты",
                                subtitle: "Особые способности и умения"
                            )
                        }

                        NavigationLink(destination: BestiaryTabView(store: store, favorites: favorites, themeManager: themeManager)) {
                            CompendiumItem(
                                icon: "pawprint.circle",
                                color: .green,
                                title: "Бестиарий",
                                subtitle: "Монстры и существа"
                            )
                        }

                        NavigationLink(destination: FavoritesTabView(store: store, favorites: favorites, themeManager: themeManager)) {
                            CompendiumItem(
                                icon: "heart.circle",
                                color: .red,
                                title: "Избранное",
                                subtitle: "Сохраненные элементы"
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Компендиум")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct CompendiumItem: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1))
        )
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

// MARK: - Monster Card

struct MonsterCard: View {
    let monster: Monster
    let favorites: Favorites
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(monster.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if !monster.subtitle.isEmpty {
                        Text(monster.subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Favorite button
                Button(action: {
                    favorites.monsters.toggle(monster.name)
                }) {
                    Image(systemName: favorites.monsters.isFavorite(monster.name) ? "heart.fill" : "heart")
                        .foregroundColor(favorites.monsters.isFavorite(monster.name) ? .red : .gray)
                        .font(.title3)
                }
            }
            
            // Basic stats
            HStack(spacing: 16) {
                StatItem(title: "КД", value: "\(monster.ac.ac)", icon: "shield.fill", color: .blue)
                StatItem(title: "ХП", value: "\(monster.hp.hp)", icon: "heart.fill", color: .red)
                StatItem(title: "CR", value: monster.challenge.cr, icon: "star.fill", color: .orange)
            }
            
            // Expandable content
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    // Abilities
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Характеристики")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            AbilityItem(name: "СИЛ", score: monster.abilities.str.score, modifier: monster.abilities.str.modifierString)
                            AbilityItem(name: "ЛОВ", score: monster.abilities.dex.score, modifier: monster.abilities.dex.modifierString)
                            AbilityItem(name: "ТЕЛ", score: monster.abilities.con.score, modifier: monster.abilities.con.modifierString)
                            AbilityItem(name: "ИНТ", score: monster.abilities.int.score, modifier: monster.abilities.int.modifierString)
                            AbilityItem(name: "МДР", score: monster.abilities.wis.score, modifier: monster.abilities.wis.modifierString)
                            AbilityItem(name: "ХАР", score: monster.abilities.cha.score, modifier: monster.abilities.cha.modifierString)
                        }
                    }
                    
                    // Speed
                    if !monster.speed.displayString.isEmpty {
                        MonsterInfoRow(title: "Скорость", value: monster.speed.displayString, icon: "figure.walk", color: .green)
                    }
                    
                    // Skills
                    if !monster.skills.isEmpty {
                        MonsterInfoRow(title: "Навыки", value: monster.skills.map { "\($0.key) \($0.value)" }.joined(separator: ", "), icon: "brain.head.profile", color: .purple)
                    }
                    
                    // Actions
                    if let actions = monster.blocks.actions, !actions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Действия")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            ForEach(actions, id: \.name) { action in
                                ActionItem(action: action)
                            }
                        }
                    }
                    
                    // Legendary Actions
                    if let legendaryActions = monster.blocks.legendaryActions, !legendaryActions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Легендарные действия")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            ForEach(legendaryActions, id: \.name) { action in
                                ActionItem(action: action)
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
            
            // Expand/Collapse button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(isExpanded ? "Свернуть" : "Развернуть")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AbilityItem: View {
    let name: String
    let score: Int
    let modifier: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(name)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text("\(score)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(modifier)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MonsterInfoRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct ActionItem: View {
    let action: Action
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(action.name)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(action.text)
                .font(.caption2)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.leading, 8)
    }
}

// MARK: - Bestiary Tab View

struct BestiaryTabView: View {
    @ObservedObject var store: CompendiumStore
    @ObservedObject var favorites: Favorites
    @ObservedObject var themeManager: ThemeManager
    @State private var searchText = ""
    @State private var showingFilters = false
    
    private func getActiveMonsterFiltersCount() -> Int {
        return store.monsterFilters.selectedSizes.count + 
               store.monsterFilters.selectedTypes.count + 
               store.monsterFilters.selectedCRs.count +
               store.monsterFilters.selectedAlignments.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Поиск монстров...", text: $searchText)
                    .onChange(of: searchText) { 
                        store.updateMonsterSearchText(searchText)
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
                    ForEach(store.filteredMonsters) { monster in
                        MonsterCard(monster: monster, favorites: favorites)
                            .id("\(monster.id)-\(favorites.monsters.isFavorite(monster.name))")
                    }
                }
                .padding(.top)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingFilters = true }) {
                    ZStack {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.orange)
                        
                        if getActiveMonsterFiltersCount() > 0 {
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("\(getActiveMonsterFiltersCount())")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            MonsterFiltersView(store: store)
        }
    }
}

// MARK: - Monster Filters View

struct MonsterFiltersView: View {
    @ObservedObject var store: CompendiumStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.988, green: 0.933, blue: 0.855)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Размер
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Размер")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                                ForEach(store.monsterFilters.sizes, id: \.self) { size in
                                    FilterButton(
                                        title: size,
                                        isSelected: store.monsterFilters.selectedSizes.contains(size)
                                    ) {
                                        store.updateMonsterSizeFilter(size)
                                    }
                                }
                            }
                        }
                        
                        // Тип
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Тип")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                                ForEach(store.monsterFilters.types, id: \.self) { type in
                                    FilterButton(
                                        title: type,
                                        isSelected: store.monsterFilters.selectedTypes.contains(type)
                                    ) {
                                        store.updateMonsterTypeFilter(type)
                                    }
                                }
                            }
                        }
                        
                        // CR
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Класс опасности")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                                ForEach(store.monsterFilters.challengeRatings, id: \.self) { cr in
                                    FilterButton(
                                        title: cr,
                                        isSelected: store.monsterFilters.selectedCRs.contains(cr)
                                    ) {
                                        store.updateMonsterCRFilter(cr)
                                    }
                                }
                            }
                        }
                        
                        // Мировоззрение
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Мировоззрение")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                                ForEach(store.monsterFilters.alignments, id: \.self) { alignment in
                                    FilterButton(
                                        title: alignment,
                                        isSelected: store.monsterFilters.selectedAlignments.contains(alignment)
                                    ) {
                                        store.updateMonsterAlignmentFilter(alignment)
                                    }
                                }
                            }
                        }
                        
                        // Кнопка очистки
                        Button(action: {
                            store.clearMonsterFilters()
                        }) {
                            Text("Очистить все фильтры")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(12)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Фильтры монстров")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
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
    @State private var monstersCollapsed = false
    
    @State private var favoriteSpells: [Spell] = []
    @State private var favoriteFeats: [Feat] = []
    @State private var favoriteBackgrounds: [Background] = []
    @State private var favoriteMonsters: [Monster] = []
    
    @MainActor
    private func updateFavorites() {
        favoriteSpells = store.spells.filter { favorites.spells.isFavorite($0.name) }
        favoriteFeats = store.feats.filter { favorites.feats.isFavorite($0.name) }
        favoriteBackgrounds = store.backgrounds.filter { favorites.backgrounds.isFavorite($0.name) }
        favoriteMonsters = store.monsters.filter { favorites.monsters.isFavorite($0.name) }
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
                if favoriteSpells.isEmpty && favoriteFeats.isEmpty && favoriteBackgrounds.isEmpty && favoriteMonsters.isEmpty {
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
                                            FavoriteFeatCard(feat: feat, favorites: favorites)
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
                                            FavoriteBackgroundCard(background: background, favorites: favorites)
                                                .id("\(background.id)-\(favorites.backgrounds.isFavorite(background.name))")
                                        }
                                    }
                                }
                            }
                            
                            if !favoriteMonsters.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Button(action: { monstersCollapsed.toggle() }) {
                                        HStack {
                                            Text("Избранные монстры (\(favoriteMonsters.count))")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: monstersCollapsed ? "chevron.down" : "chevron.up")
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if !monstersCollapsed {
                                        ForEach(favoriteMonsters) { monster in
                                            FavoriteMonsterCard(monster: monster, favorites: favorites)
                                                .id("\(monster.id)-\(favorites.monsters.isFavorite(monster.name))")
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
        .onChange(of: favorites.monsters.favorites) {
            updateFavorites()
        }
    }
}

// MARK: - Favorite Cards (without expand arrow)

struct FavoriteSpellCard: View {
    let spell: Spell
    @ObservedObject var favorites: Favorites
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name only (no expand button)
            HStack {
                Text(spell.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        favorites.spells.toggle(spell.name)
                    }
                }) {
                    Image(systemName: favorites.spells.isFavorite(spell.name) ? "heart.fill" : "heart")
                        .foregroundColor(favorites.spells.isFavorite(spell.name) ? .red : .gray)
                        .font(.title2)
                        .scaleEffect(favorites.spells.isFavorite(spell.name) ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: favorites.spells.isFavorite(spell.name))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Level and School badges
            HStack(spacing: 8) {
                Text(spell.level == 0 ? "Заговор" : "\(spell.level) уровень")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.15))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                
                Text(getSchoolName(spell.school))
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.15))
                    .foregroundColor(.purple)
                    .cornerRadius(12)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Always show description (no expand/collapse)
            Text(spell.description)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    private func getSchoolName(_ school: String) -> String {
        switch school.lowercased() {
        case "evocation": return "Воплощение"
        case "abjuration": return "Ограждение"
        case "conjuration": return "Вызов"
        case "divination": return "Прорицание"
        case "enchantment": return "Очарование"
        case "illusion": return "Иллюзия"
        case "necromancy": return "Некромантия"
        case "transmutation": return "Преобразование"
        default: return school
        }
    }
}

struct FavoriteFeatCard: View {
    let feat: Feat
    @ObservedObject var favorites: Favorites
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name only (no expand button)
            HStack {
                Text(feat.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        favorites.feats.toggle(feat.name)
                    }
                }) {
                    Image(systemName: favorites.feats.isFavorite(feat.name) ? "heart.fill" : "heart")
                        .foregroundColor(favorites.feats.isFavorite(feat.name) ? .red : .gray)
                        .font(.title2)
                        .scaleEffect(favorites.feats.isFavorite(feat.name) ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: favorites.feats.isFavorite(feat.name))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Category badge
            if !feat.category.isEmpty {
                HStack(spacing: 8) {
                    Text(feat.category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(12)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            
            // Always show description (no expand/collapse)
            Text(feat.description)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

struct FavoriteBackgroundCard: View {
    let background: Background
    @ObservedObject var favorites: Favorites
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name only (no expand button)
            HStack {
                Text(background.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
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
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Always show description (no expand/collapse)
            Text(background.description)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

struct FavoriteMonsterCard: View {
    let monster: Monster
    @ObservedObject var favorites: Favorites
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name only (no expand button)
            HStack {
                Text(monster.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        favorites.monsters.toggle(monster.name)
                    }
                }) {
                    Image(systemName: favorites.monsters.isFavorite(monster.name) ? "heart.fill" : "heart")
                        .foregroundColor(favorites.monsters.isFavorite(monster.name) ? .red : .gray)
                        .font(.title2)
                        .scaleEffect(favorites.monsters.isFavorite(monster.name) ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: favorites.monsters.isFavorite(monster.name))
                }
            }
            
            // Basic stats
            HStack(spacing: 16) {
                StatItem(title: "КД", value: "\(monster.ac.ac)", icon: "shield.fill", color: .blue)
                StatItem(title: "ХП", value: "\(monster.hp.hp)", icon: "heart.fill", color: .red)
                StatItem(title: "CR", value: monster.challenge.cr, icon: "star.fill", color: .orange)
            }
            
            // Always show description (no expand/collapse)
            if !monster.subtitle.isEmpty {
                Text(monster.subtitle)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 16)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
