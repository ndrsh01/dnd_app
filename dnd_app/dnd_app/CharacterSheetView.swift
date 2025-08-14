import SwiftUI
import UniformTypeIdentifiers

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
        if let idx = characters.firstIndex(where: { $0.id == character.id }) {
            characters.remove(at: idx)
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

// MARK: - Character Sheet View

struct CharacterSheetView: View {
    @StateObject private var store = CharacterStore()
    @State private var showingAdd = false
    @State private var showingImport = false
    @State private var searchText = ""
    
    var filteredCharacters: [Character] {
        if searchText.isEmpty {
            return store.characters
        } else {
            return store.characters.filter { character in
                character.name.localizedCaseInsensitiveContains(searchText) ||
                character.playerName.localizedCaseInsensitiveContains(searchText) ||
                character.characterClass.localizedCaseInsensitiveContains(searchText) ||
                character.race.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
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
                    // Поиск
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Поиск персонажей...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
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
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Список персонажей
                    if filteredCharacters.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "person.text.rectangle")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("Нет персонажей")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Создайте первого персонажа для начала игры")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(filteredCharacters) { character in
                                CharacterCard(character: character, store: store)
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .padding(.vertical, 4)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            deleteCharacter(character)
                                        } label: {
                                            Label("Удалить", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                    }
                }
            }
            .navigationTitle("Лист персонажа")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingAdd = true }) {
                            Label("Создать персонажа", systemImage: "person.badge.plus")
                        }
                        
                        Button(action: { showingImport = true }) {
                            Label("Импортировать JSON", systemImage: "doc.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                CharacterEditorView(store: store)
            }
            .sheet(isPresented: $showingImport) {
                CharacterImportView(store: store)
            }
        }
    }
    
    private func deleteCharacter(_ character: Character) {
        store.remove(character: character)
    }
}

// MARK: - Stat Badge

struct StatBadge: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ModernStatBadge: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка с градиентным фоном
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Character Import View

struct CharacterImportView: View {
    let store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    @State private var jsonText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var showingFilePicker = false
    @State private var showingDocumentPicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Заголовок
                VStack(spacing: 8) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Импорт персонажа")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Выберите файл для автоматического импорта или вставьте JSON вручную")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Кнопки выбора файла
                VStack(spacing: 12) {
                    Button(action: { showingFilePicker = true }) {
                        HStack {
                            Image(systemName: "folder")
                            Text("Выбрать файл")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    Button(action: { showingDocumentPicker = true }) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Открыть документ")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                }
                
                // Разделитель
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                    Text("ИЛИ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
                
                // Поле для JSON
                VStack(alignment: .leading, spacing: 8) {
                    Text("Вставить JSON вручную")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $jsonText)
                        .font(.system(.body, design: .monospaced))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .frame(minHeight: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                // Кнопки
                VStack(spacing: 12) {
                    Button(action: importCharacter) {
                        HStack {
                            Image(systemName: "arrow.down.doc")
                            Text("Импортировать из текста")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(jsonText.isEmpty ? Color.gray : Color.orange)
                        .cornerRadius(12)
                    }
                    .disabled(jsonText.isEmpty)
                    
                    Button(action: { dismiss() }) {
                        Text("Отмена")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color(hex: "#fceeda"))
            .navigationTitle("Импорт")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isSuccess ? "Успех!" : "Ошибка", isPresented: $showingAlert) {
                Button("OK") {
                    if isSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.json, .text],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .fileImporter(
                isPresented: $showingDocumentPicker,
                allowedContentTypes: [.json, .text, .plainText],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
        }
    }
    
    private func importCharacter() {
        guard !jsonText.isEmpty else { return }
        
        let success = store.importFromJSON(jsonText)
        isSuccess = success
        
        if success {
            alertMessage = "Персонаж успешно импортирован!"
        } else {
            alertMessage = "Ошибка при импорте. Проверьте формат JSON файла."
        }
        
        showingAlert = true
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                alertMessage = "Файл не выбран"
                isSuccess = false
                showingAlert = true
                return
            }
            
            do {
                // Начинаем доступ к файлу
                guard url.startAccessingSecurityScopedResource() else {
                    alertMessage = "Нет доступа к файлу"
                    isSuccess = false
                    showingAlert = true
                    return
                }
                
                defer {
                    url.stopAccessingSecurityScopedResource()
                }
                
                // Читаем содержимое файла
                let fileContent = try String(contentsOf: url, encoding: .utf8)
                
                // Сразу импортируем персонажа
                let success = store.importFromJSON(fileContent)
                isSuccess = success
                
                if success {
                    alertMessage = "Персонаж успешно импортирован из файла!"
                    // Закрываем окно импорта
                    dismiss()
                } else {
                    alertMessage = "Ошибка при импорте. Проверьте формат JSON файла."
                }
                
                showingAlert = true
                
            } catch {
                alertMessage = "Ошибка чтения файла: \(error.localizedDescription)"
                isSuccess = false
                showingAlert = true
            }
            
        case .failure(let error):
            alertMessage = "Ошибка выбора файла: \(error.localizedDescription)"
            isSuccess = false
            showingAlert = true
        }
    }
}

// MARK: - Character Card

struct CharacterCard: View {
    let character: Character
    let store: CharacterStore
    @State private var showingEditor = false
    @State private var showingViewer = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Основная информация
            HStack(spacing: 16) {
                // Аватар
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .orange.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name.isEmpty ? "Без имени" : character.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(character.race) \(character.characterClass)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Игрок: \(character.playerName.isEmpty ? "Не указан" : character.playerName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Уровень \(character.level)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text("\(character.currentHitPoints)/\(character.maxHitPoints) HP")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
            
            // Статистики
            HStack(spacing: 20) {
                StatBadge(title: "КЗ", value: "\(character.armorClass)", color: .blue)
                StatBadge(title: "Инициатива", value: "\(character.initiative >= 0 ? "+" : "")\(character.initiative)", color: .green)
                StatBadge(title: "Скорость", value: "\(character.speed) фт", color: .purple)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onTapGesture {
            showingViewer = true
        }
        .sheet(isPresented: $showingViewer) {
            CharacterViewerView(character: character, store: store)
        }
        .sheet(isPresented: $showingEditor) {
            CharacterEditorView(store: store, character: character)
        }
    }
}



// MARK: - Character Header View

struct CharacterHeaderView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Информация о персонаже")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Имя персонажа
                HStack {
                    Text("Имя")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(character.name.isEmpty ? "Без имени" : character.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                // Раса
                if !character.race.isEmpty {
                    HStack {
                        Text("Раса")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(character.race)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                
                // Класс
                if !character.characterClass.isEmpty {
                    HStack {
                        Text("Класс")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(character.characterClass)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                
                // Игрок
                if !character.playerName.isEmpty {
                    HStack {
                        Text("Игрок")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(character.playerName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                
                // Уровень
                HStack {
                    Text("Уровень")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(character.level)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                // Опыт
                HStack {
                    Text("Опыт")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(character.experience)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Character Viewer View

struct CharacterViewerView: View {
    let character: Character
    let store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditor = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок персонажа
                    CharacterHeaderView(character: character)
                    
                    // Основные характеристики
                    MainStatsView(character: character, store: store)
                    
                    // Характеристики и модификаторы
                    AbilityScoresViewerView(character: character)
                    
                    // Боевые характеристики
                    CombatStatsViewerView(character: character, store: store)
                    
                    // Спасброски и навыки
                    SkillsViewerView(character: character)
                    
                    // Черты характера
                    PersonalityViewerView(character: character)
                    
                    // Снаряжение и особенности
                    EquipmentViewerView(character: character)
                    
                    // Атаки
                    AttacksViewerView(character: character)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "#fceeda"),
                        Color(hex: "#fceeda").opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("\(character.name.isEmpty ? "Персонаж" : character.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Редактировать") {
                        showingEditor = true
                    }
                    .foregroundColor(.orange)
                }
            }
            .sheet(isPresented: $showingEditor) {
                CharacterEditorView(store: store, character: character)
            }
        }
    }
}




struct InfoCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Main Stats View

struct MainStatsView: View {
    let character: Character
    let store: CharacterStore
    @State private var showingHPEditor = false
    @State private var tempCurrentHP = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Основные характеристики")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                StatCard(title: "КЗ", value: "\(character.armorClass)", color: .blue)
                StatCard(title: "Инициатива", value: "\(character.initiative >= 0 ? "+" : "")\(character.initiative)", color: .green)
                StatCard(title: "Скорость", value: "\(character.speed) фт", color: .purple)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                // Редактируемые хиты
                Button(action: {
                    tempCurrentHP = character.currentHitPoints
                    showingHPEditor = true
                }) {
                    StatCard(title: "Хиты", value: "\(character.currentHitPoints)/\(character.maxHitPoints)", color: .red)
                }
                .buttonStyle(PlainButtonStyle())
                
                StatCard(title: "Бонус мастерства", value: "+\(character.proficiencyBonus)", color: .orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .alert("Изменить текущие хиты", isPresented: $showingHPEditor) {
            TextField("Текущие хиты", value: $tempCurrentHP, format: .number)
                .keyboardType(.numberPad)
            
            Button("Отмена", role: .cancel) { }
            
            Button("Сохранить") {
                var updatedCharacter = character
                updatedCharacter.currentHitPoints = max(0, min(tempCurrentHP, character.maxHitPoints))
                store.update(updatedCharacter)
            }
        } message: {
            Text("Введите новое значение текущих хитов (от 0 до \(character.maxHitPoints))")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Ability Scores Viewer

struct AbilityScoresViewerView: View {
    let character: Character
    
    var abilities: [(String, String, Int, Int)] {
        [
            ("Сила", "strength", character.strength, character.savingThrowModifier(for: "strength")),
            ("Ловкость", "dexterity", character.dexterity, character.savingThrowModifier(for: "dexterity")),
            ("Телосложение", "constitution", character.constitution, character.savingThrowModifier(for: "constitution")),
            ("Интеллект", "intelligence", character.intelligence, character.savingThrowModifier(for: "intelligence")),
            ("Мудрость", "wisdom", character.wisdom, character.savingThrowModifier(for: "wisdom")),
            ("Харизма", "charisma", character.charisma, character.savingThrowModifier(for: "charisma"))
        ]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Характеристики")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(abilities, id: \.0) { ability in
                    AbilityScoreViewerCard(
                        name: ability.0,
                        score: ability.2,
                        modifier: ability.3,
                        savingThrow: character.savingThrows[ability.1] ?? false
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct AbilityScoreViewerCard: View {
    let name: String
    let score: Int
    let modifier: Int
    let savingThrow: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("\(score)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            VStack(spacing: 2) {
                Text("\(modifier >= 0 ? "+" : "")\(modifier)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(modifier >= 0 ? .green : .red)
                
                if savingThrow {
                    Text("Спасбросок")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Combat Stats Viewer

struct CombatStatsViewerView: View {
    let character: Character
    let store: CharacterStore
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Боевые характеристики")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Кость хитов
                HStack {
                    Text("Кость хитов")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(character.hitDiceTotal)\(character.hitDiceType)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                
                Divider()
                
                // Вдохновение
                Button(action: {
                    var updatedCharacter = character
                    updatedCharacter.inspiration.toggle()
                    store.update(updatedCharacter)
                }) {
                    HStack {
                        Text("Вдохновение")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: character.inspiration ? "star.fill" : "star")
                            .foregroundColor(character.inspiration ? .yellow : .gray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                
                // Спасброски от смерти
                VStack(alignment: .leading, spacing: 8) {
                    Text("Спасброски от смерти")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("Успехи")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                ForEach(0..<3) { index in
                                    Button(action: {
                                        var updatedCharacter = character
                                        if index < updatedCharacter.deathSaveSuccesses {
                                            updatedCharacter.deathSaveSuccesses -= 1
                                        } else {
                                            updatedCharacter.deathSaveSuccesses = index + 1
                                        }
                                        store.update(updatedCharacter)
                                    }) {
                                        Circle()
                                            .fill(index < character.deathSaveSuccesses ? Color.green : Color.gray.opacity(0.3))
                                            .frame(width: 16, height: 16)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text("Провалы")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                ForEach(0..<3) { index in
                                    Button(action: {
                                        var updatedCharacter = character
                                        if index < updatedCharacter.deathSaveFailures {
                                            updatedCharacter.deathSaveFailures -= 1
                                        } else {
                                            updatedCharacter.deathSaveFailures = index + 1
                                        }
                                        store.update(updatedCharacter)
                                    }) {
                                        Circle()
                                            .fill(index < character.deathSaveFailures ? Color.red : Color.gray.opacity(0.3))
                                            .frame(width: 16, height: 16)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Skills Viewer

struct SkillsViewerView: View {
    let character: Character
    
    let skills = [
        ("Акробатика", "acrobatics", "Лов"),
        ("Анализ", "investigation", "Инт"),
        ("Атлетика", "athletics", "Сил"),
        ("Восприятие", "perception", "Муд"),
        ("Выживание", "survival", "Муд"),
        ("Выступление", "performance", "Хар"),
        ("Запугивание", "intimidation", "Хар"),
        ("История", "history", "Инт"),
        ("Ловкость рук", "sleight_of_hand", "Лов"),
        ("Магия", "arcana", "Инт"),
        ("Медицина", "medicine", "Муд"),
        ("Обман", "deception", "Хар"),
        ("Природа", "nature", "Инт"),
        ("Проницательность", "insight", "Муд"),
        ("Религия", "religion", "Инт"),
        ("Скрытность", "stealth", "Лов"),
        ("Убеждение", "persuasion", "Хар"),
        ("Уход за животными", "animal_handling", "Муд")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Навыки")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(skills, id: \.0) { skill in
                    SkillViewerCard(
                        name: skill.0,
                        ability: skill.2,
                        isProficient: character.skills[skill.1] ?? false,
                        modifier: character.skillModifier(for: skill.1)
                    )
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Пассивная мудрость (восприятие)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(character.passivePerception)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct SkillViewerCard: View {
    let name: String
    let ability: String
    let isProficient: Bool
    let modifier: Int
    
    var body: some View {
        HStack {
            Image(systemName: isProficient ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isProficient ? .green : .gray)
                .font(.caption)
            
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("(\(ability))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("\(modifier >= 0 ? "+" : "")\(modifier)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(modifier >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Personality Viewer

struct PersonalityViewerView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Черты характера")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                PersonalityCard(title: "Черты характера", text: character.personalityTraits)
                PersonalityCard(title: "Идеалы", text: character.ideals)
                PersonalityCard(title: "Привязанности", text: character.bonds)
                PersonalityCard(title: "Слабости", text: character.flaws)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct PersonalityCard: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(text.isEmpty ? "Не указано" : text)
                .font(.body)
                .foregroundColor(text.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Equipment Viewer

struct EquipmentViewerView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Снаряжение и особенности")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                EquipmentCard(title: "Снаряжение", text: character.equipment)
                EquipmentCard(title: "Особенности и черты", text: character.featuresAndTraits)
                EquipmentCard(title: "Прочие владения и языки", text: character.otherProficiencies)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct EquipmentCard: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(text.isEmpty ? "Не указано" : text)
                .font(.body)
                .foregroundColor(text.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Attacks Viewer

struct AttacksViewerView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Атаки и заклинания")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if character.attacks.isEmpty {
                Text("Атаки не указаны")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                VStack(spacing: 8) {
                    ForEach(character.attacks) { attack in
                        AttackViewerCard(attack: attack)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct AttackViewerCard: View {
    let attack: Attack
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(attack.name.isEmpty ? "Без названия" : attack.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(attack.attackBonus.isEmpty ? "Бонус не указан" : attack.attackBonus)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(attack.damageType.isEmpty ? "Тип не указан" : attack.damageType)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.orange)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Character Editor View

struct CharacterEditorView: View {
    let store: CharacterStore
    let character: Character?
    
    @Environment(\.dismiss) private var dismiss
    @State private var editedCharacter: Character
    
    init(store: CharacterStore, character: Character? = nil) {
        self.store = store
        self.character = character
        self._editedCharacter = State(initialValue: character ?? Character())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Основная информация
                    BasicInfoSection(character: $editedCharacter)
                    
                    // Боевые характеристики
                    CombatStatsSection(character: $editedCharacter)
                    
                    // Характеристики
                    AbilityScoresSection(character: $editedCharacter)
                    
                    // Спасброски и навыки
                    SkillsSection(character: $editedCharacter)
                    
                    // Черты характера
                    PersonalitySection(character: $editedCharacter)
                    
                    // Снаряжение и способности
                    EquipmentSection(character: $editedCharacter)
                    
                    // Атаки и заклинания
                    AttacksSection(character: $editedCharacter)
                }
                .padding()
            }
            .background(Color(hex: "#fceeda"))
            .navigationTitle(character == nil ? "Новый персонаж" : "Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveCharacter()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    @MainActor
    private func saveCharacter() {
        var characterToSave = editedCharacter
        characterToSave.dateModified = Date()
        
        if character == nil {
            characterToSave.dateCreated = Date()
            store.add(characterToSave)
        } else {
            store.update(characterToSave)
        }
        
        dismiss()
    }
}

// MARK: - Basic Info Section

struct BasicInfoSection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Основная информация")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Имя персонажа")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите имя", text: $character.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Имя игрока")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите имя игрока", text: $character.playerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Раса")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите расу", text: $character.race)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Класс")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите класс", text: $character.characterClass)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Предыстория")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите предысторию", text: $character.background)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Мировоззрение")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите мировоззрение", text: $character.alignment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Опыт")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите опыт", value: $character.experience, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Уровень")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите уровень", value: $character.level, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Combat Stats Section

struct CombatStatsSection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Боевые характеристики")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Класс брони (КЗ)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("КЗ", value: $character.armorClass, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Инициатива")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Инициатива", value: $character.initiative, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Скорость")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Скорость", value: $character.speed, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Бонус владения")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Бонус", value: $character.proficiencyBonus, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Максимум хитов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Макс. хиты", value: $character.maxHitPoints, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Текущие хиты")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Текущие хиты", value: $character.currentHitPoints, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Временные хиты")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Временные хиты", value: $character.temporaryHitPoints, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Кость хитов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("d6", text: $character.hitDiceType)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            // Вдохновение
            HStack {
                Toggle("Вдохновение", isOn: $character.inspiration)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                Spacer()
            }
            
            // Спасброски от смерти
            VStack(alignment: .leading, spacing: 8) {
                Text("Спасброски от смерти")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Успехи")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(index < character.deathSaveSuccesses ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: 20, height: 20)
                                    .onTapGesture {
                                        if index < character.deathSaveSuccesses {
                                            character.deathSaveSuccesses -= 1
                                        } else {
                                            character.deathSaveSuccesses = index + 1
                                        }
                                    }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Провалы")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(index < character.deathSaveFailures ? Color.red : Color.gray.opacity(0.3))
                                    .frame(width: 20, height: 20)
                                    .onTapGesture {
                                        if index < character.deathSaveFailures {
                                            character.deathSaveFailures -= 1
                                        } else {
                                            character.deathSaveFailures = index + 1
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Ability Scores Section

struct AbilityScoresSection: View {
    @Binding var character: Character
    
    let abilities = [
        ("Сила", "strength", \Character.strength),
        ("Ловкость", "dexterity", \Character.dexterity),
        ("Телосложение", "constitution", \Character.constitution),
        ("Интеллект", "intelligence", \Character.intelligence),
        ("Мудрость", "wisdom", \Character.wisdom),
        ("Харизма", "charisma", \Character.charisma)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Характеристики")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(abilities, id: \.0) { ability in
                    AbilityScoreCard(
                        name: ability.0,
                        score: binding(for: ability.2),
                        modifier: modifier(for: ability.2),
                        savingThrow: binding(for: ability.1, in: \.savingThrows),
                        savingThrowModifier: character.savingThrowModifier(for: ability.1)
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func binding(for keyPath: WritableKeyPath<Character, Int>) -> Binding<Int> {
        Binding(
            get: { character[keyPath: keyPath] },
            set: { character[keyPath: keyPath] = $0 }
        )
    }
    
    private func modifier(for keyPath: KeyPath<Character, Int>) -> Int {
        let score = character[keyPath: keyPath]
        return (score - 10) / 2
    }
    
    private func binding(for key: String, in keyPath: WritableKeyPath<Character, [String: Bool]>) -> Binding<Bool> {
        Binding(
            get: { character[keyPath: keyPath][key] ?? false },
            set: { character[keyPath: keyPath][key] = $0 }
        )
    }
}

struct AbilityScoreCard: View {
    let name: String
    @Binding var score: Int
    let modifier: Int
    @Binding var savingThrow: Bool
    let savingThrowModifier: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            TextField("10", value: $score, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 2) {
                Text("\(modifier >= 0 ? "+" : "")\(modifier)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(modifier >= 0 ? .green : .red)
                
                HStack {
                    Text("Спасбросок")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Toggle("", isOn: $savingThrow)
                        .toggleStyle(CheckboxToggleStyle())
                }
                
                if savingThrow {
                    Text("\(savingThrowModifier >= 0 ? "+" : "")\(savingThrowModifier)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .orange : .gray)
        }
    }
}

// MARK: - Skills Section

struct SkillsSection: View {
    @Binding var character: Character
    
    let skills = [
        ("Акробатика", "acrobatics", "Лов"),
        ("Анализ", "investigation", "Инт"),
        ("Атлетика", "athletics", "Сил"),
        ("Восприятие", "perception", "Муд"),
        ("Выживание", "survival", "Муд"),
        ("Выступление", "performance", "Хар"),
        ("Запугивание", "intimidation", "Хар"),
        ("История", "history", "Инт"),
        ("Ловкость рук", "sleight_of_hand", "Лов"),
        ("Магия", "arcana", "Инт"),
        ("Медицина", "medicine", "Муд"),
        ("Обман", "deception", "Хар"),
        ("Природа", "nature", "Инт"),
        ("Проницательность", "insight", "Муд"),
        ("Религия", "religion", "Инт"),
        ("Скрытность", "stealth", "Лов"),
        ("Убеждение", "persuasion", "Хар"),
        ("Уход за животными", "animal_handling", "Муд")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Навыки")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(skills, id: \.0) { skill in
                    HStack {
                        Toggle("", isOn: binding(for: skill.1, in: \.skills))
                            .toggleStyle(CheckboxToggleStyle())
                        
                        Text(skill.0)
                            .font(.caption)
                        
                        HStack(spacing: 4) {
                            Text("(\(skill.2))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("\(character.skillModifier(for: skill.1) >= 0 ? "+" : "")\(character.skillModifier(for: skill.1))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(character.skillModifier(for: skill.1) >= 0 ? .green : .red)
                        }
                        
                        Spacer()
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Пассивная мудрость (восприятие)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(character.passivePerception)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Прочие владения и языки")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Введите владения и языки", text: $character.otherProficiencies, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func binding(for key: String, in keyPath: WritableKeyPath<Character, [String: Bool]>) -> Binding<Bool> {
        Binding(
            get: { character[keyPath: keyPath][key] ?? false },
            set: { character[keyPath: keyPath][key] = $0 }
        )
    }
}

// MARK: - Personality Section

struct PersonalitySection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Черты характера")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Черты характера")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Опишите черты характера", text: $character.personalityTraits, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Идеалы")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Опишите идеалы", text: $character.ideals, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Привязанности")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Опишите привязанности", text: $character.bonds, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Слабости")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Опишите слабости", text: $character.flaws, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Equipment Section

struct EquipmentSection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Снаряжение и способности")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Снаряжение")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Опишите снаряжение", text: $character.equipment, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Умения и способности")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    TextField("Опишите умения и способности", text: $character.featuresAndTraits, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Attacks Section

struct AttacksSection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Атаки и заклинания")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(character.attacks.indices, id: \.self) { index in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Название")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Название атаки", text: $character.attacks[index].name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Бонус атаки")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("+5", text: $character.attacks[index].attackBonus)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Урон/Вид")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("1d6+3 рубящий", text: $character.attacks[index].damageType)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                
                Button("Добавить атаку") {
                    character.attacks.append(Attack())
                }
                .foregroundColor(.orange)
            }
            
            // Ячейки заклинаний
            VStack(alignment: .leading, spacing: 8) {
                Text("Ячейки заклинаний")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { level in
                        VStack(spacing: 4) {
                            Text("\(level) ур.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            TextField("0", value: $character.spellSlots[level], format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
