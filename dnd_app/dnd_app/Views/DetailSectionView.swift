import SwiftUI

struct DetailSectionView: View {
    let character: Character
    let section: CharacterDetailSection
    @ObservedObject var store: CharacterStore
    @ObservedObject var compendiumStore: CompendiumStore
    @ObservedObject var classesStore: ClassesStore
    let onSaveChanges: ((Character) -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    switch section {
                    case .abilities:
                        AbilitiesDetailView(character: character, store: store, onSaveChanges: onSaveChanges)
                    case .combat:
                        CombatDetailView(character: character, store: store, onSaveChanges: onSaveChanges)
                    case .skills:
                SkillsDetailView(character: character, store: store, onSaveChanges: onSaveChanges)
                    case .spells:
                        ClassAbilitiesDetailView(character: character, compendiumStore: compendiumStore, classesStore: classesStore, onSaveChanges: onSaveChanges)
                    case .equipment:
                        EquipmentDetailView(character: character, store: store, onSaveChanges: onSaveChanges)
                    case .treasure:
                        TreasureDetailView(character: character, store: store, onSaveChanges: onSaveChanges)
                    case .personality:
                        PersonalityDetailView(character: character, store: store, onSaveChanges: onSaveChanges)
                    case .features:
                        FeaturesDetailView(character: character, store: store, onSaveChanges: onSaveChanges)
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.988, green: 0.933, blue: 0.855),
                        Color(red: 0.988, green: 0.933, blue: 0.855).opacity(0.9),
                        Color(red: 0.988, green: 0.933, blue: 0.855)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle(section.rawValue)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Abilities Detail View
struct AbilitiesDetailView: View {
    let character: Character
    @ObservedObject var store: CharacterStore
    let onSaveChanges: ((Character) -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            // Характеристики
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "figure.strengthtraining.traditional")
                            .foregroundColor(.orange)
                            .font(.title2)
                    .fontWeight(.semibold)
                    }
                    
                    Text("Характеристики")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    AbilityDetailCard(name: "Сила", score: character.strength, modifier: character.strengthModifier, icon: "figure.strengthtraining.traditional", color: .red)
                    AbilityDetailCard(name: "Ловкость", score: character.dexterity, modifier: character.dexterityModifier, icon: "figure.run", color: .green)
                    AbilityDetailCard(name: "Телосложение", score: character.constitution, modifier: character.constitutionModifier, icon: "heart.fill", color: .orange)
                    AbilityDetailCard(name: "Интеллект", score: character.intelligence, modifier: character.intelligenceModifier, icon: "brain.head.profile", color: .blue)
                    AbilityDetailCard(name: "Мудрость", score: character.wisdom, modifier: character.wisdomModifier, icon: "eye.fill", color: .purple)
                    AbilityDetailCard(name: "Харизма", score: character.charisma, modifier: character.charismaModifier, icon: "person.2.fill", color: .pink)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
            
            // Спасброски
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "shield.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    .fontWeight(.semibold)
                    }
                    
                    Text("Спасброски")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    ForEach(["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"], id: \.self) { ability in
                        SaveThrowRow(
                            ability: ability,
                            modifier: character.savingThrowModifier(for: ability),
                            isProficient: character.savingThrows[ability] == true,
                            onToggleProficiency: {
                                print("🔍 [SaveThrowRow] Переключаем владение для \(ability)")
                                var updatedCharacter = character
                                let currentValue = updatedCharacter.savingThrows[ability] ?? false
                                updatedCharacter.savingThrows[ability] = !currentValue
                                print("🔍 [SaveThrowRow] Новое значение для \(ability): \(updatedCharacter.savingThrows[ability] ?? false)")
                                store.update(updatedCharacter)
                                store.selectedCharacter = updatedCharacter
                                onSaveChanges?(updatedCharacter)
                            }
                        )
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
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
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            }
            
            Text(name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(modifier >= 0 ? .green : .red)
            
            Text("\(score)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 2)
        )
    }
}

struct SaveThrowRow: View {
    let ability: String
    let modifier: Int
    let isProficient: Bool
    let onToggleProficiency: () -> Void
    
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
        HStack(spacing: 16) {
            Text(abilityName)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            if isProficient {
                HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                    Text("Проф.")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            } else {
                // Пустая кликабельная область для добавления владения
                HStack {
                    Spacer()
                }
                .frame(minWidth: 50, minHeight: 20)
            }
            
            Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(modifier >= 0 ? .green : .red)
                .frame(minWidth: 40)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .onTapGesture(count: 2) {
            print("🔍 [SaveThrowRow] Двойной клик по всей строке для \(abilityName) (isProficient: \(isProficient))")
            onToggleProficiency()
        }
    }
}

// MARK: - Combat Detail View
struct CombatDetailView: View {
    let character: Character
    @ObservedObject var store: CharacterStore
    let onSaveChanges: ((Character) -> Void)?
    @State private var editingMaxHP = false
    @State private var editingCurrentHP = false
    @State private var editingTempHP = false
    @State private var editingHitDiceTotal = false
    @State private var editingHitDiceUsed = false
    @State private var editingHitDiceType = false
    @State private var newMaxHP = ""
    @State private var newCurrentHP = ""
    @State private var newTempHP = ""
    @State private var newHitDiceTotal = ""
    @State private var newHitDiceUsed = ""
    @State private var newHitDiceType = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Боевые характеристики
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                Text("Боевые характеристики")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    CombatDetailCard(title: "Класс брони", value: "\(character.armorClass)", icon: "shield.fill", color: .blue)
                    CombatDetailCard(title: "Инициатива", value: character.initiative >= 0 ? "+\(character.initiative)" : "\(character.initiative)", icon: "bolt.fill", color: .yellow)
                    CombatDetailCard(title: "Скорость", value: "\(character.effectiveSpeed) фт.", icon: "figure.walk", color: .green)
                    CombatDetailCard(title: "Пассивное восприятие", value: "\(character.passivePerception)", icon: "eye.fill", color: .purple)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
            
            // Хиты и кости
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                Text("Хиты и кости")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Максимум хитов:")
                        Spacer()
                        Button(action: {
                            newMaxHP = String(character.maxHitPoints)
                            editingMaxHP = true
                        }) {
                        Text("\(character.maxHitPoints)")
                            .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        Text("Текущие хиты:")
                        Spacer()
                        Button(action: {
                            newCurrentHP = String(character.currentHitPoints)
                            editingCurrentHP = true
                        }) {
                        Text("\(character.currentHitPoints)")
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                        }
                    }
                    
                        HStack {
                            Text("Временные хиты:")
                            Spacer()
                        Button(action: {
                            newTempHP = String(character.temporaryHitPoints)
                            editingTempHP = true
                        }) {
                            Text("\(character.temporaryHitPoints)")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        Text("Кости хитов (всего):")
                        Spacer()
                        Button(action: {
                            newHitDiceTotal = String(character.hitDiceTotal)
                            editingHitDiceTotal = true
                        }) {
                            Text("\(character.hitDiceTotal)")
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                    
                    HStack {
                        Text("Кости хитов (использовано):")
                        Spacer()
                        Button(action: {
                            newHitDiceUsed = String(character.hitDiceUsed)
                            editingHitDiceUsed = true
                        }) {
                            Text("\(character.hitDiceUsed)")
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    HStack {
                        Text("Тип костей хитов:")
                        Spacer()
                        Button(action: {
                            newHitDiceType = character.hitDiceType
                            editingHitDiceType = true
                        }) {
                            Text("d\(character.hitDiceType)")
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                    }
                    
                    HStack {
                        Text("Доступные кости:")
                        Spacer()
                        Text("\(character.hitDiceTotal - character.hitDiceUsed)d\(character.hitDiceType)")
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
            
            // Спасброски от смерти
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "skull")
                        .foregroundColor(.red)
                        .font(.title2)
                    Text("Спасброски от смерти")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("Успехи")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            ForEach(0..<3) { index in
                                Button(action: {
                                    if let selectedCharacter = store.selectedCharacter {
                                        var updatedCharacter = selectedCharacter
                                        if index < selectedCharacter.deathSaveSuccesses {
                                            updatedCharacter.deathSaveSuccesses -= 1
                                        } else {
                                            updatedCharacter.deathSaveSuccesses = index + 1
                                        }
                                        store.update(updatedCharacter)
                                        store.selectedCharacter = updatedCharacter
                                        onSaveChanges?(updatedCharacter)
                                    }
                                }) {
                                Circle()
                                        .fill(index < (store.selectedCharacter?.deathSaveSuccesses ?? character.deathSaveSuccesses) ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: 20, height: 20)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    VStack(spacing: 8) {
                        Text("Неудачи")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            ForEach(0..<3) { index in
                                Button(action: {
                                    if let selectedCharacter = store.selectedCharacter {
                                        var updatedCharacter = selectedCharacter
                                        if index < selectedCharacter.deathSaveFailures {
                                            updatedCharacter.deathSaveFailures -= 1
                                        } else {
                                            updatedCharacter.deathSaveFailures = index + 1
                                        }
                                        store.update(updatedCharacter)
                                        store.selectedCharacter = updatedCharacter
                                        onSaveChanges?(updatedCharacter)
                                    }
                                }) {
                                Circle()
                                        .fill(index < (store.selectedCharacter?.deathSaveFailures ?? character.deathSaveFailures) ? Color.red : Color.gray.opacity(0.3))
                                    .frame(width: 20, height: 20)
                            }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
            
            // Степени истощения
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                    Text("Степени истощения")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    ForEach(1...6, id: \.self) { level in
                        ExhaustionLevelCard(
                            level: level,
                            isActive: (store.selectedCharacter?.exhaustionLevel ?? character.exhaustionLevel) >= level,
                            onTap: {
                                if let selectedCharacter = store.selectedCharacter {
                                    let newLevel = selectedCharacter.exhaustionLevel >= level ? level - 1 : level
                                    store.updateCharacterExhaustion(selectedCharacter, newExhaustionLevel: newLevel)
                                }
                            }
                        )
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
        }
        .alert("Редактировать максимум хитов", isPresented: $editingMaxHP) {
            TextField("Максимум хитов", text: $newMaxHP)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if let newValue = Int(newMaxHP) {
                    var updatedCharacter = character
                    updatedCharacter.maxHitPoints = newValue
                    store.update(updatedCharacter)
                    store.selectedCharacter = updatedCharacter
                    onSaveChanges?(updatedCharacter)
                }
            }
        }
        .alert("Редактировать текущие хиты", isPresented: $editingCurrentHP) {
            TextField("Текущие хиты", text: $newCurrentHP)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if let newValue = Int(newCurrentHP) {
                    var updatedCharacter = character
                    updatedCharacter.currentHitPoints = newValue
                    store.update(updatedCharacter)
                    store.selectedCharacter = updatedCharacter
                    onSaveChanges?(updatedCharacter)
                }
            }
        }
        .alert("Редактировать временные хиты", isPresented: $editingTempHP) {
            TextField("Временные хиты", text: $newTempHP)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if let newValue = Int(newTempHP) {
                    var updatedCharacter = character
                    updatedCharacter.temporaryHitPoints = newValue
                    store.update(updatedCharacter)
                    store.selectedCharacter = updatedCharacter
                    onSaveChanges?(updatedCharacter)
                }
            }
        }
        .alert("Редактировать общее количество костей хитов", isPresented: $editingHitDiceTotal) {
            TextField("Общее количество костей", text: $newHitDiceTotal)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if let newValue = Int(newHitDiceTotal) {
                    var updatedCharacter = character
                    updatedCharacter.hitDiceTotal = newValue
                    store.update(updatedCharacter)
                    store.selectedCharacter = updatedCharacter
                    onSaveChanges?(updatedCharacter)
                }
            }
        }
        .alert("Редактировать использованные кости хитов", isPresented: $editingHitDiceUsed) {
            TextField("Использованные кости", text: $newHitDiceUsed)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if let newValue = Int(newHitDiceUsed) {
                    var updatedCharacter = character
                    updatedCharacter.hitDiceUsed = newValue
                    store.update(updatedCharacter)
                    store.selectedCharacter = updatedCharacter
                    onSaveChanges?(updatedCharacter)
                }
            }
        }
        .alert("Редактировать тип костей хитов", isPresented: $editingHitDiceType) {
            TextField("Тип костей (например: 6, 8, 10, 12, 20)", text: $newHitDiceType)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if !newHitDiceType.isEmpty {
                    var updatedCharacter = character
                    updatedCharacter.hitDiceType = newHitDiceType
                    store.update(updatedCharacter)
                    store.selectedCharacter = updatedCharacter
                    onSaveChanges?(updatedCharacter)
                }
            }
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

struct ExhaustionLevelCard: View {
    let level: Int
    let isActive: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Circle()
                .fill(isActive ? Color.orange : Color.gray.opacity(0.3))
                .frame(width: 20, height: 20)
                .overlay(
                    Text("\(level)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(isActive ? .white : .secondary)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Skills Detail View
struct SkillsDetailView: View {
    let character: Character
    @ObservedObject var store: CharacterStore
    let onSaveChanges: ((Character) -> Void)?
    
    private let skillNames = [
        "acrobatics": ("Акробатика", "ЛОВ"),
        "animal_handling": ("Уход за животными", "МДР"),
        "arcana": ("Магия", "ИНТ"),
        "athletics": ("Атлетика", "СИЛ"),
        "deception": ("Обман", "ХАР"),
        "history": ("История", "ИНТ"),
        "insight": ("Проницательность", "МДР"),
        "intimidation": ("Запугивание", "ХАР"),
        "investigation": ("Расследование", "ИНТ"),
        "medicine": ("Медицина", "МДР"),
        "nature": ("Природа", "ИНТ"),
        "perception": ("Восприятие", "МДР"),
        "performance": ("Выступление", "ХАР"),
        "persuasion": ("Убеждение", "ХАР"),
        "religion": ("Религия", "ИНТ"),
        "sleight_of_hand": ("Ловкость рук", "ЛОВ"),
        "stealth": ("Скрытность", "ЛОВ"),
        "survival": ("Выживание", "МДР")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.blue)
                            .font(.title2)
                    .fontWeight(.semibold)
                    }
                    
                    Text("Навыки")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 12) {
                    ForEach(skillNames.sorted(by: { $0.value.0 < $1.value.0 }), id: \.key) { skillKey, skillData in
                        SkillDetailRow(
                            skillKey: skillKey,
                            skillName: skillData.0,
                            ability: skillData.1,
                            modifier: character.skillModifier(for: skillKey),
                            isProficient: character.skills[skillKey] == true,
                            store: store,
                            onSaveChanges: onSaveChanges
                        )
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
        }
    }
}

struct SkillDetailRow: View {
    let skillKey: String
    let skillName: String
    let ability: String
    let modifier: Int
    let isProficient: Bool
    @ObservedObject var store: CharacterStore
    let onSaveChanges: ((Character) -> Void)?
    
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Text(skillName)
                .font(.subheadline)
                    .fontWeight(.semibold)
                .foregroundColor(.primary)
                
                Text("(\(ability))")
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isProficient {
                HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                    Text("Проф.")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            
            Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(modifier >= 0 ? .green : .red)
                .frame(minWidth: 40)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .onTapGesture(count: 2) {
            print("🔍 [SkillDetailRow] Двойной клик по навыку \(skillName)")
            toggleProficiency()
        }
    }
    
    private func toggleProficiency() {
        if let selectedCharacter = store.selectedCharacter {
            var updatedCharacter = selectedCharacter
            
            // Переключаем владение навыком
            updatedCharacter.skills[skillKey] = !isProficient
            
            store.update(updatedCharacter)
            store.selectedCharacter = updatedCharacter
            onSaveChanges?(updatedCharacter)
        }
    }
}

// MARK: - Class Abilities Detail View
struct ClassAbilitiesDetailView: View {
    let character: Character
    @ObservedObject var compendiumStore: CompendiumStore
    @ObservedObject var classesStore: ClassesStore
    let onSaveChanges: ((Character) -> Void)?
    @StateObject private var favorites = Favorites()
    @State private var favoriteSpells: [Spell] = []
    
    private var hasSpellcasters: Bool {
        // Check multi-class characters
        let multiClassHasSpellcasters = character.characterClasses.contains { characterClass in
            classesStore.isSpellcaster(slug: characterClass.slug)
        }
        
        // Check legacy single class characters
        let legacyHasSpellcasters = !character.characterClass.isEmpty && 
            classesStore.isSpellcaster(slug: getClassSlug(for: character.characterClass))
        
        return multiClassHasSpellcasters || legacyHasSpellcasters
    }
    

    
    private func getClassSlug(for className: String) -> String {
        switch className.lowercased() {
        case "варвар": return "barbarian"
        case "бард": return "bard"
        case "волшебник": return "wizard"
        case "друид": return "druid"
        case "жрец": return "cleric"
        case "колдун": return "warlock"
        case "монах": return "monk"
        case "паладин": return "paladin"
        case "плут": return "rogue"
        case "следопыт": return "ranger"
        case "чародей": return "sorcerer"
        default: return "fighter"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Class abilities for each class (new multi-class system)
            ForEach(character.characterClasses, id: \.id) { characterClass in
                ClassAbilitiesCard(
                    characterClass: characterClass,
                    classFeatures: character.classFeatures[characterClass.slug] ?? [:],
                    classTable: character.classProgression[characterClass.slug],
                    classesStore: classesStore,
                    onSaveChanges: onSaveChanges,
                    character: character
                )
            }
            
            // Legacy support for single class characters
            if character.characterClasses.isEmpty && !character.characterClass.isEmpty {
                let legacyClass = CharacterClass(
                    slug: getClassSlug(for: character.characterClass),
                    name: character.characterClass,
                    level: character.level,
                    subclass: character.subclass.isEmpty ? nil : character.subclass
                )
                
                ClassAbilitiesCard(
                    characterClass: legacyClass,
                    classFeatures: character.classFeatures[legacyClass.slug] ?? [:],
                    classTable: character.classProgression[legacyClass.slug],
                    classesStore: classesStore,
                    onSaveChanges: onSaveChanges,
                    character: character
                )
            }
            
            // Message if no classes at all
            if character.characterClasses.isEmpty && character.characterClass.isEmpty {
        VStack(spacing: 16) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                        
                        Text("Классы не настроены")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    Text("Перейдите в редактирование персонажа, чтобы добавить классы и увидеть их способности.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .stroke(LinearGradient(colors: [.orange.opacity(0.3), .orange.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                )
            }
            
            // Ячейки заклинаний (только для заклинательных классов с ячейками)
            if hasSpellcasters && character.spellSlots.values.contains(where: { $0 > 0 }) {
                // Заголовок ячеек заклинаний
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.purple)
                    }
                    
                Text("Ячейки заклинаний")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Ячейки заклинаний на всю ширину
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                    ForEach(1...9, id: \.self) { level in
                        if let slots = character.spellSlots[level], slots > 0 {
                            SpellSlotCard(level: level, slots: slots)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            
            // Заклинания (только если есть избранные)
            if !favoriteSpells.isEmpty {
                // Заголовок заклинаний
                    HStack {
                        ZStack {
                            Circle()
                            .fill(Color.blue.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                        Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                        }
                        
                    Text("Заклинания")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                    
                // Карточки заклинаний на всю ширину экрана
                    LazyVStack(spacing: 12) {
                        ForEach(favoriteSpells) { spell in
                            CompendiumSpellCard(spell: spell, favorites: favorites)
                                .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 16)
            }
            
            // This section is now handled by ClassAbilitiesCard components above

            // Список заклинаний персонажа (только для заклинательных классов)
            let availableSpells = character.spells.filter { spell in
                // Проверяем, есть ли ячейки для уровня заклинания
                guard spell.level > 0 else {
                    return false
                }
                let slots = character.spellSlots[spell.level]
                // Проверяем, что ячейки есть и они больше 0
                return slots != nil && slots! > 0
            }
            
            if hasSpellcasters, !availableSpells.isEmpty {
                // Заголовок заклинаний
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                        Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        
                    Text("Заклинания")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                    
                // Карточки заклинаний на всю ширину экрана
                    LazyVStack(spacing: 12) {
                    ForEach(availableSpells) { spell in
                            SpellCard(spell: spell)
                                .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 16)
            } else if favoriteSpells.isEmpty {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                    Image(systemName: "sparkles")
                            .font(.system(size: 28))
                        .foregroundColor(.gray)
                    }
                    
                    Text("Нет заклинаний")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Добавьте заклинания в редакторе персонажа или в избранное")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(.systemBackground),
                                    Color(.systemBackground).opacity(0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .stroke(
                            LinearGradient(
                                colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                )
            }
        }
        .onAppear {
            updateFavorites()
        }
        .onChange(of: favorites.spells.favorites) {
            updateFavorites()
        }
    }
    
    @MainActor
    private func updateFavorites() {
        favoriteSpells = compendiumStore.spells.filter { favorites.spells.isFavorite($0.name) }
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
    let spell: CharacterSpell
    
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
            
                            Text(spell.description.parseMarkdown())
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
    @ObservedObject var store: CharacterStore
    let onSaveChanges: ((Character) -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.brown.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "bag.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.brown)
                    }
                    
                Text("Снаряжение")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                RichTextField(
                    text: Binding(
                        get: { character.equipment },
                        set: { newValue in
                            var updatedCharacter = character
                            updatedCharacter.equipment = newValue
                            store.update(updatedCharacter)
                            store.selectedCharacter = updatedCharacter
                            onSaveChanges?(updatedCharacter)
                        }
                    ),
                    placeholder: "Снаряжение не указано"
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.brown.opacity(0.3), .brown.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
            
            // Атаки
            if !character.attacks.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "sword.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                        }
                        
                    Text("Атаки")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(character.attacks) { attack in
                            AttackCard(
                                attack: attack,
                                onUpdate: { updatedAttack in
                                    var updatedCharacter = character
                                    if let index = updatedCharacter.attacks.firstIndex(where: { $0.id == attack.id }) {
                                        updatedCharacter.attacks[index] = updatedAttack
                                        store.update(updatedCharacter)
                                        store.selectedCharacter = updatedCharacter
                                        onSaveChanges?(updatedCharacter)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(.systemBackground),
                                    Color(.systemBackground).opacity(0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .stroke(
                            LinearGradient(
                                colors: [.red.opacity(0.3), .red.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                )
            }
        }
    }
}

struct AttackCard: View {
    let attack: Attack
    let onUpdate: ((Attack) -> Void)?
    
    @State private var editingName = false
    @State private var editingBonus = false
    @State private var editingDamage = false
    @State private var newName = ""
    @State private var newBonus = ""
    @State private var newDamage = ""
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if editingName {
                    TextField("Название атаки", text: $newName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            var updatedAttack = attack
                            updatedAttack.name = newName
                            onUpdate?(updatedAttack)
                            editingName = false
                        }
                } else {
                    Text(attack.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .onLongPressGesture(minimumDuration: 0.5) {
                            newName = attack.name
                            editingName = true
                        }
                }
                
                if editingBonus {
                    HStack {
                        Text("Бонус атаки: ")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack {
                            TextField("Бонус", text: $newBonus)
                                .font(.subheadline)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                            
                            Button("Готово") {
                                var updatedAttack = attack
                                updatedAttack.attackBonus = newBonus
                                onUpdate?(updatedAttack)
                                editingBonus = false
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                } else {
                    Text("Бонус атаки: \(attack.attackBonus)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .onLongPressGesture(minimumDuration: 0.5) {
                            newBonus = String(attack.attackBonus)
                            editingBonus = true
                        }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Урон")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if editingDamage {
                    TextField("Урон", text: $newDamage)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            var updatedAttack = attack
                            updatedAttack.damageType = newDamage
                            onUpdate?(updatedAttack)
                            editingDamage = false
                        }
                } else {
                    Text(attack.damageType)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                        .onLongPressGesture(minimumDuration: 0.5) {
                            newDamage = attack.damageType
                            editingDamage = true
                        }
                }
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
    @ObservedObject var store: CharacterStore
    let onSaveChanges: ((Character) -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.yellow)
                    }
                    
                Text("Сокровища")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                RichTextField(
                    text: Binding(
                        get: { character.treasure },
                        set: { newValue in
                            var updatedCharacter = character
                            updatedCharacter.treasure = newValue
                            store.update(updatedCharacter)
                            store.selectedCharacter = updatedCharacter
                            onSaveChanges?(updatedCharacter)
                        }
                    ),
                    placeholder: "Сокровища не указаны"
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.yellow.opacity(0.3), .yellow.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.cyan.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.cyan)
                    }
                    
                Text("Особые ресурсы")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                RichTextField(
                    text: Binding(
                        get: { character.specialResources },
                        set: { newValue in
                            var updatedCharacter = character
                            updatedCharacter.specialResources = newValue
                            store.update(updatedCharacter)
                            store.selectedCharacter = updatedCharacter
                            onSaveChanges?(updatedCharacter)
                        }
                    ),
                    placeholder: "Особые ресурсы не указаны"
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.cyan.opacity(0.3), .cyan.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
        }
    }
}

// MARK: - Personality Detail View
struct PersonalityDetailView: View {
    let character: Character
    @ObservedObject var store: CharacterStore
    let onSaveChanges: ((Character) -> Void)?
    @StateObject private var favorites = Favorites()
    @StateObject private var compendiumStore = CompendiumStore()
    @State private var favoriteBackgrounds: [Background] = []
    
    var body: some View {
        VStack(spacing: 20) {
            // Избранные предыстории
            if !favoriteBackgrounds.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        
                        Text("Избранные предыстории")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(favoriteBackgrounds) { background in
                            BackgroundCard(background: background, favorites: favorites)
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(.systemBackground),
                                    Color(.systemBackground).opacity(0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                )
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.pink.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.pink)
                    }
                    
                Text("Черты характера")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                RichTextField(
                    text: Binding(
                        get: { character.personalityTraits },
                        set: { newValue in
                            var updatedCharacter = character
                            updatedCharacter.personalityTraits = newValue
                            store.update(updatedCharacter)
                            store.selectedCharacter = updatedCharacter
                            onSaveChanges?(updatedCharacter)
                        }
                    ),
                    placeholder: "Черты характера не указаны"
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.pink.opacity(0.3), .pink.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.purple)
                    }
                    
                Text("Идеалы")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                RichTextField(
                    text: Binding(
                        get: { character.ideals },
                        set: { newValue in
                            var updatedCharacter = character
                            updatedCharacter.ideals = newValue
                            store.update(updatedCharacter)
                            store.selectedCharacter = updatedCharacter
                            onSaveChanges?(updatedCharacter)
                        }
                    ),
                    placeholder: "Идеалы не указаны"
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "link")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    
                Text("Привязанности")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                RichTextField(
                    text: Binding(
                        get: { character.bonds },
                        set: { newValue in
                            var updatedCharacter = character
                            updatedCharacter.bonds = newValue
                            store.update(updatedCharacter)
                            store.selectedCharacter = updatedCharacter
                            onSaveChanges?(updatedCharacter)
                        }
                    ),
                    placeholder: "Привязанности не указаны"
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                    }
                    
                Text("Слабости")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                RichTextField(
                    text: Binding(
                        get: { character.flaws },
                        set: { newValue in
                            var updatedCharacter = character
                            updatedCharacter.flaws = newValue
                            store.update(updatedCharacter)
                            store.selectedCharacter = updatedCharacter
                            onSaveChanges?(updatedCharacter)
                        }
                    ),
                    placeholder: "Слабости не указаны"
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.red.opacity(0.3), .red.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
        }
        .onAppear {
            updateFavorites()
        }
        .onChange(of: favorites.backgrounds.favorites) {
            updateFavorites()
        }
    }
    
    @MainActor
    private func updateFavorites() {
        favoriteBackgrounds = compendiumStore.backgrounds.filter { favorites.backgrounds.isFavorite($0.name) }
    }
}

// MARK: - Features Detail View
struct FeaturesDetailView: View {
    let character: Character
    @ObservedObject var store: CharacterStore
    let onSaveChanges: ((Character) -> Void)?
    @StateObject private var favorites = Favorites()
    @StateObject private var compendiumStore = CompendiumStore()
    @State private var favoriteFeats: [Feat] = []
    
    var body: some View {
        VStack(spacing: 20) {
            // Избранные черты
            if !favoriteFeats.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                        
                        Text("Избранные черты")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(favoriteFeats) { feat in
                            FeatCard(feat: feat, favorites: favorites)
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(.systemBackground),
                                    Color(.systemBackground).opacity(0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                )
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "star.circle")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    
                Text("Умения и способности")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                RichTextField(
                    text: Binding(
                        get: { character.featuresAndTraits },
                        set: { newValue in
                            var updatedCharacter = character
                            updatedCharacter.featuresAndTraits = newValue
                            store.update(updatedCharacter)
                            store.selectedCharacter = updatedCharacter
                            onSaveChanges?(updatedCharacter)
                        }
                    ),
                    placeholder: "Умения и способности не указаны"
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.green.opacity(0.3), .green.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    
                    Text("Прочие владения")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                RichTextField(
                    text: Binding(
                        get: { character.otherProficiencies },
                        set: { newValue in
                            var updatedCharacter = character
                            updatedCharacter.otherProficiencies = newValue
                            store.selectedCharacter = updatedCharacter
                        }
                    ),
                    placeholder: "Прочие владения не указаны"
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "globe")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.purple)
                    }
                    
                Text("Языки")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                RichTextField(
                    text: Binding(
                        get: { character.languages },
                        set: { newValue in
                            var updatedCharacter = character
                            updatedCharacter.languages = newValue
                            store.selectedCharacter = updatedCharacter
                        }
                    ),
                    placeholder: "Языки не указаны"
                )
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.systemBackground).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
        }
        .onAppear {
            updateFavorites()
        }
        .onChange(of: favorites.feats.favorites) {
            updateFavorites()
        }
    }
    
    @MainActor
    private func updateFavorites() {
        favoriteFeats = compendiumStore.feats.filter { favorites.feats.isFavorite($0.name) }
    }
}



// MARK: - Background Card for DetailSectionView



struct BackgroundCard: View {
    let background: Background
    @ObservedObject var favorites: Favorites
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with name and expand button
            HStack {
                Text(background.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            favorites.backgrounds.toggle(background.name)
                        }
                    }) {
                        Image(systemName: favorites.backgrounds.isFavorite(background.name) ? "heart.fill" : "heart")
                            .foregroundColor(favorites.backgrounds.isFavorite(background.name) ? .red : .gray)
                            .font(.title2)
                            .scaleEffect(favorites.backgrounds.isFavorite(background.name) ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: favorites.backgrounds.isFavorite(background.name))
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.orange)
                            .font(.title3)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Expanded details
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Характеристики
                    if !background.characteristics.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text(background.characteristics.parseMarkdown())
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                    
                    // Черта
                    if !background.trait.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.purple)
                                .font(.caption)
                            Text(background.trait.parseMarkdown())
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                    
                    // Навыки
                    if !background.skills.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text(background.skills.parseMarkdown())
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                    
                    // Инструменты
                    if !background.tools.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "wrench.and.screwdriver.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text(background.tools.parseMarkdown())
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                    
                    // Снаряжение
                    if !background.equipment.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "bag.fill")
                                .foregroundColor(.brown)
                                .font(.caption)
                            Text(background.equipment.parseMarkdown())
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                    
                    // Описание
                    if !background.description.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "text.quote")
                                .foregroundColor(.indigo)
                                .font(.caption)
                            Text(background.description.parseMarkdown())
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
