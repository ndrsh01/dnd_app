import Foundation

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
