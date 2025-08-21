import SwiftUI
import Combine

// MARK: - Character Class Models

struct CharacterClass: Codable, Identifiable {
    let id = UUID()
    let slug: String
    let name: String
    var level: Int
    var subclass: String?
    
    enum CodingKeys: String, CodingKey {
        case slug, name, level, subclass
    }
}

// MARK: - JSON Import Models

struct ImportedCharacter: Codable {
    let data: String
    let jsonType: String
    let version: String
}

struct CharacterData: Codable {
    let name: NameValue
    let info: CharacterInfo
    let stats: CharacterStats
    let saves: CharacterSaves
    let skills: CharacterSkills
    let vitality: CharacterVitality
    let weaponsList: [WeaponItem]
    let text: CharacterText
    let prof: ProficiencyValue?
    let proficiency: Int
}

struct NameValue: Codable {
    let value: String
}

struct LevelValue: Codable {
    let value: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = String(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else {
            value = "1"
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

struct CharacterInfo: Codable {
    let charClass: NameValue
    let level: LevelValue
    let background: NameValue
    let playerName: NameValue
    let race: NameValue
    let alignment: NameValue
    let experience: LevelValue
}

struct CharacterStats: Codable {
    let str: StatValue
    let dex: StatValue
    let con: StatValue
    let int: StatValue
    let wis: StatValue
    let cha: StatValue
}

struct StatValue: Codable {
    let score: Int
    let modifier: Int?
    let label: String
}

struct CharacterSaves: Codable {
    let str: SaveValue
    let dex: SaveValue
    let con: SaveValue
    let int: SaveValue
    let wis: SaveValue
    let cha: SaveValue
}

struct SaveValue: Codable {
    let isProf: Bool
}

struct CharacterSkills: Codable {
    let acrobatics: SkillValue?
    let investigation: SkillValue?
    let athletics: SkillValue?
    let perception: SkillValue?
    let survival: SkillValue?
    let performance: SkillValue?
    let intimidation: SkillValue?
    let history: SkillValue?
    let sleightOfHand: SkillValue?
    let arcana: SkillValue?
    let medicine: SkillValue?
    let deception: SkillValue?
    let nature: SkillValue?
    let insight: SkillValue?
    let religion: SkillValue?
    let stealth: SkillValue?
    let persuasion: SkillValue?
    let animalHandling: SkillValue?
    
    enum CodingKeys: String, CodingKey {
        case acrobatics, investigation, athletics, perception, survival, performance, intimidation, history
        case sleightOfHand = "sleight of hand"
        case arcana, medicine, deception, nature, insight, religion, stealth, persuasion
        case animalHandling = "animal handling"
    }
}

struct SkillValue: Codable {
    let baseStat: String
    let name: String
    let isProf: Int?
}

struct CharacterVitality: Codable {
    let hpMax: LevelValue
    let ac: LevelValue
    let speed: LevelValue
    let isDying: Bool?
    
    enum CodingKeys: String, CodingKey {
        case hpMax = "hp-max"
        case ac, speed, isDying
    }
}

struct WeaponItem: Codable {
    let name: NameValue
    let mod: NameValue
    let dmg: NameValue
    let isProf: Bool
}

struct CharacterText: Codable {
    let background: TextValue?
    let flaws: TextValue?
    let bonds: TextValue?
    let ideals: TextValue?
    let personality: TextValue?
    let attacks: TextValue?
    let traits: TextValue?
}

struct TextValue: Codable {
    let value: TextContent
    
    func extractText() -> String {
        return value.data.extractText()
    }
}

struct TextContent: Codable {
    let data: TextData
}

struct TextData: Codable {
    let content: [TextBlock]
}

struct TextBlock: Codable {
    let type: String
    let content: [TextElement]?
    let text: String?
    let marks: [TextMark]?
}

struct TextElement: Codable {
    let type: String
    let text: String?
    let marks: [TextMark]?
}

struct TextMark: Codable {
    let type: String
}

struct ProficiencyValue: Codable {
    let value: TextValue
}

// MARK: - Text Parsing Extension

extension TextData {
    func extractText() -> String {
        var result = ""
        
        for block in content {
            if let text = block.text {
                result += text
            } else if let contentElements = block.content {
                for element in contentElements {
                    if let text = element.text {
                        result += text
                    }
                }
            }
            result += "\n"
        }
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Character Models

struct Character: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String = ""
    var playerName: String = ""
    var race: String = ""
    var characterClasses: [CharacterClass] = []
    var characterClass: String = "" // For backward compatibility
    var subclass: String = "" // Current subclass for the main class
    var background: String = ""
    var alignment: String = ""
    var experience: Int = 0
    var level: Int = 1
    
    // Combat Stats
    var armorClass: Int = 10
    var initiative: Int = 0
    var speed: Int = 30
    var maxHitPoints: Int = 0
    var currentHitPoints: Int = 0
    var temporaryHitPoints: Int = 0
    var hitDiceTotal: Int = 0
    var hitDiceType: String = "d6"
    var proficiencyBonus: Int = 2
    var inspiration: Bool = false
    
    // Death Saves
    var deathSaveSuccesses: Int = 0
    var deathSaveFailures: Int = 0
    
    // Exhaustion
    var exhaustionLevel: Int = 0
    
    // Ability Scores
    var strength: Int = 10
    var dexterity: Int = 10
    var constitution: Int = 10
    var intelligence: Int = 10
    var wisdom: Int = 10
    var charisma: Int = 10
    
    // Saving Throws
    var savingThrows: [String: Bool] = [
        "strength": false,
        "dexterity": false,
        "constitution": false,
        "intelligence": false,
        "wisdom": false,
        "charisma": false
    ]
    
    // Skills
    var skills: [String: Bool] = [
        "acrobatics": false,
        "animal_handling": false,
        "arcana": false,
        "athletics": false,
        "deception": false,
        "history": false,
        "insight": false,
        "intimidation": false,
        "investigation": false,
        "medicine": false,
        "nature": false,
        "perception": false,
        "performance": false,
        "persuasion": false,
        "religion": false,
        "sleight_of_hand": false,
        "stealth": false,
        "survival": false
    ]
    
    // Skill ability mappings
    var skillAbilities: [String: String] = [
        "acrobatics": "dexterity",
        "animal_handling": "wisdom",
        "arcana": "intelligence",
        "athletics": "strength",
        "deception": "charisma",
        "history": "intelligence",
        "insight": "wisdom",
        "intimidation": "charisma",
        "investigation": "intelligence",
        "medicine": "wisdom",
        "nature": "intelligence",
        "perception": "wisdom",
        "performance": "charisma",
        "persuasion": "charisma",
        "religion": "intelligence",
        "sleight_of_hand": "dexterity",
        "stealth": "dexterity",
        "survival": "wisdom"
    ]
    
    // Character Traits
    var personalityTraits: String = ""
    var ideals: String = ""
    var bonds: String = ""
    var flaws: String = ""
    
    // Class Features and Abilities (cached from JSON)
    var classFeatures: [String: [String: [ClassFeature]]] = [:] // [classSlug: [level: [features]]]
    var classProgression: [String: ClassTable] = [:] // [classSlug: progressionTable]
    
    // Equipment and Features
    var equipment: String = ""
    var featuresAndTraits: String = ""
    var otherProficiencies: String = ""
    
    // Attacks and Spellcasting
    var attacks: [Attack] = []
    var spellSlots: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
    
    // Spells
    var spells: [CharacterSpell] = []
    
    // Treasure and Resources
    var treasure: String = ""
    var specialResources: String = ""
    
    // Languages
    var languages: String = ""
    
    // Hit Dice
    var hitDiceUsed: Int = 0
    
    var dateCreated: Date = Date()
    var dateModified: Date = Date()
    
    // MARK: - Initializer
    init() {
        // Default initializer - all properties already have default values
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id, name, playerName, race, characterClass, characterClasses, background, alignment, experience, level
        case armorClass, initiative, speed, maxHitPoints, currentHitPoints, temporaryHitPoints
        case hitDiceTotal, hitDiceType, proficiencyBonus, inspiration
        case deathSaveSuccesses, deathSaveFailures, exhaustionLevel
        case strength, dexterity, constitution, intelligence, wisdom, charisma
        case savingThrows, skills, skillAbilities
        case personalityTraits, ideals, bonds, flaws
        case classFeatures, classProgression
        case equipment, featuresAndTraits, otherProficiencies
        case attacks, spellSlots, spells
        case treasure, specialResources, languages, hitDiceUsed
        case dateCreated, dateModified
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        playerName = try container.decode(String.self, forKey: .playerName)
        race = try container.decode(String.self, forKey: .race)
        characterClass = try container.decodeIfPresent(String.self, forKey: .characterClass) ?? ""
        characterClasses = try container.decodeIfPresent([CharacterClass].self, forKey: .characterClasses) ?? []
        background = try container.decode(String.self, forKey: .background)
        alignment = try container.decode(String.self, forKey: .alignment)
        experience = try container.decode(Int.self, forKey: .experience)
        level = try container.decode(Int.self, forKey: .level)
        
        armorClass = try container.decode(Int.self, forKey: .armorClass)
        initiative = try container.decode(Int.self, forKey: .initiative)
        speed = try container.decode(Int.self, forKey: .speed)
        maxHitPoints = try container.decode(Int.self, forKey: .maxHitPoints)
        currentHitPoints = try container.decode(Int.self, forKey: .currentHitPoints)
        temporaryHitPoints = try container.decode(Int.self, forKey: .temporaryHitPoints)
        hitDiceTotal = try container.decode(Int.self, forKey: .hitDiceTotal)
        hitDiceType = try container.decode(String.self, forKey: .hitDiceType)
        proficiencyBonus = try container.decode(Int.self, forKey: .proficiencyBonus)
        inspiration = try container.decode(Bool.self, forKey: .inspiration)
        
        deathSaveSuccesses = try container.decode(Int.self, forKey: .deathSaveSuccesses)
        deathSaveFailures = try container.decode(Int.self, forKey: .deathSaveFailures)
        exhaustionLevel = try container.decode(Int.self, forKey: .exhaustionLevel)
        
        strength = try container.decode(Int.self, forKey: .strength)
        dexterity = try container.decode(Int.self, forKey: .dexterity)
        constitution = try container.decode(Int.self, forKey: .constitution)
        intelligence = try container.decode(Int.self, forKey: .intelligence)
        wisdom = try container.decode(Int.self, forKey: .wisdom)
        charisma = try container.decode(Int.self, forKey: .charisma)
        
        savingThrows = try container.decode([String: Bool].self, forKey: .savingThrows)
        skills = try container.decode([String: Bool].self, forKey: .skills)
        skillAbilities = try container.decode([String: String].self, forKey: .skillAbilities)
        
        personalityTraits = try container.decode(String.self, forKey: .personalityTraits)
        ideals = try container.decode(String.self, forKey: .ideals)
        bonds = try container.decode(String.self, forKey: .bonds)
        flaws = try container.decode(String.self, forKey: .flaws)
        
        classFeatures = try container.decodeIfPresent([String: [String: [ClassFeature]]].self, forKey: .classFeatures) ?? [:]
        classProgression = try container.decodeIfPresent([String: ClassTable].self, forKey: .classProgression) ?? [:]
        
        equipment = try container.decode(String.self, forKey: .equipment)
        featuresAndTraits = try container.decode(String.self, forKey: .featuresAndTraits)
        otherProficiencies = try container.decode(String.self, forKey: .otherProficiencies)
        
        attacks = try container.decode([Attack].self, forKey: .attacks)
        spellSlots = try container.decode([Int: Int].self, forKey: .spellSlots)
        spells = try container.decode([CharacterSpell].self, forKey: .spells)
        
        treasure = try container.decode(String.self, forKey: .treasure)
        specialResources = try container.decode(String.self, forKey: .specialResources)
        languages = try container.decode(String.self, forKey: .languages)
        hitDiceUsed = try container.decode(Int.self, forKey: .hitDiceUsed)
        
        dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        dateModified = try container.decode(Date.self, forKey: .dateModified)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(playerName, forKey: .playerName)
        try container.encode(race, forKey: .race)
        try container.encode(characterClass, forKey: .characterClass)
        try container.encode(characterClasses, forKey: .characterClasses)
        try container.encode(background, forKey: .background)
        try container.encode(alignment, forKey: .alignment)
        try container.encode(experience, forKey: .experience)
        try container.encode(level, forKey: .level)
        
        try container.encode(armorClass, forKey: .armorClass)
        try container.encode(initiative, forKey: .initiative)
        try container.encode(speed, forKey: .speed)
        try container.encode(maxHitPoints, forKey: .maxHitPoints)
        try container.encode(currentHitPoints, forKey: .currentHitPoints)
        try container.encode(temporaryHitPoints, forKey: .temporaryHitPoints)
        try container.encode(hitDiceTotal, forKey: .hitDiceTotal)
        try container.encode(hitDiceType, forKey: .hitDiceType)
        try container.encode(proficiencyBonus, forKey: .proficiencyBonus)
        try container.encode(inspiration, forKey: .inspiration)
        
        try container.encode(deathSaveSuccesses, forKey: .deathSaveSuccesses)
        try container.encode(deathSaveFailures, forKey: .deathSaveFailures)
        try container.encode(exhaustionLevel, forKey: .exhaustionLevel)
        
        try container.encode(strength, forKey: .strength)
        try container.encode(dexterity, forKey: .dexterity)
        try container.encode(constitution, forKey: .constitution)
        try container.encode(intelligence, forKey: .intelligence)
        try container.encode(wisdom, forKey: .wisdom)
        try container.encode(charisma, forKey: .charisma)
        
        try container.encode(savingThrows, forKey: .savingThrows)
        try container.encode(skills, forKey: .skills)
        try container.encode(skillAbilities, forKey: .skillAbilities)
        
        try container.encode(personalityTraits, forKey: .personalityTraits)
        try container.encode(ideals, forKey: .ideals)
        try container.encode(bonds, forKey: .bonds)
        try container.encode(flaws, forKey: .flaws)
        
        try container.encode(classFeatures, forKey: .classFeatures)
        try container.encode(classProgression, forKey: .classProgression)
        
        try container.encode(equipment, forKey: .equipment)
        try container.encode(featuresAndTraits, forKey: .featuresAndTraits)
        try container.encode(otherProficiencies, forKey: .otherProficiencies)
        
        try container.encode(attacks, forKey: .attacks)
        try container.encode(spellSlots, forKey: .spellSlots)
        try container.encode(spells, forKey: .spells)
        
        try container.encode(treasure, forKey: .treasure)
        try container.encode(specialResources, forKey: .specialResources)
        try container.encode(languages, forKey: .languages)
        try container.encode(hitDiceUsed, forKey: .hitDiceUsed)
        
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(dateModified, forKey: .dateModified)
    }
    
    // MARK: - Equatable Implementation
    static func == (lhs: Character, rhs: Character) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Computed Properties
    var strengthModifier: Int { (strength - 10) / 2 }
    var dexterityModifier: Int { (dexterity - 10) / 2 }
    var constitutionModifier: Int { (constitution - 10) / 2 }
    var intelligenceModifier: Int { (intelligence - 10) / 2 }
    var wisdomModifier: Int { (wisdom - 10) / 2 }
    var charismaModifier: Int { (charisma - 10) / 2 }
    
    // Multiclass properties
    var totalLevel: Int { characterClasses.reduce(0) { $0 + $1.level } }
    var primaryClass: CharacterClass? { characterClasses.first }
    var displayClassName: String {
        if characterClasses.isEmpty {
            return characterClass.isEmpty ? "—" : characterClass
        }
        return characterClasses.map { "\($0.name) \($0.level)" }.joined(separator: " / ")
    }
    
    var passivePerception: Int { 10 + wisdomModifier + (skills["perception"] == true ? proficiencyBonus : 0) }
    
    // Скорость с учетом истощения
    var effectiveSpeed: Int { max(0, speed - (exhaustionLevel * 5)) }
    
    // Ability checks with exhaustion penalty (ability checks include skills)
    func abilityCheckModifier(for ability: String) -> Int {
        let base: Int
        switch ability {
        case "strength": base = strengthModifier
        case "dexterity": base = dexterityModifier
        case "constitution": base = constitutionModifier
        case "intelligence": base = intelligenceModifier
        case "wisdom": base = wisdomModifier
        case "charisma": base = charismaModifier
        default: base = 0
        }
        return base - (exhaustionLevel * 2)
    }
    
    // Skill modifiers
    func skillModifier(for skill: String) -> Int {
        guard let ability = skillAbilities[skill] else { return 0 }
        
        let abilityModifier = abilityCheckModifier(for: ability)
        
        return abilityModifier + (skills[skill] == true ? proficiencyBonus : 0)
    }
    
    // Saving throw modifiers
    func savingThrowModifier(for ability: String) -> Int {
        let base = abilityCheckModifier(for: ability)
        return base + (savingThrows[ability] == true ? proficiencyBonus : 0)
    }
}

struct Attack: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String = ""
    var attackBonus: String = ""
    var damageType: String = ""
}

struct CharacterSpell: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String = ""
    var level: Int = 0
    var school: String = ""
    var castingTime: String = ""
    var range: String = ""
    var components: String = ""
    var duration: String = ""
    var description: String = ""
    var isPrepared: Bool = false
}

// MARK: - Character Store

final class CharacterStore: ObservableObject {
    @Published var characters: [Character] = [] {
        didSet { save() }
    }
    
    @Published var selectedCharacter: Character? {
        didSet { saveSelectedCharacter() }
    }
    
    private let key = "characters_v1"
    private let selectedCharacterKey = "selectedCharacter_v1"
    private let cacheManager = CacheManager.shared
    
    init() {
        load()
        
        // Добавляем тестового персонажа, если список пуст
        if characters.isEmpty {
            addTestCharacter()
        }
    }
    
    private func addTestCharacter() {
        var testCharacter = Character()
        testCharacter.name = "Абоба"
        testCharacter.playerName = "Тест"
        testCharacter.race = "Человек"
        testCharacter.characterClass = "Монах"
        testCharacter.background = "Чужеземец"
        testCharacter.alignment = "Хаотично-нейтральный"
        testCharacter.level = 2
        testCharacter.experience = 0
        
        // Характеристики
        testCharacter.strength = 17
        testCharacter.dexterity = 18
        testCharacter.constitution = 18
        testCharacter.intelligence = 12
        testCharacter.wisdom = 14
        testCharacter.charisma = 16
        
        // Боевые характеристики
        testCharacter.armorClass = 15 // Studded leather + Dex
        testCharacter.initiative = 4 // Dex modifier
        testCharacter.speed = 30
        testCharacter.maxHitPoints = 22
        testCharacter.currentHitPoints = 22
        testCharacter.hitDiceTotal = 2
        testCharacter.hitDiceType = "d8"
        testCharacter.proficiencyBonus = 2
        
        // Спасброски (Плут: Dex, Int; Воин: Str, Con)
        testCharacter.savingThrows["dexterity"] = true
        testCharacter.savingThrows["intelligence"] = true
        testCharacter.savingThrows["strength"] = true
        testCharacter.savingThrows["constitution"] = true
        
        // Навыки (Плут: Акробатика, Восприятие, Ловкость рук, Проницательность, Скрытность)
        testCharacter.skills["acrobatics"] = true
        testCharacter.skills["perception"] = true
        testCharacter.skills["sleight_of_hand"] = true
        testCharacter.skills["insight"] = true
        testCharacter.skills["stealth"] = true
        
        // Дополнительные навыки от предыстории и расы
        testCharacter.skills["survival"] = true
        
        // Черты характера
        testCharacter.personalityTraits = "Я всегда настороже и первым замечаю опасность."
        testCharacter.ideals = "Свобода. Цепи предназначены для того, чтобы их разрывать."
        testCharacter.bonds = "Я защищаю тех, кто не может защитить себя."
        testCharacter.flaws = "Я слишком доверяю тем, кто разделяет мои убеждения."
        
        // Снаряжение
        testCharacter.equipment = """
        • Рюкзак
        • Трутница
        • 10 факелов
        • Рационы на 10 дней
        • Бурдюк
        • 50-футовая верёвка
        • Дорожная одежда
        • Длинный плащ с капюшоном
        • Поясной кошель
        • Проклёпанная кожа
        • 2 коротких меча
        • 2 кинжала
        • Воровские инструменты
        • Лютня
        """
        
        // Особенности и черты
        testCharacter.featuresAndTraits = """
        • Скрытая атака
        • Использование двух оружий
        • Странник
        • Метка Древнейшей
        • Темное зрение
        • Сражение двумя оружиями
        • Второе дыхание
        """
        
        // Прочие владения и языки
        testCharacter.otherProficiencies = """
        • Лёгкие доспехи
        • Простое оружие
        • Воровские инструменты
        • Лютня
        • Средние доспехи
        • Щиты
        • Воинское оружие
        """
        
        // Языки
        testCharacter.languages = """
        • Язык из родного мира
        • Общий
        • Эльфийский
        • Дварфский
        • Воровской жаргон
        """
        
        // Сокровища и ресурсы
        testCharacter.treasure = """
        • 15 золотых монет
        • 3 серебряных монеты
        • 8 медных монет
        • Драгоценный камень (50 золотых)
        """
        
        testCharacter.specialResources = """
        • Вдохновение: 1
        • Второе дыхание: 1/день
        """
        
        // Атаки
        testCharacter.attacks = [
            Attack(name: "Короткий меч", attackBonus: "+6", damageType: "колющий 1d6+4"),
            Attack(name: "Кинжал", attackBonus: "+6", damageType: "колющий 1d4+4"),
            Attack(name: "Скрытая атака", attackBonus: "+6", damageType: "колющий 1d6+4 + 1d6")
        ]
        
        add(testCharacter)
    }
    
    func add(_ character: Character) {
        var newCharacters = characters
        newCharacters.append(character)
        characters = newCharacters.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }
    
    func remove(at offsets: IndexSet) {
        characters.remove(atOffsets: offsets)
    }
    
    func remove(character: Character) {
        print("🗑️ [CHARACTER] Попытка удаления персонажа: \(character.name) (ID: \(character.id))")
        print("🗑️ [CHARACTER] Всего персонажей до удаления: \(characters.count)")
        
        if let idx = characters.firstIndex(where: { $0.id == character.id }) {
            characters.remove(at: idx)
            print("✅ [CHARACTER] Персонаж успешно удален. Осталось персонажей: \(characters.count)")
        } else {
            print("❌ [CHARACTER] Персонаж не найден для удаления")
        }
    }

    func duplicate(_ character: Character) {
        var copy = character
        copy.id = UUID()
        copy.name += " копия"
        copy.dateCreated = Date()
        copy.dateModified = Date()
        add(copy)
    }
    
    func update(_ character: Character) {
        if let idx = characters.firstIndex(where: { $0.id == character.id }) {
            var newCharacters = characters
            newCharacters[idx] = character
            characters = newCharacters.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
            if selectedCharacter?.id == character.id { selectedCharacter = character }
        }
    }

    func filteredCharacters(searchText: String) -> [Character] {
        if searchText.isEmpty { return characters }
        return characters.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    func updateCharacterClasses(_ character: Character, classesStore: ClassesStore) {
        var updatedCharacter = character
        
        // Update cached class data for all classes
        for characterClass in character.characterClasses {
            if let gameClass = classesStore.classesBySlug[characterClass.slug] {
                updatedCharacter.classFeatures[characterClass.slug] = gameClass.featuresByLevel
            }
            
            if let classTable = classesStore.classTablesBySlug[characterClass.slug] {
                updatedCharacter.classProgression[characterClass.slug] = classTable
            }
        }
        
        update(updatedCharacter)
    }
    
    func importFromJSON(_ jsonString: String) -> Bool {
        do {
            let importedChar = try JSONDecoder().decode(ImportedCharacter.self, from: jsonString.data(using: .utf8)!)
            let charData = try JSONDecoder().decode(CharacterData.self, from: importedChar.data.data(using: .utf8)!)
            
            var newCharacter = Character()
            
            // Основная информация
            newCharacter.name = charData.name.value.isEmpty ? "Без имени" : charData.name.value
            newCharacter.playerName = charData.info.playerName.value.isEmpty ? "" : charData.info.playerName.value
            newCharacter.race = charData.info.race.value.isEmpty ? "" : charData.info.race.value
            newCharacter.characterClass = charData.info.charClass.value.isEmpty ? "" : charData.info.charClass.value
            newCharacter.background = charData.info.background.value.isEmpty ? "" : charData.info.background.value
            newCharacter.alignment = charData.info.alignment.value.isEmpty ? "" : charData.info.alignment.value
            newCharacter.level = Int(charData.info.level.value) ?? 1
            newCharacter.experience = Int(charData.info.experience.value) ?? 0
            
            // Характеристики
            newCharacter.strength = charData.stats.str.score
            newCharacter.dexterity = charData.stats.dex.score
            newCharacter.constitution = charData.stats.con.score
            newCharacter.intelligence = charData.stats.int.score
            newCharacter.wisdom = charData.stats.wis.score
            newCharacter.charisma = charData.stats.cha.score
            
            // Спасброски
            newCharacter.savingThrows["strength"] = charData.saves.str.isProf
            newCharacter.savingThrows["dexterity"] = charData.saves.dex.isProf
            newCharacter.savingThrows["constitution"] = charData.saves.con.isProf
            newCharacter.savingThrows["intelligence"] = charData.saves.int.isProf
            newCharacter.savingThrows["wisdom"] = charData.saves.wis.isProf
            newCharacter.savingThrows["charisma"] = charData.saves.cha.isProf
            
            // Навыки - улучшенная обработка
            let skillMappings: [(String, SkillValue?)] = [
                ("athletics", charData.skills.athletics),
                ("acrobatics", charData.skills.acrobatics),
                ("sleight_of_hand", charData.skills.sleightOfHand),
                ("stealth", charData.skills.stealth),
                ("arcana", charData.skills.arcana),
                ("history", charData.skills.history),
                ("investigation", charData.skills.investigation),
                ("nature", charData.skills.nature),
                ("religion", charData.skills.religion),
                ("animal_handling", charData.skills.animalHandling),
                ("insight", charData.skills.insight),
                ("medicine", charData.skills.medicine),
                ("perception", charData.skills.perception),
                ("survival", charData.skills.survival),
                ("deception", charData.skills.deception),
                ("intimidation", charData.skills.intimidation),
                ("performance", charData.skills.performance),
                ("persuasion", charData.skills.persuasion)
            ]
            
            for (skillKey, skillValue) in skillMappings {
                if let skill = skillValue, skill.isProf == 1 {
                    newCharacter.skills[skillKey] = true
                }
            }
            
            // Боевые характеристики
            newCharacter.armorClass = Int(charData.vitality.ac.value) ?? 10
            newCharacter.speed = Int(charData.vitality.speed.value) ?? 30
            newCharacter.maxHitPoints = Int(charData.vitality.hpMax.value) ?? 0
            newCharacter.currentHitPoints = Int(charData.vitality.hpMax.value) ?? 0
            newCharacter.proficiencyBonus = charData.proficiency
            
            // Инициатива (рассчитывается из модификатора ловкости)
            newCharacter.initiative = charData.stats.dex.modifier ?? 0
            
            // Хиты и кости
            newCharacter.hitDiceTotal = newCharacter.level
            newCharacter.hitDiceType = "d8" // По умолчанию, можно улучшить
            
            // Черты характера - улучшенная обработка
            if let background = charData.text.background {
                newCharacter.personalityTraits = background.value.data.extractText()
            }
            if let ideals = charData.text.ideals {
                newCharacter.ideals = ideals.value.data.extractText()
            }
            if let bonds = charData.text.bonds {
                newCharacter.bonds = bonds.value.data.extractText()
            }
            if let flaws = charData.text.flaws {
                newCharacter.flaws = flaws.value.data.extractText()
            }
            if let personality = charData.text.personality {
                newCharacter.personalityTraits = personality.value.data.extractText()
            }
            
            // Особенности и черты
            var featuresText = ""
            if let traits = charData.text.traits {
                featuresText += traits.value.data.extractText()
            }
            if let prof = charData.prof {
                if !featuresText.isEmpty {
                    featuresText += "\n\n"
                }
                featuresText += prof.value.extractText()
            }
            newCharacter.featuresAndTraits = featuresText
            
            // Снаряжение и атаки
            var equipmentText = ""
            if let attacks = charData.text.attacks {
                equipmentText += "Атаки:\n" + attacks.value.data.extractText()
            }
            
            // Добавляем оружие из списка
            if !charData.weaponsList.isEmpty {
                if !equipmentText.isEmpty {
                    equipmentText += "\n\n"
                }
                equipmentText += "Оружие:\n"
                for weapon in charData.weaponsList {
                    equipmentText += "• \(weapon.name.value) (\(weapon.dmg.value))\n"
                }
            }
            
            newCharacter.equipment = equipmentText
            
                    // Прочие владения
        if let prof = charData.prof {
            newCharacter.otherProficiencies = prof.value.extractText()
        }
        
        // Языки (по умолчанию)
        newCharacter.languages = "Общий"
        
        // Кости хитов
        newCharacter.hitDiceUsed = 0
            
            // Атаки
            for weapon in charData.weaponsList {
                let attack = Attack(
                    name: weapon.name.value,
                    attackBonus: weapon.mod.value,
                    damageType: weapon.dmg.value
                )
                newCharacter.attacks.append(attack)
            }
            
            print("✅ [IMPORT] Успешно импортирован персонаж: \(newCharacter.name)")
            print("   - Уровень: \(newCharacter.level)")
            print("   - Класс: \(newCharacter.characterClass)")
            print("   - Раса: \(newCharacter.race)")
            print("   - HP: \(newCharacter.currentHitPoints)/\(newCharacter.maxHitPoints)")
            print("   - КЗ: \(newCharacter.armorClass)")
            print("   - Навыков: \(newCharacter.skills.filter { $0.value }.count)")
            print("   - Атак: \(newCharacter.attacks.count)")
            
            add(newCharacter)
            return true
        } catch {
            print("❌ Failed to import character: \(error)")
            print("   JSON: \(jsonString.prefix(500))...")
            return false
        }
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(characters)
            UserDefaults.standard.set(data, forKey: key)
            // Кэшируем персонажей
            cacheManager.cacheCharacters(characters)
        } catch {
            print("❌ Failed to encode characters: \(error)")
        }
    }
    
    func updateCharacterHitPoints(_ character: Character, newCurrentHP: Int) {
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            characters[index].currentHitPoints = max(0, min(newCurrentHP, character.maxHitPoints))
            
            // Обновляем выбранного персонажа, если это он
            if selectedCharacter?.id == character.id {
                selectedCharacter = characters[index]
            }
            
            // Сохраняем в кэш
            cacheManager.cacheCharacters(characters)
            saveSelectedCharacter()
            
            print("✅ [CHARACTERS] Обновлены хиты персонажа \(character.name): \(newCurrentHP)")
        }
    }
    
    func updateCharacterExhaustion(_ character: Character, newExhaustionLevel: Int) {
        if let index = characters.firstIndex(where: { $0.id == character.id }) {
            characters[index].exhaustionLevel = max(0, min(newExhaustionLevel, 6))
            
            // Обновляем выбранного персонажа, если это он
            if selectedCharacter?.id == character.id {
                selectedCharacter = characters[index]
            }
            
            // Сохраняем в кэш
            cacheManager.cacheCharacters(characters)
            saveSelectedCharacter()
            
            print("✅ [CHARACTERS] Обновлена степень истощения персонажа \(character.name): \(newExhaustionLevel)")
        }
    }
    
    func importCharacterFromJSON(_ jsonString: String) -> Character? {
        // Сначала пытаемся импортировать как наш собственный формат Character
        if let data = jsonString.data(using: .utf8),
           let directCharacter = try? JSONDecoder().decode(Character.self, from: data) {
            print("✅ [IMPORT] Импортирован персонаж в формате Character: \(directCharacter.name)")
            return directCharacter
        }
        
        // Если не получилось, пытаемся импортировать как внешний формат
        do {
            let data = jsonString.data(using: .utf8)!
            let importedCharacter = try JSONDecoder().decode(ImportedCharacter.self, from: data)
            
            guard importedCharacter.jsonType == "character" else {
                print("❌ [IMPORT] Неверный тип JSON: \(importedCharacter.jsonType)")
                return nil
            }
            
            let charData = try JSONDecoder().decode(CharacterData.self, from: importedCharacter.data.data(using: .utf8)!)
            
            var newCharacter = Character()
            
            // Основная информация
            newCharacter.name = charData.name.value
            newCharacter.playerName = charData.info.playerName.value
            newCharacter.race = charData.info.race.value
            newCharacter.characterClass = charData.info.charClass.value
            newCharacter.background = charData.info.background.value
            newCharacter.alignment = charData.info.alignment.value
            newCharacter.level = Int(charData.info.level.value) ?? 1
            newCharacter.experience = Int(charData.info.experience.value) ?? 0
            
            // Характеристики
            newCharacter.strength = charData.stats.str.score
            newCharacter.dexterity = charData.stats.dex.score
            newCharacter.constitution = charData.stats.con.score
            newCharacter.intelligence = charData.stats.int.score
            newCharacter.wisdom = charData.stats.wis.score
            newCharacter.charisma = charData.stats.cha.score
            
            // Боевые характеристики
            newCharacter.armorClass = 10 + newCharacter.dexterityModifier
            newCharacter.initiative = newCharacter.dexterityModifier
            newCharacter.speed = 30
            newCharacter.maxHitPoints = 10 + newCharacter.constitutionModifier
            newCharacter.currentHitPoints = newCharacter.maxHitPoints
            newCharacter.hitDiceTotal = newCharacter.level
            newCharacter.hitDiceType = "d8"
            newCharacter.proficiencyBonus = (newCharacter.level - 1) / 4 + 2
            
            // Спасброски
            newCharacter.savingThrows["strength"] = charData.saves.str.isProf
            newCharacter.savingThrows["dexterity"] = charData.saves.dex.isProf
            newCharacter.savingThrows["constitution"] = charData.saves.con.isProf
            newCharacter.savingThrows["intelligence"] = charData.saves.int.isProf
            newCharacter.savingThrows["wisdom"] = charData.saves.wis.isProf
            newCharacter.savingThrows["charisma"] = charData.saves.cha.isProf
            
            // Навыки
            if let acrobatics = charData.skills.acrobatics { newCharacter.skills["acrobatics"] = acrobatics.isProf != nil }
            if let investigation = charData.skills.investigation { newCharacter.skills["investigation"] = investigation.isProf != nil }
            if let athletics = charData.skills.athletics { newCharacter.skills["athletics"] = athletics.isProf != nil }
            if let perception = charData.skills.perception { newCharacter.skills["perception"] = perception.isProf != nil }
            if let survival = charData.skills.survival { newCharacter.skills["survival"] = survival.isProf != nil }
            if let performance = charData.skills.performance { newCharacter.skills["performance"] = performance.isProf != nil }
            if let intimidation = charData.skills.intimidation { newCharacter.skills["intimidation"] = intimidation.isProf != nil }
            if let history = charData.skills.history { newCharacter.skills["history"] = history.isProf != nil }
            if let sleightOfHand = charData.skills.sleightOfHand { newCharacter.skills["sleight_of_hand"] = sleightOfHand.isProf != nil }
            if let arcana = charData.skills.arcana { newCharacter.skills["arcana"] = arcana.isProf != nil }
            if let medicine = charData.skills.medicine { newCharacter.skills["medicine"] = medicine.isProf != nil }
            if let deception = charData.skills.deception { newCharacter.skills["deception"] = deception.isProf != nil }
            if let nature = charData.skills.nature { newCharacter.skills["nature"] = nature.isProf != nil }
            if let insight = charData.skills.insight { newCharacter.skills["insight"] = insight.isProf != nil }
            if let religion = charData.skills.religion { newCharacter.skills["religion"] = religion.isProf != nil }
            if let animalHandling = charData.skills.animalHandling { newCharacter.skills["animal_handling"] = animalHandling.isProf != nil }
            if let stealth = charData.skills.stealth { newCharacter.skills["stealth"] = stealth.isProf != nil }
            if let persuasion = charData.skills.persuasion { newCharacter.skills["persuasion"] = persuasion.isProf != nil }
            
            // Черты характера
            if let traits = charData.text.traits {
                newCharacter.personalityTraits = traits.value.data.extractText()
            }
            if let ideals = charData.text.ideals {
                newCharacter.ideals = ideals.value.data.extractText()
            }
            if let bonds = charData.text.bonds {
                newCharacter.bonds = bonds.value.data.extractText()
            }
            if let flaws = charData.text.flaws {
                newCharacter.flaws = flaws.value.data.extractText()
            }
            
            // Особенности и черты
            var featuresText = ""
            if let traits = charData.text.traits {
                featuresText += traits.value.data.extractText()
            }
            if let prof = charData.prof {
                if !featuresText.isEmpty {
                    featuresText += "\n\n"
                }
                featuresText += prof.value.extractText()
            }
            newCharacter.featuresAndTraits = featuresText
            
            // Снаряжение и атаки
            var equipmentText = ""
            if let attacks = charData.text.attacks {
                equipmentText += "Атаки:\n" + attacks.value.data.extractText()
            }
            
            // Добавляем оружие из списка
            if !charData.weaponsList.isEmpty {
                if !equipmentText.isEmpty {
                    equipmentText += "\n\n"
                }
                equipmentText += "Оружие:\n"
                for weapon in charData.weaponsList {
                    equipmentText += "• \(weapon.name.value) (\(weapon.dmg.value))\n"
                }
            }
            
            newCharacter.equipment = equipmentText
            
            // Прочие владения
            if let prof = charData.prof {
                newCharacter.otherProficiencies = prof.value.extractText()
            }
            
            // Языки (по умолчанию)
            newCharacter.languages = "Общий"
            
            // Кости хитов
            newCharacter.hitDiceUsed = 0
                
            // Атаки
            for weapon in charData.weaponsList {
                let attack = Attack(
                    name: weapon.name.value,
                    attackBonus: weapon.mod.value,
                    damageType: weapon.dmg.value
                )
                newCharacter.attacks.append(attack)
            }
            
            print("✅ [IMPORT] Успешно импортирован персонаж: \(newCharacter.name)")
            return newCharacter
            
        } catch {
            print("❌ Failed to import character: \(error)")
            return nil
        }
    }
    
    private func load() {
        // Сначала пытаемся загрузить из кэша
        if let cachedCharacters = cacheManager.getCachedCharacters() {
            characters = cachedCharacters
            print("✅ [CHARACTERS] Загружено \(cachedCharacters.count) персонажей из кэша")
        } else {
            // Если кэша нет, загружаем из UserDefaults
            guard let data = UserDefaults.standard.data(forKey: key) else { return }
            do {
                characters = try JSONDecoder().decode([Character].self, from: data)
                // Кэшируем персонажей
                cacheManager.cacheCharacters(characters)
                print("✅ [CHARACTERS] Загружено \(characters.count) персонажей из UserDefaults и закэшировано")
            } catch {
                print("❌ Failed to decode characters: \(error)")
            }
        }
        
        characters.sort {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }

        // Загружаем выбранного персонажа
        loadSelectedCharacter()
    }
    
    private func saveSelectedCharacter() {
        guard let selectedCharacter = selectedCharacter else {
            UserDefaults.standard.removeObject(forKey: selectedCharacterKey)
            return
        }
        
        do {
            let data = try JSONEncoder().encode(selectedCharacter)
            UserDefaults.standard.set(data, forKey: selectedCharacterKey)
            print("✅ [CHARACTER] Сохранен выбранный персонаж: \(selectedCharacter.name)")
        } catch {
            print("❌ Failed to save selected character: \(error)")
        }
    }
    
    private func loadSelectedCharacter() {
        guard let data = UserDefaults.standard.data(forKey: selectedCharacterKey) else { return }
        
        do {
            let savedCharacter = try JSONDecoder().decode(Character.self, from: data)
            // Находим персонажа в списке по ID
            if let character = characters.first(where: { $0.id == savedCharacter.id }) {
                selectedCharacter = character
                print("✅ [CHARACTER] Загружен выбранный персонаж: \(character.name)")
            } else {
                print("⚠️ [CHARACTER] Выбранный персонаж не найден в списке, сбрасываем выбор")
                selectedCharacter = nil
            }
        } catch {
            print("❌ Failed to load selected character: \(error)")
            selectedCharacter = nil
        }
    }
}
