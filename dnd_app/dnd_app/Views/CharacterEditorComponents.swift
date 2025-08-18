import SwiftUI

// MARK: - Section Components for Character Editor

struct BasicInfoSection: View {
    @Binding var character: Character
    @StateObject private var classesStore = ClassesStore()
    @StateObject private var compendiumStore = CompendiumStore()
    @State private var showingClassPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.orange.opacity(0.2)).frame(width: 28, height: 28)
                    Image(systemName: "person.circle").foregroundColor(.orange).font(.caption)
                }
                Text("Основная информация").font(.headline).fontWeight(.semibold)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
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
                    Text("Класс (устаревшее)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите класс", text: $character.characterClass)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(true)
                        .opacity(0.6)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Предыстория")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("Предыстория", selection: $character.background) {
                        Text("Выберите предысторию").tag("")
                        ForEach(compendiumStore.backgrounds, id: \.name) { background in
                            Text(background.name).tag(background.name)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.primary)
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
                    HStack(spacing: 8) {
                        Button(action: {
                            if character.level > 1 {
                                character.level -= 1
                                character.proficiencyBonus = (character.level - 1) / 4 + 2
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                        
                        Text("\(character.level)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(minWidth: 40)
                        
                        Button(action: {
                            if character.level < 20 {
                                character.level += 1
                                character.proficiencyBonus = (character.level - 1) / 4 + 2
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            // Classes section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Классы")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("+ Добавить класс") {
                        showingClassPicker = true
                    }
                    .foregroundColor(.blue)
                    .font(.caption)
                }
                
                // Existing classes
                if character.characterClasses.isEmpty {
                    Text("Выберите класс для персонажа")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                } else {
                    ForEach(character.characterClasses.indices, id: \.self) { index in
                        ImprovedClassCard(
                            characterClass: $character.characterClasses[index],
                            availableClasses: Array(classesStore.classesBySlug.values),
                            onDelete: { 
                                character.characterClasses.remove(at: index)
                            }
                        )
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .stroke(LinearGradient(colors: [.orange.opacity(0.3), .orange.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .sheet(isPresented: $showingClassPicker) {
            ClassPickerView(
                availableClasses: Array(classesStore.classesBySlug.values),
                onClassSelected: { gameClass in
                    let newCharacterClass = CharacterClass(
                        slug: gameClass.slug,
                        name: gameClass.name,
                        level: 1,
                        subclass: nil
                    )
                    character.characterClasses.append(newCharacterClass)
                    showingClassPicker = false
                }
            )
        }
    }
}

struct CombatStatsSection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.red.opacity(0.2)).frame(width: 28, height: 28)
                    Image(systemName: "shield.fill").foregroundColor(.red).font(.caption)
                }
                Text("Боевые характеристики").font(.headline).fontWeight(.semibold)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Класс брони (КЗ)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("КЗ", value: $character.armorClass, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Максимум хитов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        Button(action: {
                            if character.maxHitPoints > 1 {
                                character.maxHitPoints -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                        
                        Text("\(character.maxHitPoints)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(minWidth: 60)
                        
                        Button(action: {
                            if character.maxHitPoints < 999 {
                                character.maxHitPoints += 1
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Текущие хиты")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        Button(action: {
                            if character.currentHitPoints > 0 {
                                character.currentHitPoints -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                        
                        Text("\(character.currentHitPoints)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(minWidth: 60)
                        
                        Button(action: {
                            if character.currentHitPoints < character.maxHitPoints {
                                character.currentHitPoints += 1
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.green)
                        }
                    }
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
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .stroke(LinearGradient(colors: [.red.opacity(0.3), .red.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
}

struct AbilityScoresSection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.purple.opacity(0.2)).frame(width: 28, height: 28)
                    Image(systemName: "sparkles").foregroundColor(.purple).font(.caption)
                }
                Text("Характеристики").font(.headline).fontWeight(.semibold)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                InteractiveAbilityCard(
                    name: "Сила",
                    score: $character.strength,
                    modifier: character.strengthModifier
                )
                
                InteractiveAbilityCard(
                    name: "Ловкость",
                    score: $character.dexterity,
                    modifier: character.dexterityModifier
                )
                
                InteractiveAbilityCard(
                    name: "Телосложение",
                    score: $character.constitution,
                    modifier: character.constitutionModifier
                )
                
                InteractiveAbilityCard(
                    name: "Интеллект",
                    score: $character.intelligence,
                    modifier: character.intelligenceModifier
                )
                
                InteractiveAbilityCard(
                    name: "Мудрость",
                    score: $character.wisdom,
                    modifier: character.wisdomModifier
                )
                
                InteractiveAbilityCard(
                    name: "Харизма",
                    score: $character.charisma,
                    modifier: character.charismaModifier
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .stroke(LinearGradient(colors: [.purple.opacity(0.3), .purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
}

struct SkillsSection: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.green.opacity(0.2)).frame(width: 28, height: 28)
                    Image(systemName: "brain.head.profile").foregroundColor(.green).font(.caption)
                }
                Text("Навыки").font(.headline).fontWeight(.semibold)
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
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .stroke(LinearGradient(colors: [.green.opacity(0.3), .green.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
}

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
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Class Selection Components

struct ImprovedClassCard: View {
    @Binding var characterClass: CharacterClass
    let availableClasses: [GameClass]
    let onDelete: () -> Void
    
    var gameClass: GameClass? {
        availableClasses.first { $0.slug == characterClass.slug }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Class name with picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Класс")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Класс", selection: Binding(
                        get: { characterClass.slug },
                        set: { newSlug in
                            if let gameClass = availableClasses.first(where: { $0.slug == newSlug }) {
                                characterClass = CharacterClass(
                                    slug: gameClass.slug,
                                    name: gameClass.name,
                                    level: characterClass.level,
                                    subclass: nil // Reset subclass when changing class
                                )
                            }
                        }
                    )) {
                        ForEach(availableClasses, id: \.slug) { gameClass in
                            Text(gameClass.name).tag(gameClass.slug)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.primary)
                }
                
                Spacer()
                
                // Level picker
                VStack(spacing: 4) {
                    Text("Уровень")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Button(action: {
                            if characterClass.level > 1 {
                                characterClass = CharacterClass(
                                    slug: characterClass.slug,
                                    name: characterClass.name,
                                    level: characterClass.level - 1,
                                    subclass: characterClass.subclass
                                )
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                        
                        Text("\(characterClass.level)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(minWidth: 40)
                        
                        Button(action: {
                            if characterClass.level < 20 {
                                characterClass = CharacterClass(
                                    slug: characterClass.slug,
                                    name: characterClass.name,
                                    level: characterClass.level + 1,
                                    subclass: characterClass.subclass
                                )
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Circle().fill(Color.red.opacity(0.1)))
                }
            }
            
            // Subclass selection (available from level 3)
            if characterClass.level >= 3, let gameClass = gameClass, !gameClass.subclasses.isEmpty {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Подкласс")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Подкласс", selection: Binding(
                            get: { characterClass.subclass ?? "" },
                            set: { newSubclass in
                                characterClass = CharacterClass(
                                    slug: characterClass.slug,
                                    name: characterClass.name,
                                    level: characterClass.level,
                                    subclass: newSubclass.isEmpty ? nil : newSubclass
                                )
                            }
                        )) {
                            Text("Выберите подкласс").tag("")
                            ForEach(gameClass.subclasses, id: \.name) { subclass in
                                Text(subclass.name).tag(subclass.name)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .accentColor(.primary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        )
    }
}

struct ClassPickerView: View {
    let availableClasses: [GameClass]
    let onClassSelected: (GameClass) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(availableClasses, id: \.slug) { gameClass in
                Button(action: {
                    onClassSelected(gameClass)
                }) {
                    HStack {
                        Text(gameClass.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Выберите класс")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}
