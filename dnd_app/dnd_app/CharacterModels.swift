import SwiftUI

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
    var characterClass: String = ""
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
    
    // Equipment and Features
    var equipment: String = ""
    var featuresAndTraits: String = ""
    var otherProficiencies: String = ""
    
    // Attacks and Spellcasting
    var attacks: [Attack] = []
    var spellSlots: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
    
    var dateCreated: Date = Date()
    var dateModified: Date = Date()
    
    // Computed Properties
    var strengthModifier: Int { (strength - 10) / 2 }
    var dexterityModifier: Int { (dexterity - 10) / 2 }
    var constitutionModifier: Int { (constitution - 10) / 2 }
    var intelligenceModifier: Int { (intelligence - 10) / 2 }
    var wisdomModifier: Int { (wisdom - 10) / 2 }
    var charismaModifier: Int { (charisma - 10) / 2 }
    
    var passivePerception: Int { 10 + wisdomModifier + (skills["perception"] == true ? proficiencyBonus : 0) }
    
    // Skill modifiers
    func skillModifier(for skill: String) -> Int {
        guard let ability = skillAbilities[skill] else { return 0 }
        
        let abilityModifier: Int
        switch ability {
        case "strength": abilityModifier = strengthModifier
        case "dexterity": abilityModifier = dexterityModifier
        case "constitution": abilityModifier = constitutionModifier
        case "intelligence": abilityModifier = intelligenceModifier
        case "wisdom": abilityModifier = wisdomModifier
        case "charisma": abilityModifier = charismaModifier
        default: abilityModifier = 0
        }
        
        return abilityModifier + (skills[skill] == true ? proficiencyBonus : 0)
    }
    
    // Saving throw modifiers
    func savingThrowModifier(for ability: String) -> Int {
        let abilityModifier: Int
        switch ability {
        case "strength": abilityModifier = strengthModifier
        case "dexterity": abilityModifier = dexterityModifier
        case "constitution": abilityModifier = constitutionModifier
        case "intelligence": abilityModifier = intelligenceModifier
        case "wisdom": abilityModifier = wisdomModifier
        case "charisma": abilityModifier = charismaModifier
        default: abilityModifier = 0
        }
        
        return abilityModifier + (savingThrows[ability] == true ? proficiencyBonus : 0)
    }
}

struct Attack: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String = ""
    var attackBonus: String = ""
    var damageType: String = ""
}

// MARK: - Character Store

final class CharacterStore: ObservableObject {
    @Published var characters: [Character] = [] {
        didSet { save() }
    }
    
    private let key = "characters_v1"
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
        testCharacter.name = "Андрей"
        testCharacter.playerName = "Panikoid"
        testCharacter.race = "Человек"
        testCharacter.characterClass = "Плут 1/Воин 1"
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
        • Язык из родного мира
        • Общий
        • Эльфийский
        • Дварфский
        • Воровской жаргон
        • Лёгкие доспехи
        • Простое оружие
        • Воровские инструменты
        • Лютня
        • Средние доспехи
        • Щиты
        • Воинское оружие
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
        characters.append(character)
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
    
    func update(_ character: Character) {
        if let idx = characters.firstIndex(where: { $0.id == character.id }) {
            characters[idx] = character
        }
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
    
    private func load() {
        // Сначала пытаемся загрузить из кэша
        if let cachedCharacters = cacheManager.getCachedCharacters() {
            characters = cachedCharacters
            print("✅ [CHARACTERS] Загружено \(cachedCharacters.count) персонажей из кэша")
            return
        }
        
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
}
