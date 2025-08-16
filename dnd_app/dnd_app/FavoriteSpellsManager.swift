//
//  FavoriteSpellsManager.swift
//  tabaxi
//
//  Created by Alexander Aferenok on 08.08.2025.
//

import Foundation

@MainActor
final class FavoriteSpellsManager: ObservableObject {
    @Published private(set) var favoriteSpells: Set<String> = []
    @Published private(set) var favoriteFeats: Set<String> = []
    @Published private(set) var favoriteBackgrounds: Set<String> = []
    
    private let spellsStorageKey = "favoriteSpells"
    private let featsStorageKey = "favoriteFeats"
    private let backgroundsStorageKey = "favoriteBackgrounds"
    private let cacheManager = CacheManager.shared
    
    init() {
        load()
    }
    
    // MARK: - Spell Management
    func toggleSpell(_ spellName: String) {
        if favoriteSpells.contains(spellName) {
            favoriteSpells.remove(spellName)
        } else {
            favoriteSpells.insert(spellName)
        }
        saveSpells()
    }
    
    func isSpellFavorite(_ spellName: String) -> Bool {
        return favoriteSpells.contains(spellName)
    }
    
    func addMultipleSpells(_ spells: [Spell]) {
        for spell in spells {
            favoriteSpells.insert(spell.name)
        }
        saveSpells()
    }
    
    func removeMultipleSpells(_ spells: [Spell]) {
        for spell in spells {
            favoriteSpells.remove(spell.name)
        }
        saveSpells()
    }
    
    func getFavoriteSpells(from allSpells: [Spell]) -> [Spell] {
        return allSpells.filter { spell in
            favoriteSpells.contains(spell.name)
        }
    }
    
    func clearFavoriteSpells() {
        favoriteSpells.removeAll()
        saveSpells()
    }
    
    func areAllSpellsFavorite(_ spells: [Spell]) -> Bool {
        guard !spells.isEmpty else { return false }
        return spells.allSatisfy { favoriteSpells.contains($0.name) }
    }
    
    func toggleMultipleSpells(_ spells: [Spell]) {
        if areAllSpellsFavorite(spells) {
            removeMultipleSpells(spells)
        } else {
            addMultipleSpells(spells)
        }
    }
    
    // MARK: - Feat Management
    func toggleFeat(_ featName: String) {
        if favoriteFeats.contains(featName) {
            favoriteFeats.remove(featName)
        } else {
            favoriteFeats.insert(featName)
        }
        saveFeats()
    }
    
    func isFeatFavorite(_ featName: String) -> Bool {
        return favoriteFeats.contains(featName)
    }
    
    func addMultipleFeats(_ feats: [Feat]) {
        for feat in feats {
            favoriteFeats.insert(feat.name)
        }
        saveFeats()
    }
    
    func removeMultipleFeats(_ feats: [Feat]) {
        for feat in feats {
            favoriteFeats.remove(feat.name)
        }
        saveFeats()
    }
    
    func getFavoriteFeats(from allFeats: [Feat]) -> [Feat] {
        return allFeats.filter { feat in
            favoriteFeats.contains(feat.name)
        }
    }
    
    func clearFavoriteFeats() {
        favoriteFeats.removeAll()
        saveFeats()
    }
    
    func areAllFeatsFavorite(_ feats: [Feat]) -> Bool {
        guard !feats.isEmpty else { return false }
        return feats.allSatisfy { favoriteFeats.contains($0.name) }
    }
    
    func toggleMultipleFeats(_ feats: [Feat]) {
        if areAllFeatsFavorite(feats) {
            removeMultipleFeats(feats)
        } else {
            addMultipleFeats(feats)
        }
    }
    
    // MARK: - Background Management
    func toggleBackground(_ backgroundName: String) {
        if favoriteBackgrounds.contains(backgroundName) {
            favoriteBackgrounds.remove(backgroundName)
        } else {
            favoriteBackgrounds.insert(backgroundName)
        }
        saveBackgrounds()
    }
    
    func isBackgroundFavorite(_ backgroundName: String) -> Bool {
        return favoriteBackgrounds.contains(backgroundName)
    }
    
    func addMultipleBackgrounds(_ backgrounds: [Background]) {
        for background in backgrounds {
            favoriteBackgrounds.insert(background.name)
        }
        saveBackgrounds()
    }
    
    func removeMultipleBackgrounds(_ backgrounds: [Background]) {
        for background in backgrounds {
            favoriteBackgrounds.remove(background.name)
        }
        saveBackgrounds()
    }
    
    func getFavoriteBackgrounds(from allBackgrounds: [Background]) -> [Background] {
        return allBackgrounds.filter { background in
            favoriteBackgrounds.contains(background.name)
        }
    }
    
    func clearFavoriteBackgrounds() {
        favoriteBackgrounds.removeAll()
        saveBackgrounds()
    }
    
    func areAllBackgroundsFavorite(_ backgrounds: [Background]) -> Bool {
        guard !backgrounds.isEmpty else { return false }
        return backgrounds.allSatisfy { favoriteBackgrounds.contains($0.name) }
    }
    
    func toggleMultipleBackgrounds(_ backgrounds: [Background]) {
        if areAllBackgroundsFavorite(backgrounds) {
            removeMultipleBackgrounds(backgrounds)
        } else {
            addMultipleBackgrounds(backgrounds)
        }
    }
    
    // MARK: - Persistence
    private func saveSpells() {
        UserDefaults.standard.set(Array(favoriteSpells), forKey: spellsStorageKey)
        // Кэшируем избранные заклинания
        cacheManager.cacheFavorites(Array(favoriteSpells))
    }
    
    private func saveFeats() {
        UserDefaults.standard.set(Array(favoriteFeats), forKey: featsStorageKey)
        // Кэшируем избранные умения
        cacheManager.cacheFavorites(Array(favoriteFeats))
    }
    
    private func saveBackgrounds() {
        UserDefaults.standard.set(Array(favoriteBackgrounds), forKey: backgroundsStorageKey)
        // Кэшируем избранные предыстории
        cacheManager.cacheFavorites(Array(favoriteBackgrounds))
    }
    
    private func load() {
        // Сначала пытаемся загрузить из кэша
        if let cachedSpells = cacheManager.getCachedFavorites() {
            favoriteSpells = Set(cachedSpells)
            print("✅ [FAVORITES] Загружено \(cachedSpells.count) избранных заклинаний из кэша")
        } else {
            // Если кэша нет, загружаем из UserDefaults
            if let spellsArray = UserDefaults.standard.array(forKey: spellsStorageKey) as? [String] {
                favoriteSpells = Set(spellsArray)
                // Кэшируем избранные заклинания
                cacheManager.cacheFavorites(Array(favoriteSpells))
                print("✅ [FAVORITES] Загружено \(favoriteSpells.count) избранных заклинаний из UserDefaults и закэшировано")
            }
        }
        
        if let featsArray = UserDefaults.standard.array(forKey: featsStorageKey) as? [String] {
            favoriteFeats = Set(featsArray)
        }
        
        if let backgroundsArray = UserDefaults.standard.array(forKey: backgroundsStorageKey) as? [String] {
            favoriteBackgrounds = Set(backgroundsArray)
        }
    }
}
