import SwiftUI

struct CompactCharacterSheetView: View {
    let character: Character
    @ObservedObject var store: CharacterStore
    @ObservedObject var compendiumStore: CompendiumStore
    @State private var showingDetailSection: CharacterDetailSection?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let current = store.selectedCharacter {
                // Заголовок персонажа
                    CharacterHeaderCompactView(character: current, store: store)
                
                // Хиты (отдельно)
                    HitPointsView(store: store)
                
                // Основные характеристики (компактно)
                    CompactStatsView(character: current)
                
                // Ссылки на детальные разделы
                DetailSectionsView(showingDetailSection: $showingDetailSection)
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
        .sheet(item: $showingDetailSection) { section in
            let current = store.selectedCharacter ?? character
            DetailSectionView(character: current, section: section, store: store, compendiumStore: compendiumStore)
        }
    }
}

struct CharacterHeaderCompactView: View {
    let character: Character
    @ObservedObject var store: CharacterStore
    @State private var editingName = false
    @State private var newName = ""
    @State private var editingRace = false
    @State private var newRace = ""
    @State private var editingClass = false
    @State private var newClass = ""
    @State private var editingLevel = false
    @State private var newLevel = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Главная секция с аватаром и именем
            HStack(spacing: 20) {
                // Современный аватар с градиентом
                ZStack {
                    // Градиентный фон
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(0.8),
                                    Color.orange.opacity(0.6),
                                    Color.yellow.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    // Иконка персонажа
                    Image(systemName: "person.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Информация о персонаже
                VStack(alignment: .leading, spacing: 8) {
                    // Имя персонажа
                    Text(character.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .onLongPressGesture {
                            newName = character.name
                            editingName = true
                        }
                    
                    // Раса и класс с иконками
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "figure.walk")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text(character.race)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .onLongPressGesture {
                                    newRace = character.race
                                    editingRace = true
                                }
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "shield.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text(character.characterClass)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                                .onLongPressGesture {
                                    newClass = character.characterClass
                                    editingClass = true
                                }
                        }
                    }
                    
                    // Уровень в красивом badge
                    HStack {
                    Text("Уровень \(character.level)")
                        .font(.caption)
                        .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .orange.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .onLongPressGesture {
                                newLevel = "\(character.level)"
                                editingLevel = true
                            }
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Разделитель
            Divider()
                .padding(.horizontal, 20)
            
            // Дополнительная информация в современном стиле
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    ModernInfoItem(icon: "person.circle", title: "Игрок", value: character.playerName, color: .blue)
                    ModernInfoItem(icon: "book.closed", title: "Предыстория", value: character.background, color: .purple)
                }
                
                HStack(spacing: 16) {
                    ModernInfoItem(icon: "balance.scale", title: "Мировоззрение", value: character.alignment, color: .indigo)
                    ModernInfoItem(icon: "star.circle", title: "Опыт", value: "\(character.experience)", color: .yellow)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
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
        .alert("Редактировать имя", isPresented: $editingName) {
            TextField("Имя персонажа", text: $newName)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    var updatedCharacter = character
                    updatedCharacter.name = newName
                    store.update(updatedCharacter)
                }
            }
        }
        .alert("Редактировать расу", isPresented: $editingRace) {
            TextField("Раса", text: $newRace)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if !newRace.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    var updatedCharacter = character
                    updatedCharacter.race = newRace
                    store.update(updatedCharacter)
                }
            }
        }
        .alert("Редактировать класс", isPresented: $editingClass) {
            TextField("Класс", text: $newClass)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if !newClass.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    var updatedCharacter = character
                    updatedCharacter.characterClass = newClass
                    store.update(updatedCharacter)
                }
            }
        }
        .alert("Редактировать уровень", isPresented: $editingLevel) {
            TextField("Уровень", text: $newLevel)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if let level = Int(newLevel), level > 0, level <= 20 {
                    var updatedCharacter = character
                    updatedCharacter.level = level
                    store.update(updatedCharacter)
                }
            }
        }
    }
}

struct ModernInfoItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // Иконка в цветном круге
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
            }
            
            // Текст
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                
                Text(value.isEmpty ? "—" : value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

struct InfoItemCompact: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value.isEmpty ? "—" : value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

struct HitPointsView: View {
    @ObservedObject var store: CharacterStore
    @State private var showingHPEditor = false
    @State private var newHP = ""
    
    private var character: Character? { store.selectedCharacter }
    
    private var hpPercentage: Double {
        guard let c = character, c.maxHitPoints > 0 else { return 0 }
        return Double(c.currentHitPoints) / Double(c.maxHitPoints)
    }
    
    private var hpColor: Color {
        switch hpPercentage {
        case 0.7...1.0: return .green
        case 0.3..<0.7: return .yellow
        default: return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Заголовок с иконкой
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.headline)
                        .foregroundColor(hpColor)
                Text("Хиты")
                    .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // Кликабельное значение HP
                Button(action: {
                    newHP = "\(character?.currentHitPoints ?? 0)"
                    showingHPEditor = true
                }) {
                    HStack(spacing: 4) {
                        Text("\(character?.currentHitPoints ?? 0)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(hpColor)
                        
                        Text("/")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("\(character?.maxHitPoints ?? 0)")
                    .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(hpColor.opacity(0.1))
                            .stroke(hpColor.opacity(0.3), lineWidth: 2)
                    )
                }
            }
            
            // Современный прогресс-бар
            VStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    // Фон прогресс-бара
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    // Заполненная часть с градиентом
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [hpColor, hpColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(4, CGFloat(hpPercentage) * 280), height: 12)
                        .animation(.easeInOut(duration: 0.3), value: hpPercentage)
                }
                
                // Процент здоровья
                HStack {
                    Text("\(Int(hpPercentage * 100))% здоровья")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let c = character, c.temporaryHitPoints > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("\(c.temporaryHitPoints) врем.")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
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
                        colors: [hpColor.opacity(0.3), hpColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .alert("Изменить хиты", isPresented: $showingHPEditor) {
            TextField("Текущие хиты", text: $newHP)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if let c = character, let hp = Int(newHP), hp >= 0, hp <= c.maxHitPoints {
                    store.updateCharacterHitPoints(c, newCurrentHP: hp)
                }
            }
        } message: {
            Text("Введите новое значение хитов (0-\(character?.maxHitPoints ?? 0))")
        }
    }
}

struct CompactStatsView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 20) {
            // Заголовок с иконкой
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.headline)
                        .foregroundColor(.purple)
            Text("Основные характеристики")
                .font(.headline)
                        .fontWeight(.bold)
                }
                Spacer()
            }
            
            // Современная сетка характеристик
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ModernStatItem(name: "СИЛ", score: character.strength, modifier: character.strengthModifier, icon: "figure.strengthtraining.traditional", color: .red)
                ModernStatItem(name: "ЛОВ", score: character.dexterity, modifier: character.dexterityModifier, icon: "figure.run", color: .green)
                ModernStatItem(name: "ТЕЛ", score: character.constitution, modifier: character.constitutionModifier, icon: "heart.fill", color: .orange)
                ModernStatItem(name: "ИНТ", score: character.intelligence, modifier: character.intelligenceModifier, icon: "brain.head.profile", color: .blue)
                ModernStatItem(name: "МДР", score: character.wisdom, modifier: character.wisdomModifier, icon: "eye.fill", color: .purple)
                ModernStatItem(name: "ХАР", score: character.charisma, modifier: character.charismaModifier, icon: "person.2.fill", color: .pink)
            }
            
            // Боевые характеристики
            VStack(spacing: 12) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "shield.fill")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Text("Боевые характеристики")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    ModernCombatStat(title: "КЗ", value: "\(character.armorClass)", icon: "shield.fill", color: .blue)
                    ModernCombatStat(title: "Инициатива", value: character.initiative >= 0 ? "+\(character.initiative)" : "\(character.initiative)", icon: "bolt.fill", color: .yellow)
                    ModernCombatStat(title: "Скорость", value: "\(character.effectiveSpeed) фт.", icon: "figure.walk", color: .green)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
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
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}

struct CompactStatItem: View {
    let name: String
    let score: Int
    let modifier: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(modifier >= 0 ? .green : .red)
            
            Text("\(score)")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ModernStatItem: View {
    let name: String
    let score: Int
    let modifier: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // Иконка характеристики
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Название характеристики
            Text(name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            // Модификатор (главное значение)
            Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(modifier >= 0 ? .green : .red)
            
            // Базовое значение
            Text("\(score)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray6))
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.06))
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ModernCombatStat: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            // Иконка
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            // Значение
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Название
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.08))
        )
    }
}

struct CombatStatCompact: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct DetailSectionsView: View {
    @Binding var showingDetailSection: CharacterDetailSection?
    @State private var collapsedSections: Set<CharacterDetailSection> = []
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Детальная информация")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 8) {
                ForEach(CharacterDetailSection.allCases, id: \.self) { section in
                    CollapsibleSectionCard(
                        section: section,
                        isCollapsed: collapsedSections.contains(section),
                        onToggle: {
                            if collapsedSections.contains(section) {
                                collapsedSections.remove(section)
                            } else {
                                collapsedSections.insert(section)
                            }
                        },
                        onTap: {
                        showingDetailSection = section
                    }
                    )
                }
            }
        }
        .padding()
        .background(ThemeManager.adaptiveCardBackground(for: nil))
        .cornerRadius(12)
    }
}

struct CollapsibleSectionCard: View {
    let section: CharacterDetailSection
    let isCollapsed: Bool
    let onToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: section.icon)
                    .font(.title2)
                    .foregroundColor(section.color)
                
                Text(section.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(section.color.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(section.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            onToggle()
        }
    }
}


