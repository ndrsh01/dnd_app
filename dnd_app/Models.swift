import Foundation
import SwiftUI

// MARK: - Character Model
struct Character: Identifiable, Codable {
    let id = UUID()
    var name: String
    var race: String
    var class: String
    var level: Int
    var description: String
    var imageName: String?
    var relationships: [Relationship]
    var notes: String
    
    init(name: String, race: String, class: String, level: Int = 1, description: String = "", imageName: String? = nil, notes: String = "") {
        self.name = name
        self.race = race
        self.class = class
        self.level = level
        self.description = description
        self.imageName = imageName
        self.relationships = []
        self.notes = notes
    }
}

// MARK: - Relationship Model
struct Relationship: Identifiable, Codable {
    let id = UUID()
    var characterName: String
    var relationshipType: RelationshipType
    var strength: Int // 1-5 hearts
    var description: String
    
    init(characterName: String, relationshipType: RelationshipType, strength: Int = 3, description: String = "") {
        self.characterName = characterName
        self.relationshipType = relationshipType
        self.strength = max(1, min(5, strength))
        self.description = description
    }
}

enum RelationshipType: String, CaseIterable, Codable {
    case friend = "Друг"
    case family = "Семья"
    case lover = "Любовь"
    case enemy = "Враг"
    case mentor = "Наставник"
    case student = "Ученик"
    case ally = "Союзник"
    case rival = "Соперник"
    
    var color: Color {
        switch self {
        case .friend: return .blue
        case .family: return .green
        case .lover: return .pink
        case .enemy: return .red
        case .mentor: return .orange
        case .student: return .purple
        case .ally: return .cyan
        case .rival: return .yellow
        }
    }
}

// MARK: - Quote Model
struct Quote: Identifiable, Codable {
    let id = UUID()
    var text: String
    var author: String
    var category: QuoteCategory
    var isFavorite: Bool
    
    init(text: String, author: String, category: QuoteCategory, isFavorite: Bool = false) {
        self.text = text
        self.author = author
        self.category = category
        self.isFavorite = isFavorite
    }
}

enum QuoteCategory: String, CaseIterable, Codable {
    case wisdom = "Мудрость"
    case battle = "Битва"
    case magic = "Магия"
    case adventure = "Приключения"
    case friendship = "Дружба"
    case love = "Любовь"
    case motivation = "Мотивация"
    case humor = "Юмор"
    
    var icon: String {
        switch self {
        case .wisdom: return "brain.head.profile"
        case .battle: return "sword"
        case .magic: return "sparkles"
        case .adventure: return "map"
        case .friendship: return "person.2"
        case .love: return "heart"
        case .motivation: return "flame"
        case .humor: return "face.smiling"
        }
    }
    
    var color: Color {
        switch self {
        case .wisdom: return .blue
        case .battle: return .red
        case .magic: return .purple
        case .adventure: return .orange
        case .friendship: return .green
        case .love: return .pink
        case .motivation: return .yellow
        case .humor: return .cyan
        }
    }
}

// MARK: - Dice Model
struct Dice: Identifiable {
    let id = UUID()
    var sides: Int
    var count: Int
    var modifier: Int
    
    init(sides: Int = 20, count: Int = 1, modifier: Int = 0) {
        self.sides = sides
        self.count = count
        self.modifier = modifier
    }
    
    func roll() -> Int {
        let rolls = (0..<count).map { _ in Int.random(in: 1...sides) }
        return rolls.reduce(0, +) + modifier
    }
}

// MARK: - Spell Model
struct Spell: Identifiable, Codable {
    let id = UUID()
    var name: String
    var level: Int
    var school: String
    var castingTime: String
    var range: String
    var components: [String]
    var duration: String
    var description: String
    var isPrepared: Bool
    
    init(name: String, level: Int, school: String, castingTime: String, range: String, components: [String], duration: String, description: String, isPrepared: Bool = false) {
        self.name = name
        self.level = level
        self.school = school
        self.castingTime = castingTime
        self.range = range
        self.components = components
        self.duration = duration
        self.description = description
        self.isPrepared = isPrepared
    }
}
