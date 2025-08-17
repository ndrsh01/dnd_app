import SwiftUI

enum CharacterDetailSection: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case abilities = "Характеристики"
    case combat = "Боевые характеристики"
    case skills = "Навыки"
    case spells = "Заклинания"
    case equipment = "Снаряжение"
    case treasure = "Сокровища"
    case personality = "Личность"
    case features = "Особенности"
    
    var icon: String {
        switch self {
        case .abilities: return "figure.strengthtraining.traditional"
        case .combat: return "shield.fill"
        case .skills: return "brain.head.profile"
        case .spells: return "sparkles"
        case .equipment: return "bag.fill"
        case .treasure: return "diamond.fill"
        case .personality: return "person.text.rectangle"
        case .features: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .abilities: return .blue
        case .combat: return .red
        case .skills: return .green
        case .spells: return .purple
        case .equipment: return .orange
        case .treasure: return .yellow
        case .personality: return .pink
        case .features: return .indigo
        }
    }
}
