import SwiftUI

struct CharacterCreationView: View {
    @ObservedObject var characterStore: CharacterStore
    @Environment(\.dismiss) private var dismiss
    @State private var character = Character()
    @State private var currentStep = 0
    @State private var showingImport = false
    
    private let steps = [
        "Основная информация",
        "Характеристики",
        "Боевые характеристики",
        "Навыки и спасброски",
        "Личность",
        "Снаряжение"
    ]
    
    private func stepIcon(for step: Int) -> String {
        switch step {
        case 0: return "person.circle"
        case 1: return "sparkles"
        case 2: return "shield"
        case 3: return "brain.head.profile"
        case 4: return "heart"
        case 5: return "bag"
        default: return "questionmark.circle"
        }
    }
    
        var body: some View {
        NavigationView {
            ZStack {
                // Современный градиентный фон
                LinearGradient(
                    colors: [
                        Color("BackgroundColor").opacity(0.95),
                        Color("BackgroundColor").opacity(0.8),
                        Color("BackgroundColor")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Прогресс-бар с современным стилем
                    VStack(spacing: 12) {
                        ProgressView(value: Double(currentStep + 1), total: Double(steps.count))
                            .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(4)
                        
                        // Заголовок шага с иконкой
                        HStack {
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: stepIcon(for: currentStep))
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                Text(steps[currentStep])
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Text("\(currentStep + 1) из \(steps.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardBackground"))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)
                
                    // Контент шага
                    ScrollView {
                        VStack(spacing: 20) {
                            switch currentStep {
                            case 0:
                                BasicInfoStepView(character: $character)
                            case 1:
                                AbilitiesStepView(character: $character)
                            case 2:
                                CombatStepView(character: $character)
                            case 3:
                                SkillsStepView(character: $character)
                            case 4:
                                PersonalityStepView(character: $character)
                            case 5:
                                EquipmentStepView(character: $character)
                            default:
                                EmptyView()
                            }
                        }
                        .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("CardBackground"))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Кнопки навигации
                    HStack(spacing: 16) {
                        if currentStep > 0 {
                            Button(action: {
                                withAnimation {
                                    currentStep -= 1
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Назад")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.orange)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.orange, lineWidth: 1)
                                )
                            }
                        }
                        
                        Spacer()
                        
                        if currentStep < steps.count - 1 {
                            Button(action: {
                                withAnimation {
                                    currentStep += 1
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Text("Далее")
                                        .fontWeight(.semibold)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [Color.orange, Color.orange.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                        } else {
                            Button(action: {
                                createCharacter()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Создать персонажа")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [Color.green, Color.green.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Создание персонажа")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingImport = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Импорт")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showingImport) {
                CharacterImportView(store: characterStore) { importedCharacter in
                    // Заменяем текущего персонажа импортированным
                    character = importedCharacter
                    // Переходим к последнему шагу для проверки
                    currentStep = steps.count - 1
                }
            }
        }
    }
    
    private func createCharacter() {
        character.dateCreated = Date()
        character.dateModified = Date()
        characterStore.add(character)
        dismiss()
    }
}

// MARK: - Basic Info Step
struct BasicInfoStepView: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Основная информация")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 12) {
                    TextField("Имя персонажа", text: $character.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Имя игрока", text: $character.playerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Раса", text: $character.race)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Класс", text: $character.characterClass)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Предыстория", text: $character.background)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Мировоззрение", text: $character.alignment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        Text("Уровень:")
                        Spacer()
                        Stepper(value: $character.level, in: 1...20) {
                            Text("\(character.level)")
                                .font(.headline)
                                .fontWeight(.semibold)
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

// MARK: - Abilities Step
struct AbilitiesStepView: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Характеристики")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    AbilityInputCard(title: "Сила", score: $character.strength, icon: "figure.strengthtraining.traditional", color: .red)
                    AbilityInputCard(title: "Ловкость", score: $character.dexterity, icon: "figure.run", color: .green)
                    AbilityInputCard(title: "Телосложение", score: $character.constitution, icon: "heart.fill", color: .orange)
                    AbilityInputCard(title: "Интеллект", score: $character.intelligence, icon: "brain.head.profile", color: .blue)
                    AbilityInputCard(title: "Мудрость", score: $character.wisdom, icon: "eye.fill", color: .purple)
                    AbilityInputCard(title: "Харизма", score: $character.charisma, icon: "person.2.fill", color: .pink)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}

struct AbilityInputCard: View {
    let title: String
    @Binding var score: Int
    let icon: String
    let color: Color
    
    var modifier: Int {
        (score - 10) / 2
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            HStack {
                Button("-") {
                    if score > 1 {
                        score -= 1
                    }
                }
                .foregroundColor(.red)
                
                Text("\(score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(minWidth: 40)
                
                Button("+") {
                    if score < 20 {
                        score += 1
                    }
                }
                .foregroundColor(.green)
            }
            
            Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                .font(.caption)
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

// MARK: - Combat Step
struct CombatStepView: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Боевые характеристики")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Класс брони:")
                        Spacer()
                        TextField("10", value: $character.armorClass, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                    }
                    
                    HStack {
                        Text("Максимум хитов:")
                        Spacer()
                        TextField("0", value: $character.maxHitPoints, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                    }
                    
                    HStack {
                        Text("Скорость:")
                        Spacer()
                        TextField("30", value: $character.speed, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                    }
                    
                    HStack {
                        Text("Инициатива:")
                        Spacer()
                        Text("\(character.dexterityModifier)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(character.dexterityModifier >= 0 ? .green : .red)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}

// MARK: - Skills Step
struct SkillsStepView: View {
    @Binding var character: Character
    
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
                    ForEach(skillNames.sorted(by: { $0.value < $1.value }), id: \.key) { skillKey, skillName in
                        SkillToggleRow(
                            name: skillName,
                            isProficient: Binding(
                                get: { character.skills[skillKey] == true },
                                set: { character.skills[skillKey] = $0 }
                            )
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

struct SkillToggleRow: View {
    let name: String
    @Binding var isProficient: Bool
    
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isProficient)
                .toggleStyle(SwitchToggleStyle(tint: .orange))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Personality Step
struct PersonalityStepView: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Личность")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Черты характера")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("Опишите черты характера", text: $character.personalityTraits, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Идеалы")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("Опишите идеалы", text: $character.ideals, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Привязанности")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("Опишите привязанности", text: $character.bonds, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Слабости")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("Опишите слабости", text: $character.flaws, axis: .vertical)
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
}

// MARK: - Equipment Step
struct EquipmentStepView: View {
    @Binding var character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Снаряжение")
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Прочие владения и языки")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("Опишите прочие владения и языки", text: $character.otherProficiencies, axis: .vertical)
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
}

struct CharacterCreationView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterCreationView(characterStore: CharacterStore())
    }
}
