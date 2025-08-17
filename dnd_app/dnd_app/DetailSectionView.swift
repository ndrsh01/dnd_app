import SwiftUI

struct DetailSectionView: View {
    let character: Character
    let section: CompactCharacterSheetView.DetailSection
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    switch section {
                    case .abilities:
                        AbilitiesDetailView(character: character)
                    case .combat:
                        CombatDetailView(character: character)
                    case .skills:
                        SkillsDetailView(character: character)
                    case .spells:
                        SpellsDetailView(character: character)
                    case .equipment:
                        EquipmentDetailView(character: character)
                    case .treasure:
                        TreasureDetailView(character: character)
                    case .personality:
                        PersonalityDetailView(character: character)
                    case .features:
                        FeaturesDetailView(character: character)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(section.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Abilities Detail View
struct AbilitiesDetailView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            // Характеристики
            VStack(alignment: .leading, spacing: 12) {
                Text("Характеристики")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    AbilityDetailCard(name: "Сила", score: character.strength, modifier: character.strengthModifier, icon: "figure.strengthtraining.traditional", color: .red)
                    AbilityDetailCard(name: "Ловкость", score: character.dexterity, modifier: character.dexterityModifier, icon: "figure.run", color: .green)
                    AbilityDetailCard(name: "Телосложение", score: character.constitution, modifier: character.constitutionModifier, icon: "heart.fill", color: .orange)
                    AbilityDetailCard(name: "Интеллект", score: character.intelligence, modifier: character.intelligenceModifier, icon: "brain.head.profile", color: .blue)
                    AbilityDetailCard(name: "Мудрость", score: character.wisdom, modifier: character.wisdomModifier, icon: "eye.fill", color: .purple)
                    AbilityDetailCard(name: "Харизма", score: character.charisma, modifier: character.charismaModifier, icon: "person.2.fill", color: .pink)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // Спасброски
            VStack(alignment: .leading, spacing: 12) {
                Text("Спасброски")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 8) {
                    ForEach(["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"], id: \.self) { ability in
                        SaveThrowRow(
                            ability: ability,
                            modifier: character.savingThrowModifier(for: ability),
                            isProficient: character.savingThrows[ability] == true
                        )
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}

struct AbilityDetailCard: View {
    let name: String
    let score: Int
    let modifier: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text("\(score)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(modifier >= 0 ? .green : .red)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct SaveThrowRow: View {
    let ability: String
    let modifier: Int
    let isProficient: Bool
    
    private var abilityName: String {
        switch ability {
        case "strength": return "Сила"
        case "dexterity": return "Ловкость"
        case "constitution": return "Телосложение"
        case "intelligence": return "Интеллект"
        case "wisdom": return "Мудрость"
        case "charisma": return "Харизма"
        default: return ability
        }
    }
    
    var body: some View {
        HStack {
            Text(abilityName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            if isProficient {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
            
            Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(modifier >= 0 ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Combat Detail View
struct CombatDetailView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            // Боевые характеристики
            VStack(alignment: .leading, spacing: 12) {
                Text("Боевые характеристики")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    CombatDetailCard(title: "Класс брони", value: "\(character.armorClass)", icon: "shield.fill", color: .blue)
                    CombatDetailCard(title: "Инициатива", value: character.initiative >= 0 ? "+\(character.initiative)" : "\(character.initiative)", icon: "bolt.fill", color: .yellow)
                    CombatDetailCard(title: "Скорость", value: "\(character.speed) фт.", icon: "figure.walk", color: .green)
                    CombatDetailCard(title: "Пассивное восприятие", value: "\(character.passivePerception)", icon: "eye.fill", color: .purple)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // Хиты и кости
            VStack(alignment: .leading, spacing: 12) {
                Text("Хиты и кости")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Максимум хитов:")
                        Spacer()
                        Text("\(character.maxHitPoints)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Текущие хиты:")
                        Spacer()
                        Text("\(character.currentHitPoints)")
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                    
                    if character.temporaryHitPoints > 0 {
                        HStack {
                            Text("Временные хиты:")
                            Spacer()
                            Text("\(character.temporaryHitPoints)")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        Text("Кости хитов:")
                        Spacer()
                        Text("\(character.hitDiceTotal - character.hitDiceUsed)d\(character.hitDiceType)")
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // Смертельные спасброски
            VStack(alignment: .leading, spacing: 12) {
                Text("Смертельные спасброски")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("Успехи")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(index < character.deathSaveSuccesses ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                    
                    VStack(spacing: 8) {
                        Text("Неудачи")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(index < character.deathSaveFailures ? Color.red : Color.gray.opacity(0.3))
                                    .frame(width: 20, height: 20)
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
}

struct CombatDetailCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Skills Detail View
struct SkillsDetailView: View {
    let character: Character
    
    private let skillNames = [
        "acrobatics": "Акробатика",
        "animal_handling": "Уход за животными",
        "arcana": "Магия",
        "athletics": "Атлетика",
        "deception": "Обман",
        "history": "История",
        "insight": "Проницательность",
        "intimidation": "Запугивание",
        "investigation": "Расследование",
        "medicine": "Медицина",
        "nature": "Природа",
        "perception": "Восприятие",
        "performance": "Выступление",
        "persuasion": "Убеждение",
        "religion": "Религия",
        "sleight_of_hand": "Ловкость рук",
        "stealth": "Скрытность",
        "survival": "Выживание"
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Навыки")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 8) {
                    ForEach(Array(skillNames.keys.sorted()), id: \.self) { skillKey in
                        if let skillName = skillNames[skillKey] {
                            SkillDetailRow(
                                name: skillName,
                                modifier: character.skillModifier(for: skillKey),
                                isProficient: character.skills[skillKey] == true
                            )
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}

struct SkillDetailRow: View {
    let name: String
    let modifier: Int
    let isProficient: Bool
    
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            if isProficient {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
            
            Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(modifier >= 0 ? .green : .red)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Spells Detail View
struct SpellsDetailView: View {
    let character: Character
    @StateObject private var favorites = FavoriteSpellsManager()
    @StateObject private var store = CompendiumStore()
    
    var favoriteSpells: [Spell] {
        favorites.getFavoriteSpells(from: store.spells)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Ячейки заклинаний
            VStack(alignment: .leading, spacing: 12) {
                Text("Ячейки заклинаний")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                    ForEach(1...5, id: \.self) { level in
                        SpellSlotCard(level: level, slots: character.spellSlots[level] ?? 0)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // Список заклинаний
            if !character.spells.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Заклинания")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ForEach(character.spells) { spell in
                            SpellCard(spell: spell)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("Нет заклинаний")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Добавьте заклинания в редакторе персонажа")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            
            // Избранные заклинания
            if !favoriteSpells.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Избранные заклинания")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ForEach(favoriteSpells) { spell in
                            CompendiumSpellCard(spell: spell, favorites: favorites)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
    }
}

struct SpellSlotCard: View {
    let level: Int
    let slots: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(level) ур.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(slots)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.purple)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
        )
    }
}

struct SpellCard: View {
    let spell: Spell
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(spell.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if spell.isPrepared {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            HStack {
                Text("Уровень \(spell.level)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(spell.school)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(spell.description)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(3)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Equipment Detail View
struct EquipmentDetailView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Снаряжение")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if !character.equipment.isEmpty {
                    Text(character.equipment)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } else {
                    Text("Снаряжение не указано")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // Атаки
            if !character.attacks.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Атаки")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ForEach(character.attacks) { attack in
                            AttackCard(attack: attack)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
    }
}

struct AttackCard: View {
    let attack: Attack
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(attack.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Бонус атаки: \(attack.attackBonus)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Урон")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(attack.damageType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Treasure Detail View
struct TreasureDetailView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Сокровища")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if !character.treasure.isEmpty {
                    Text(character.treasure)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } else {
                    Text("Сокровища не указаны")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Особые ресурсы")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if !character.specialResources.isEmpty {
                    Text(character.specialResources)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } else {
                    Text("Особые ресурсы не указаны")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}

// MARK: - Personality Detail View
struct PersonalityDetailView: View {
    let character: Character
    @StateObject private var favorites = FavoriteSpellsManager()
    @StateObject private var store = CompendiumStore()
    
    var favoriteBackgrounds: [Background] {
        favorites.getFavoriteBackgrounds(from: store.backgrounds)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Черты характера")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if !character.personalityTraits.isEmpty {
                    Text(character.personalityTraits)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } else {
                    Text("Черты характера не указаны")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Идеалы")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if !character.ideals.isEmpty {
                    Text(character.ideals)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } else {
                    Text("Идеалы не указаны")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Привязанности")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if !character.bonds.isEmpty {
                    Text(character.bonds)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } else {
                    Text("Привязанности не указаны")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Слабости")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if !character.flaws.isEmpty {
                    Text(character.flaws)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } else {
                    Text("Слабости не указаны")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // Избранные предыстории
            if !favoriteBackgrounds.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Избранные предыстории")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ForEach(favoriteBackgrounds) { background in
                            BackgroundCard(background: background, favorites: favorites)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Features Detail View
struct FeaturesDetailView: View {
    let character: Character
    @StateObject private var favorites = FavoriteSpellsManager()
    @StateObject private var store = CompendiumStore()
    
    var favoriteFeats: [Feat] {
        favorites.getFavoriteFeats(from: store.feats)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Умения и способности")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if !character.featuresAndTraits.isEmpty {
                    Text(character.featuresAndTraits)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } else {
                    Text("Умения и способности не указаны")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Прочие владения и языки")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if !character.otherProficiencies.isEmpty {
                    Text(character.otherProficiencies)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } else {
                    Text("Прочие владения и языки не указаны")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Языки")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if !character.languages.isEmpty {
                    Text(character.languages)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                } else {
                    Text("Языки не указаны")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // Избранные черты
            if !favoriteFeats.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Избранные черты")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ForEach(favoriteFeats) { feat in
                            FeatCard(feat: feat, favorites: favorites)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
    }
}


