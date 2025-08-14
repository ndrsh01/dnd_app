import Foundation

// MARK: - Spell Models
struct Spell: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let level: Int
    let school: String
    let classes: [String]
    let actionType: String?
    let concentration: Bool
    let ritual: Bool
    let castingTime: String?
    let range: String?
    let components: [String]?
    let duration: String?
    let description: String
    let material: String?
    let cantripUpgrade: String?
    
    enum CodingKeys: String, CodingKey {
        case name, level, school, classes, actionType, concentration, ritual, castingTime, range, components, duration, description, material, cantripUpgrade
    }
    
    init(name: String, level: Int, school: String, classes: [String], actionType: String? = nil, concentration: Bool, ritual: Bool, castingTime: String? = nil, range: String? = nil, components: [String]? = nil, duration: String? = nil, description: String, material: String? = nil, cantripUpgrade: String? = nil) {
        self.name = name
        self.level = level
        self.school = school
        self.classes = classes
        self.actionType = actionType
        self.concentration = concentration
        self.ritual = ritual
        self.castingTime = castingTime
        self.range = range
        self.components = components
        self.duration = duration
        self.description = description
        self.material = material
        self.cantripUpgrade = cantripUpgrade
    }
}

// MARK: - Feat Models
struct Feat: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let description: String
    let category: String
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
