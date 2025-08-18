import SwiftUI

// MARK: - Spells View
struct SpellsView: View {
    @StateObject private var spellStore = SpellStore()
    @StateObject private var featStore = FeatStore()
    @StateObject private var backgroundStore = BackgroundStore()
    @StateObject private var favorites = FavoriteSpellsManager()
    @StateObject private var themeManager = ThemeManager()

    var body: some View {
        ZStack {
            ThemeManager.adaptiveBackground(for: themeManager.preferredColorScheme)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                SearchAndFilterSection(spellStore: spellStore, featStore: featStore, favorites: favorites, themeManager: themeManager, currentTab: 0)
                AllSpellsTab(spellStore: spellStore, featStore: featStore, backgroundStore: backgroundStore, favorites: favorites, themeManager: themeManager)
            }
        }
    }
}

// MARK: - Search and Filter Section
struct SearchAndFilterSection: View {
    @ObservedObject var spellStore: SpellStore
    @ObservedObject var featStore: FeatStore
    let favorites: FavoriteSpellsManager
    let themeManager: ThemeManager
    let currentTab: Int
    @State private var showingFilters = false

    private func getActiveFiltersCount() -> Int {
        return spellStore.spellFilters.selectedLevels.count +
               spellStore.spellFilters.selectedSchools.count +
               spellStore.spellFilters.selectedClasses.count +
               (spellStore.spellFilters.concentrationOnly ? 1 : 0) +
               (spellStore.spellFilters.ritualOnly ? 1 : 0)
    }

    var body: some View {
        Group {
            VStack(spacing: 12) {
                Button(action: { showingFilters = true }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        Text("Поиск заклинаний...")
                            .foregroundColor(.secondary)
                        Spacer()
                        if getActiveFiltersCount() > 0 {
                            Text("\(getActiveFiltersCount())")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding()
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
                .padding(.horizontal)
                .padding(.top)
            }
            .sheet(isPresented: $showingFilters) {
                SpellSearchView(spellStore: spellStore, featStore: featStore, favorites: favorites, themeManager: themeManager)
            }
        }
    }
}

// MARK: - Spell Search View
struct SpellSearchView: View {
    @ObservedObject var spellStore: SpellStore
    @ObservedObject var featStore: FeatStore
    let favorites: FavoriteSpellsManager
    let themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var showingCustomSpellSheet = false
    @State private var spellsCollapsed = false
    @State private var featsCollapsed = false

    var body: some View {
        NavigationStack {
            ZStack {
                ThemeManager.adaptiveBackground(for: themeManager.preferredColorScheme)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Поиск заклинаний и умений...", text: $searchText)
                        .onChange(of: searchText) { 
                            spellStore.updateSpellSearchText(searchText)
                            featStore.updateFeatSearchText(searchText)
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                // Results
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if !spellStore.filteredSpells.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Button(action: { spellsCollapsed.toggle() }) {
                                    HStack {
                                        Text("Заклинания (\(spellStore.filteredSpells.count))")
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
                                        ForEach(spellStore.filteredSpells) { spell in
                                            CompendiumSpellCard(spell: spell, favorites: favorites)
                                                .id("\(spell.id)-\(favorites.isSpellFavorite(spell.name))")
                                    }
                                }
                            }
                        }

                        if !featStore.filteredFeats.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Button(action: { featsCollapsed.toggle() }) {
                                    HStack {
                                        Text("Умения (\(featStore.filteredFeats.count))")
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
                                        ForEach(featStore.filteredFeats) { feat in
                                            FeatCard(feat: feat, favorites: favorites)
                                                .id("\(feat.id)-\(favorites.isFeatFavorite(feat.name))")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top)
                    }
                }
            }
            .navigationTitle("Поиск заклинаний и умений")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !spellStore.filteredSpells.isEmpty || !featStore.filteredFeats.isEmpty {
                            Button(action: {
                                if !spellStore.filteredSpells.isEmpty {
                                    favorites.toggleMultipleSpells(spellStore.filteredSpells)
                                }
                                if !featStore.filteredFeats.isEmpty {
                                    favorites.toggleMultipleFeats(featStore.filteredFeats)
                                }
                            }) {
                                let allSpellsFavorite = spellStore.filteredSpells.isEmpty || favorites.areAllSpellsFavorite(spellStore.filteredSpells)
                                let allFeatsFavorite = featStore.filteredFeats.isEmpty || favorites.areAllFeatsFavorite(featStore.filteredFeats)
                                let allFavorite = allSpellsFavorite && allFeatsFavorite
                                
                                Image(systemName: allFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Button(action: { showingFilters = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.orange)
                        }
                        
                        Button(action: { showingCustomSpellSheet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.orange)
                    }
                }
                }
            }
            .sheet(isPresented: $showingFilters) {
                AdvancedFiltersView(store: spellStore)
            }
        }
    }
}

// MARK: - Advanced Filters View
struct AdvancedFiltersView: View {
    @ObservedObject var store: SpellStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Уровень заклинания
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Уровень заклинания")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
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
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
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
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
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
            .navigationTitle("Фильтры")
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

// MARK: - All Spells Tab (Favorites)
struct AllSpellsTab: View {
    let spellStore: SpellStore
    let featStore: FeatStore
    let backgroundStore: BackgroundStore
    let favorites: FavoriteSpellsManager
    let themeManager: ThemeManager

    @State private var spellsCollapsed = false
    @State private var featsCollapsed = false
    
    @State private var favoriteSpells: [Spell] = []
    @State private var favoriteFeats: [Feat] = []
    @State private var favoriteBackgrounds: [Background] = []
    
    @MainActor
    private func updateFavorites() {
        favoriteSpells = favorites.getFavoriteSpells(from: spellStore.spells)
        favoriteFeats = favorites.getFavoriteFeats(from: featStore.feats)
        favoriteBackgrounds = favorites.getFavoriteBackgrounds(from: backgroundStore.backgrounds)
    }

    var body: some View {
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
                    
                    Text("Добавь заклинания, умения и предыстории в избранное для быстрого доступа")
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
                                            .id("\(spell.id)-\(favorites.isSpellFavorite(spell.name))")
                                    }
                                }
                            }
                        }
                        
                        if !favoriteFeats.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Button(action: { featsCollapsed.toggle() }) {
                        HStack {
                                        Text("Избранные умения (\(favoriteFeats.count))")
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
                                            .id("\(feat.id)-\(favorites.isFeatFavorite(feat.name))")
                                    }
                                }
                            }
                        }
                        
                        if !favoriteBackgrounds.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Button(action: { 
                                    // Добавим состояние для предысторий позже
                                }) {
                                    HStack {
                                        Text("Избранные предыстории (\(favoriteBackgrounds.count))")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.up")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                ForEach(favoriteBackgrounds) { background in
                                    BackgroundCard(background: background, favorites: favorites)
                                        .id("\(background.id)-\(favorites.isBackgroundFavorite(background.name))")
                                }
                            }
                        }
                    }
                    .padding(.top)
                }
            }
        }
            .onAppear {
            DispatchQueue.main.async {
                updateFavorites()
            }
        }
        .onChange(of: favorites.favoriteSpells) {
            DispatchQueue.main.async {
                updateFavorites()
            }
        }
        .onChange(of: favorites.favoriteFeats) {
            DispatchQueue.main.async {
                updateFavorites()
            }
        }
        .onReceive(favorites.objectWillChange) { _ in
            DispatchQueue.main.async {
                updateFavorites()
            }
        }
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.orange : Color(.systemGray5))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Feat Card
struct FeatCard: View {
    let feat: Feat
    @ObservedObject var favorites: FavoriteSpellsManager
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with name and expand button
            HStack {
                Text(feat.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            if favorites.isFeatFavorite(feat) {
                                favorites.removeFeatFromFavorites(feat)
                            } else {
                                favorites.addFeatToFavorites(feat)
                            }
                        }
                    }) {
                        Image(systemName: favorites.isFeatFavorite(feat) ? "heart.fill" : "heart")
                            .foregroundColor(favorites.isFeatFavorite(feat) ? .red : .gray)
                            .font(.title2)
                            .scaleEffect(favorites.isFeatFavorite(feat) ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: favorites.isFeatFavorite(feat))
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
            
            // Requirements
            if !feat.requirements.isEmpty {
                HStack(spacing: 4) {
                    Text("Требования:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(feat.requirements)
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            
            // Description (expandable)
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Text(feat.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 20)
    }
}

// MARK: - Compendium Spell Card
struct CompendiumSpellCard: View {
    let spell: Spell
    @ObservedObject var favorites: FavoriteSpellsManager
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with name and expand button
            HStack {
                Text(spell.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            favorites.toggleSpell(spell.name)
                        }
                    }) {
                        Image(systemName: favorites.isSpellFavorite(spell.name) ? "heart.fill" : "heart")
                            .foregroundColor(favorites.isSpellFavorite(spell.name) ? .red : .gray)
                            .font(.title2)
                            .scaleEffect(favorites.isSpellFavorite(spell.name) ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: favorites.isSpellFavorite(spell.name))
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
                
                // Concentration badge
                if spell.concentration {
                    Text("Концентрация")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.15))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }
                
                // Ritual badge
                if spell.ritual {
                    Text("Ритуал")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
            // Classes (always visible)
            if !spell.classes.isEmpty {
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(spell.classes.map { getClassName($0) }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            
            // Description (expandable)
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Casting time, range, components, duration
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text(spell.castingTime)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text(spell.range)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text(spell.components)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.purple)
                                .font(.caption)
                            Text(spell.duration)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // Description
                    Text(spell.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 20)
    }
    
    private func getSchoolName(_ school: String) -> String {
        let schoolNames = [
            "evocation": "Воплощение",
            "conjuration": "Вызов",
            "illusion": "Иллюзия",
            "necromancy": "Некромантия",
            "abjuration": "Ограждение",
            "enchantment": "Очарование",
            "transmutation": "Преобразование",
            "divination": "Прорицание"
        ]
        return schoolNames[school] ?? school
    }
    
    private func getClassName(_ className: String) -> String {
        let classNames = [
            "bard": "Бард",
            "sorcerer": "Волшебник",
            "druid": "Друид",
            "cleric": "Жрец",
            "warlock": "Колдун",
            "paladin": "Паладин",
            "ranger": "Следопыт",
            "wizard": "Чародей"
        ]
        return classNames[className] ?? className
    }
}




