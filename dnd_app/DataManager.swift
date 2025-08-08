import Foundation
import SwiftUI

class DataManager: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var characters: [Character] = []
    @Published var spells: [Spell] = []
    
    private let quotesKey = "quotes"
    private let charactersKey = "characters"
    private let spellsKey = "spells"
    
    init() {
        loadQuotes()
        loadCharacters()
        loadSpells()
    }
    
    // MARK: - Quotes Management
    func loadQuotes() {
        if let url = Bundle.main.url(forResource: "quotes", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let quotesData = try decoder.decode(QuotesData.self, from: data)
                
                self.quotes = quotesData.quotes.map { quoteData in
                    Quote(
                        text: quoteData.text,
                        author: quoteData.author,
                        category: QuoteCategory(rawValue: quoteData.category) ?? .wisdom
                    )
                }
            } catch {
                print("Error loading quotes: \(error)")
                loadDefaultQuotes()
            }
        } else {
            loadDefaultQuotes()
        }
    }
    
    private func loadDefaultQuotes() {
        quotes = [
            Quote(text: "Приключения ждут тех, кто готов их искать.", author: "Древняя мудрость", category: .adventure),
            Quote(text: "В битве важна не сила оружия, а сила духа.", author: "Ветеран войны", category: .battle),
            Quote(text: "Магия - это искусство невозможного.", author: "Архимаг", category: .magic)
        ]
    }
    
    func getRandomQuote(for category: QuoteCategory? = nil) -> Quote? {
        let filteredQuotes = category != nil ? quotes.filter { $0.category == category } : quotes
        return filteredQuotes.randomElement()
    }
    
    func addQuote(_ quote: Quote) {
        quotes.append(quote)
        saveQuotes()
    }
    
    func removeQuote(_ quote: Quote) {
        quotes.removeAll { $0.id == quote.id }
        saveQuotes()
    }
    
    func toggleFavorite(_ quote: Quote) {
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index].isFavorite.toggle()
            saveQuotes()
        }
    }
    
    private func saveQuotes() {
        if let encoded = try? JSONEncoder().encode(quotes) {
            UserDefaults.standard.set(encoded, forKey: quotesKey)
        }
    }
    
    // MARK: - Characters Management
    func loadCharacters() {
        if let data = UserDefaults.standard.data(forKey: charactersKey),
           let decoded = try? JSONDecoder().decode([Character].self, from: data) {
            characters = decoded
        }
    }
    
    func addCharacter(_ character: Character) {
        characters.append(character)
        saveCharacters()
    }
    
    func updateCharacter(_ character: Character) {
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            characters[index] = character
            saveCharacters()
        }
    }
    
    func removeCharacter(_ character: Character) {
        characters.removeAll { $0.id == character.id }
        saveCharacters()
    }
    
    func addRelationship(to character: Character, relationship: Relationship) {
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            characters[index].relationships.append(relationship)
            saveCharacters()
        }
    }
    
    func removeRelationship(from character: Character, relationship: Relationship) {
        if let charIndex = characters.firstIndex(where: { $0.id == character.id }) {
            characters[charIndex].relationships.removeAll { $0.id == relationship.id }
            saveCharacters()
        }
    }
    
    private func saveCharacters() {
        if let encoded = try? JSONEncoder().encode(characters) {
            UserDefaults.standard.set(encoded, forKey: charactersKey)
        }
    }
    
    // MARK: - Spells Management
    func loadSpells() {
        if let data = UserDefaults.standard.data(forKey: spellsKey),
           let decoded = try? JSONDecoder().decode([Spell].self, from: data) {
            spells = decoded
        } else {
            loadDefaultSpells()
        }
    }
    
    private func loadDefaultSpells() {
        spells = [
            Spell(name: "Огненный шар", level: 3, school: "Воплощение", castingTime: "1 действие", range: "150 футов", components: ["В", "С", "М"], duration: "Мгновенно", description: "Создает взрывающийся огненный шар"),
            Spell(name: "Лечение ран", level: 1, school: "Воплощение", castingTime: "1 действие", range: "Касание", components: ["В", "С"], duration: "Мгновенно", description: "Восстанавливает хиты цели"),
            Spell(name: "Магический щит", level: 1, school: "Прорицание", castingTime: "1 реакция", range: "На себя", components: ["В", "С"], duration: "1 раунд", description: "Добавляет бонус к КД")
        ]
    }
    
    func addSpell(_ spell: Spell) {
        spells.append(spell)
        saveSpells()
    }
    
    func removeSpell(_ spell: Spell) {
        spells.removeAll { $0.id == spell.id }
        saveSpells()
    }
    
    func toggleSpellPrepared(_ spell: Spell) {
        if let index = spells.firstIndex(where: { $0.id == spell.id }) {
            spells[index].isPrepared.toggle()
            saveSpells()
        }
    }
    
    private func saveSpells() {
        if let encoded = try? JSONEncoder().encode(spells) {
            UserDefaults.standard.set(encoded, forKey: spellsKey)
        }
    }
}

// MARK: - JSON Decoding Structures
struct QuotesData: Codable {
    let quotes: [QuoteData]
}

struct QuoteData: Codable {
    let text: String
    let author: String
    let category: String
}
