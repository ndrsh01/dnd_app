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
    
    private let spellsStorageKey = "favoriteSpells"
    private let featsStorageKey = "favoriteFeats"
    
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
    
    // MARK: - Persistence
    private func saveSpells() {
        UserDefaults.standard.set(Array(favoriteSpells), forKey: spellsStorageKey)
    }
    
    private func saveFeats() {
        UserDefaults.standard.set(Array(favoriteFeats), forKey: featsStorageKey)
    }
    
    private func load() {
        if let spellsArray = UserDefaults.standard.array(forKey: spellsStorageKey) as? [String] {
            favoriteSpells = Set(spellsArray)
        }
        
        if let featsArray = UserDefaults.standard.array(forKey: featsStorageKey) as? [String] {
            favoriteFeats = Set(featsArray)
        }
    }
}
