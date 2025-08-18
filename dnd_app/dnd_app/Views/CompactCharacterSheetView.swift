import SwiftUI

struct CompactCharacterSheetView: View {
    let character: Character
    @ObservedObject var store: CharacterStore
    @ObservedObject var spellStore: SpellStore
    @ObservedObject var featStore: FeatStore
    @ObservedObject var backgroundStore: BackgroundStore
    @State private var showingDetailSection: CharacterDetailSection?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок персонажа
                CharacterHeaderCompactView(character: character)
                
                // Хиты (отдельно)
                HitPointsView(character: character, store: store)
                
                // Основные характеристики (компактно)
                CompactStatsView(character: character)
                
                // Ссылки на детальные разделы
                DetailSectionsView(showingDetailSection: $showingDetailSection)
            }
            .padding()
        }
        .background(ThemeManager.adaptiveCardBackground(for: nil))
        .sheet(item: $showingDetailSection) { section in
            DetailSectionView(character: character, section: section, store: store, spellStore: spellStore, featStore: featStore, backgroundStore: backgroundStore)
        }
    }
}

struct CharacterHeaderCompactView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 12) {
            // Аватар и основная информация
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("\(character.race) • \(character.characterClass)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Уровень \(character.level)")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
            
            // Дополнительная информация
            HStack(spacing: 20) {
                InfoItemCompact(title: "Игрок", value: character.playerName)
                InfoItemCompact(title: "Предыстория", value: character.background)
                InfoItemCompact(title: "Мировоззрение", value: character.alignment)
            }
        }
        .padding()
        .background(ThemeManager.adaptiveCardBackground(for: nil))
        .cornerRadius(12)
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
    let character: Character
    @ObservedObject var store: CharacterStore
    @State private var showingHPEditor = false
    @State private var newHP = ""
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Хиты")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                Button(action: {
                    newHP = "\(character.currentHitPoints)"
                    showingHPEditor = true
                }) {
                    Text("\(character.currentHitPoints)/\(character.maxHitPoints)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .frame(minWidth: 80)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            ProgressView(value: Double(character.currentHitPoints), total: Double(character.maxHitPoints))
                .progressViewStyle(LinearProgressViewStyle(tint: .red))
            
            if character.temporaryHitPoints > 0 {
                HStack {
                    Text("Временные хиты:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(character.temporaryHitPoints)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(ThemeManager.adaptiveCardBackground(for: nil))
        .cornerRadius(12)
        .alert("Изменить хиты", isPresented: $showingHPEditor) {
            TextField("Текущие хиты", text: $newHP)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if let hp = Int(newHP), hp >= 0, hp <= character.maxHitPoints {
                    store.updateCharacterHitPoints(character, newCurrentHP: hp)
                }
            }
        } message: {
            Text("Введите новое значение хитов (0-\(character.maxHitPoints))")
        }
    }
}

struct CompactStatsView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Основные характеристики")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                CompactStatItem(name: "СИЛ", score: character.strength, modifier: character.strengthModifier)
                CompactStatItem(name: "ЛОВ", score: character.dexterity, modifier: character.dexterityModifier)
                CompactStatItem(name: "ТЕЛ", score: character.constitution, modifier: character.constitutionModifier)
                CompactStatItem(name: "ИНТ", score: character.intelligence, modifier: character.intelligenceModifier)
                CompactStatItem(name: "МДР", score: character.wisdom, modifier: character.wisdomModifier)
                CompactStatItem(name: "ХАР", score: character.charisma, modifier: character.charismaModifier)
            }
            
            // Боевые характеристики
            HStack(spacing: 16) {
                CombatStatCompact(title: "КЗ", value: "\(character.armorClass)", icon: "shield.fill", color: .blue)
                CombatStatCompact(title: "Инициатива", value: character.initiative >= 0 ? "+\(character.initiative)" : "\(character.initiative)", icon: "bolt.fill", color: .yellow)
                CombatStatCompact(title: "Скорость", value: "\(character.speed) фт.", icon: "figure.walk", color: .green)
            }
        }
        .padding()
        .background(ThemeManager.adaptiveCardBackground(for: nil))
        .cornerRadius(12)
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


