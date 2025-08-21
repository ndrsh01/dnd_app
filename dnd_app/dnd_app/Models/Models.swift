import Foundation

// MARK: - Cacheable Protocol
protocol Cacheable {
    /// Key used to store the value in the cache.
    var cacheKey: String { get }
    /// Lifetime of the cached value in seconds. `0` means the value never expires.
    var cacheExpiration: TimeInterval { get }
}

// MARK: - Spell Models
struct Spell: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let level: Int
    let school: String
    let classes: [String]
    let subclasses: [String]
    let concentration: Bool
    let ritual: Bool
    let castingTime: String
    let range: String
    let components: String
    let duration: String
    let description: String
    let improvements: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Название"
        case level = "Уровень"
        case school = "Школа"
        case classes = "Классы"
        case subclasses = "Подклассы"
        case concentration = "Концентрация"
        case ritual = "Ритуал"
        case castingTime = "Время сотворения"
        case range = "Дистанция"
        case components = "Компоненты"
        case duration = "Длительность"
        case description = "Описание"
        case improvements = "Улучшения"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        
        // Парсим уровень
        let levelString = try container.decode(String.self, forKey: .level)
        level = Int(levelString) ?? 0
        
        school = try container.decode(String.self, forKey: .school)
        
        // Парсим классы
        let classesString = try container.decode(String.self, forKey: .classes)
        classes = classesString.isEmpty ? [] : classesString.components(separatedBy: ", ")
        
        // Парсим подклассы
        let subclassesString = try container.decode(String.self, forKey: .subclasses)
        subclasses = subclassesString.isEmpty ? [] : subclassesString.components(separatedBy: ", ")
        
        concentration = try container.decode(Bool.self, forKey: .concentration)
        ritual = try container.decode(Bool.self, forKey: .ritual)
        castingTime = try container.decode(String.self, forKey: .castingTime)
        range = try container.decode(String.self, forKey: .range)
        components = try container.decode(String.self, forKey: .components)
        duration = try container.decode(String.self, forKey: .duration)
        description = try container.decode(String.self, forKey: .description)
        improvements = try container.decode(String.self, forKey: .improvements)
    }
    
    init(name: String, level: Int, school: String, classes: [String], subclasses: [String] = [], concentration: Bool, ritual: Bool, castingTime: String, range: String, components: String, duration: String, description: String, improvements: String = "") {
        self.name = name
        self.level = level
        self.school = school
        self.classes = classes
        self.subclasses = subclasses
        self.concentration = concentration
        self.ritual = ritual
        self.castingTime = castingTime
        self.range = range
        self.components = components
        self.duration = duration
        self.description = description
        self.improvements = improvements
    }
}

// MARK: - Cacheable Conformance
/// Example usage of the `Cacheable` protocol. Spells will live in the
/// cache for one hour before being invalidated.
extension Spell: Cacheable {
    var cacheKey: String { "spells" }
    var cacheExpiration: TimeInterval { 60 * 60 } // 1 hour
}

// MARK: - Background Models
struct Background: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let characteristics: String
    let trait: String
    let skills: String
    let tools: String
    let equipment: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Название"
        case characteristics = "Характеристики"
        case trait = "Черта"
        case skills = "Навыки"
        case tools = "Инструменты"
        case equipment = "Снаряжение"
        case description = "Описание"
    }
}

// MARK: - Feat Models
struct Feat: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let category: String
    let requirements: String
    let abilityIncrease: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Название"
        case category = "Категория"
        case requirements = "Требования"
        case abilityIncrease = "Повышение характеристики"
        case description = "Описание"
    }
}

// MARK: - Filter Models
struct SpellFilters: Codable {
    var searchText: String = ""
    var selectedLevels: Set<Int> = []
    var selectedSchools: Set<String> = []
    var selectedClasses: Set<String> = []
    var concentrationOnly: Bool = false
    var ritualOnly: Bool = false
    
    var isActive: Bool {
        !searchText.isEmpty || !selectedLevels.isEmpty || !selectedSchools.isEmpty || 
        !selectedClasses.isEmpty || concentrationOnly || ritualOnly
    }
    
    mutating func clear() {
        searchText = ""
        selectedLevels.removeAll()
        selectedSchools.removeAll()
        selectedClasses.removeAll()
        concentrationOnly = false
        ritualOnly = false
    }
    
    mutating func toggleLevelFilter(_ level: Int) {
        if selectedLevels.contains(level) {
            selectedLevels.remove(level)
        } else {
            selectedLevels.insert(level)
        }
    }
    
    mutating func toggleSchoolFilter(_ school: String) {
        if selectedSchools.contains(school) {
            selectedSchools.remove(school)
        } else {
            selectedSchools.insert(school)
        }
    }
    
    mutating func toggleClassFilter(_ className: String) {
        if selectedClasses.contains(className) {
            selectedClasses.remove(className)
        } else {
            selectedClasses.insert(className)
        }
    }
}

struct BackgroundFilters: Codable {
    var searchText: String = ""
    
    var isActive: Bool {
        !searchText.isEmpty
    }
    
    mutating func clear() {
        searchText = ""
    }
}

struct FeatFilters: Codable {
    var searchText: String = ""
    var selectedCategories: Set<String> = []
    
    var isActive: Bool {
        !searchText.isEmpty || !selectedCategories.isEmpty
    }
    
    mutating func clear() {
        searchText = ""
        selectedCategories.removeAll()
    }
    
    mutating func toggleCategoryFilter(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

// MARK: - Monster Models

struct Monster: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let slug: String
    let url: String
    let image: String?
    let subtitle: String
    let size: String
    let type: String
    let alignment: String
    let ac: ArmorClass
    let hp: HitPoints
    let speed: Speed
    let saves: [String: String]
    let skills: [String: String]
    let damageResistances: String
    let damageImmunities: String
    let damageVulnerabilities: String
    let conditionImmunities: String
    let senses: String
    let languages: String
    let challenge: Challenge
    let abilities: Abilities
    let blocks: Blocks
    
    enum CodingKeys: String, CodingKey {
        case name, slug, url, image, subtitle, size, type, alignment, ac, hp, speed, saves, skills
        case damageResistances = "damage_resistances"
        case damageImmunities = "damage_immunities"
        case damageVulnerabilities = "damage_vulnerabilities"
        case conditionImmunities = "condition_immunities"
        case senses, languages, challenge, abilities, blocks
    }
}

struct ArmorClass: Codable, Equatable {
    let ac: Int
    let notes: String
}

struct HitPoints: Codable, Equatable {
    let hp: Int
    let formula: String
}

struct Speed: Codable, Equatable {
    let walk: String?
    let fly: String?
    let swim: String?
    let climb: String?
    let burrow: String?
    
    var displayString: String {
        var speeds: [String] = []
        if let walk = walk { speeds.append("ходьба \(walk)") }
        if let fly = fly { speeds.append("полёт \(fly)") }
        if let swim = swim { speeds.append("плавание \(swim)") }
        if let climb = climb { speeds.append("лазание \(climb)") }
        if let burrow = burrow { speeds.append("рытьё \(burrow)") }
        return speeds.joined(separator: ", ")
    }
}

struct Challenge: Codable, Equatable {
    let cr: String
    let xp: Int
    let raw: String
    let proficiencyBonus: String
    let special: String
    
    enum CodingKeys: String, CodingKey {
        case cr, xp, raw, special
        case proficiencyBonus = "proficiency_bonus"
    }
}

struct Abilities: Codable, Equatable {
    let str: AbilityScore
    let dex: AbilityScore
    let con: AbilityScore
    let int: AbilityScore
    let wis: AbilityScore
    let cha: AbilityScore
}

struct AbilityScore: Codable, Equatable {
    let score: Int
    let mod: Int
    
    var modifierString: String {
        return mod >= 0 ? "+\(mod)" : "\(mod)"
    }
}

struct Blocks: Codable, Equatable {
    let actions: [Action]?
    let legendaryActions: [Action]?
    let reactions: [Action]?
    let traits: [Action]?
    
    enum CodingKeys: String, CodingKey {
        case actions, traits, reactions
        case legendaryActions = "legendary_actions"
    }
}

struct Action: Codable, Equatable {
    let name: String
    let text: String
}

// MARK: - Monster Filters

struct MonsterFilters: Codable {
    var searchText: String
    var selectedSizes: [String]
    var selectedTypes: [String]
    var selectedCRs: [String]
    var selectedAlignments: [String]
    
    static let sizes = ["крошечное", "маленькое", "средний", "большой", "огромный", "гигантский"]
    static let types = ["аберрация", "зверь", "небожитель", "дракон", "фея", "элементаль", "великан", "гуманоид", "монстр", "животное", "растение", "нежить"]
    static let challengeRatings = ["0", "1/8", "1/4", "1/2", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30"]
    static let alignments = ["законно-добрый", "нейтрально-добрый", "хаотично-добрый", "законно-нейтральный", "нейтральный", "хаотично-нейтральный", "законно-злой", "нейтрально-злой", "хаотично-злой", "неопределённый"]
    
    init() {
        self.searchText = ""
        self.selectedSizes = []
        self.selectedTypes = []
        self.selectedCRs = []
        self.selectedAlignments = []
    }
}
