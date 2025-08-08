//
//  SpellsView.swift
//  tabaxi
//
//  Created by Alexander Aferenok on 08.08.2025.
//

import SwiftUI

struct SpellsView: View {
    let store: SpellsStore
    let favorites: FavoriteSpellsManager
    let themeManager: ThemeManager

    var body: some View {
        ZStack {
            Color(hex: "#fceeda")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                SearchAndFilterSection(store: store, favorites: favorites, themeManager: themeManager, currentTab: 0)
                AllSpellsTab(store: store, favorites: favorites, themeManager: themeManager)
            }
        }
    }
}

// MARK: - Search and Filter Section
struct SearchAndFilterSection: View {
    @ObservedObject var store: SpellsStore
    let favorites: FavoriteSpellsManager
    let themeManager: ThemeManager
    let currentTab: Int
    @State private var showingFilters = false

    private func getActiveFiltersCount() -> Int {
        return store.spellFilters.selectedLevels.count + 
               store.spellFilters.selectedSchools.count + 
               store.spellFilters.selectedClasses.count +
               (store.spellFilters.concentrationOnly ? 1 : 0) +
               (store.spellFilters.ritualOnly ? 1 : 0)
    }

    var body: some View {
        Group {
            VStack(spacing: 12) {
                Button(action: { showingFilters = true }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Поиск заклинаний...")
                        Spacer()
                        if getActiveFiltersCount() > 0 {
                            Text("\(getActiveFiltersCount())")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .sheet(isPresented: $showingFilters) {
                SpellSearchView(store: store, favorites: favorites, themeManager: themeManager)
            }
        }
    }
}

// MARK: - Spell Search View
struct SpellSearchView: View {
    @ObservedObject var store: SpellsStore
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
                Color(hex: "#fceeda")
                .ignoresSafeArea()

                VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Поиск заклинаний и умений...", text: $searchText)
                        .onChange(of: searchText) { 
                            store.updateSpellSearchText(searchText)
                            store.updateFeatSearchText(searchText)
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)



                // Results
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if !store.filteredSpells.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Button(action: { spellsCollapsed.toggle() }) {
                                    HStack {
                                        Text("Заклинания (\(store.filteredSpells.count))")
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
                                    ForEach(store.filteredSpells) { spell in
                                        SpellCard(spell: spell, favorites: favorites)
                                            .id("\(spell.id)-\(favorites.isSpellFavorite(spell.name))")
                                    }
                                }
                            }
                        }
                        
                        if !store.filteredFeats.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Button(action: { featsCollapsed.toggle() }) {
                                    HStack {
                                        Text("Умения (\(store.filteredFeats.count))")
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
                                    ForEach(store.filteredFeats) { feat in
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
            .navigationTitle("🔮 Поиск заклинаний и умений")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !store.filteredSpells.isEmpty || !store.filteredFeats.isEmpty {
                            Button(action: {
                                if !store.filteredSpells.isEmpty {
                                    favorites.toggleMultipleSpells(store.filteredSpells)
                                }
                                if !store.filteredFeats.isEmpty {
                                    favorites.toggleMultipleFeats(store.filteredFeats)
                                }
                            }) {
                                let allSpellsFavorite = store.filteredSpells.isEmpty || favorites.areAllSpellsFavorite(store.filteredSpells)
                                let allFeatsFavorite = store.filteredFeats.isEmpty || favorites.areAllFeatsFavorite(store.filteredFeats)
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
            }
            .sheet(isPresented: $showingFilters) {
                AdvancedFiltersView(store: store)
            }
        }
    }
}

// MARK: - Advanced Filters View
struct AdvancedFiltersView: View {
    @ObservedObject var store: SpellsStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#fceeda")
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


// MARK: - All Spells Tab (Favorites)
struct AllSpellsTab: View {
    let store: SpellsStore
    let favorites: FavoriteSpellsManager
    let themeManager: ThemeManager

    @State private var spellsCollapsed = false
    @State private var featsCollapsed = false
    
    @State private var favoriteSpells: [Spell] = []
    @State private var favoriteFeats: [Feat] = []
    
    @MainActor
    private func updateFavorites() {
        favoriteSpells = favorites.getFavoriteSpells(from: store.spells)
        favoriteFeats = favorites.getFavoriteFeats(from: store.feats)
    }

    var body: some View {
        VStack(spacing: 0) {
            if favoriteSpells.isEmpty && favoriteFeats.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "heart.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Нет избранного")
                                .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Добавь заклинания и умения в избранное для быстрого доступа")
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
                                        SpellCard(spell: spell, favorites: favorites)
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

// MARK: - Spell Card
struct SpellCard: View {
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
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.15))
                    .foregroundColor(.purple)
                    .cornerRadius(12)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
            // Classes
            if !spell.classes.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    
                    Text(spell.classes.joined(separator: ", ").capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            
            // Expanded details
            if isExpanded {
                VStack(spacing: 12) {
                    // Casting info
                    VStack(spacing: 8) {
                        if let castingTime = spell.castingTime {
                            HStack(spacing: 8) {
                                Image(systemName: "clock")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                Text(castingTime)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        
                        if let range = spell.range {
                            HStack(spacing: 8) {
                                Image(systemName: "location")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                Text(range)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        
                        if let components = spell.components, !components.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "hand.raised.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text(getComponentsText(components))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        
                        if let duration = spell.duration {
                            HStack(spacing: 8) {
                                Image(systemName: "timer")
                                    .foregroundColor(.purple)
                                    .font(.caption)
                                Text(duration)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Description
                    Text(spell.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    // Material component if present
                    if let material = spell.material {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Материальный компонент:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            Text(material)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Cantrip upgrade if present
                    if let cantripUpgrade = spell.cantripUpgrade {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Улучшение заговора:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            Text(cantripUpgrade)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 16)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    private func getSchoolName(_ school: String) -> String {
        switch school.lowercased() {
        case "evocation": return "Воплощение"
        case "necromancy": return "Некромантия"
        case "illusion": return "Иллюзия"
        case "transmutation": return "Преобразование"
        case "conjuration": return "Вызов"
        case "enchantment": return "Очарование"
        case "abjuration": return "Ограждение"
        case "divination": return "Прорицание"
        default: return school.capitalized
        }
    }
    
    private func getComponentsText(_ components: [String]) -> String {
        var result: [String] = []
        if components.contains("v") { result.append("Вербальный") }
        if components.contains("s") { result.append("Соматический") }
        if components.contains("m") { result.append("Материальный") }
        return result.joined(separator: ", ")
    }
}

// MARK: - Feat Card
struct FeatCard: View {
    let feat: Feat
    @ObservedObject var favorites: FavoriteSpellsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(feat.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(feat.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        favorites.toggleFeat(feat.name)
                    }
                }) {
                    Image(systemName: favorites.isFeatFavorite(feat.name) ? "heart.fill" : "heart")
                        .foregroundColor(favorites.isFeatFavorite(feat.name) ? .red : .gray)
                        .font(.title2)
                        .scaleEffect(favorites.isFeatFavorite(feat.name) ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: favorites.isFeatFavorite(feat.name))
                }
            }
            
            Text(feat.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
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
                .padding(.vertical, 6)
                .background(isSelected ? Color.orange : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}
