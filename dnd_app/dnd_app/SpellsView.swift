//
//  SpellsView.swift
//  tabaxi
//
//  Created by Alexander Aferenok on 08.08.2025.
//

import SwiftUI

struct SpellsView: View {
    let store: CompendiumStore
    let favorites: FavoriteSpellsManager
    let themeManager: ThemeManager

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#fceeda"),
                    Color(hex: "#fceeda").opacity(0.9),
                    Color(hex: "#fceeda")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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
    @ObservedObject var store: CompendiumStore
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
                SpellSearchView(store: store, favorites: favorites, themeManager: themeManager)
            }
        }
    }
}

// MARK: - Spell Search View
struct SpellSearchView: View {
    @ObservedObject var store: CompendiumStore
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
                LinearGradient(
                    colors: [
                        Color(hex: "#fceeda"),
                        Color(hex: "#fceeda").opacity(0.9),
                        Color(hex: "#fceeda")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
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
    @ObservedObject var store: CompendiumStore
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
    let store: CompendiumStore
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



