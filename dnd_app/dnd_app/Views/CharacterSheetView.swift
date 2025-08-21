import SwiftUI
import UniformTypeIdentifiers

// MARK: - Character Sheet View

struct CharacterSheetView: View {
    @ObservedObject var characterStore: CharacterStore
    @StateObject private var compendiumStore = CompendiumStore()
    @StateObject private var classesStore = ClassesStore()
    @StateObject private var themeManager = ThemeManager()
    @State private var showingAdd = false
    @State private var showCharacterSelection = false
    @State private var isEditingMode = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.988, green: 0.933, blue: 0.855),
                        Color(red: 0.988, green: 0.933, blue: 0.855).opacity(0.9),
                        Color(red: 0.988, green: 0.933, blue: 0.855)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Всегда показываем лист выбранного персонажа
                    if let character = characterStore.selectedCharacter {
                        CompactCharacterSheetView(
                            character: character, 
                            store: characterStore, 
                            compendiumStore: compendiumStore,
                            classesStore: classesStore,
                            isEditingMode: $isEditingMode,
                            onSaveChanges: { updatedCharacter in
                                characterStore.update(updatedCharacter)
                            }
                        )
                    } else {
                        // Fallback если по какой-то причине персонаж не выбран
                        VStack(spacing: 20) {
                            Image(systemName: "person.text.rectangle")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("Персонаж не выбран")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Выберите персонажа в настройках")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle("Лист персонажа")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showCharacterSelection = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                            Text("Сменить персонажа")
                                .font(.subheadline)
                        }
                        .foregroundColor(.orange)
                    }
                }

                // Убрали кнопку редактирования - теперь редактирование через долгое нажатие
            }
            .sheet(isPresented: $showingAdd) {
                CharacterEditorView(store: characterStore, character: characterStore.selectedCharacter)
            }
            .sheet(isPresented: $showCharacterSelection) {
                CharacterSelectionView(
                    characterStore: characterStore,
                    isPresented: $showCharacterSelection
                )
            }
        }
    }
}



// MARK: - Stat Badge

struct StatBadge: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ModernStatBadge: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка с градиентным фоном
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .padding(8)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Character Import View

struct CharacterImportView: View {
    let store: CharacterStore
    let onImport: ((Character) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @State private var jsonText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var showingFilePicker = false
    @State private var showingDocumentPicker = false
    
    init(store: CharacterStore, onImport: ((Character) -> Void)? = nil) {
        self.store = store
        self.onImport = onImport
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Заголовок
                VStack(spacing: 8) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Импорт персонажа")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Выберите файл для автоматического импорта или вставьте JSON вручную")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Кнопка открытия документа
                VStack(spacing: 12) {
                    Button(action: { showingDocumentPicker = true }) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Открыть документ")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                }
                
                // Разделитель
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                    Text("ИЛИ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
                
                // Поле для JSON
                VStack(alignment: .leading, spacing: 8) {
                    Text("Вставить JSON вручную")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $jsonText)
                        .font(.system(.body, design: .monospaced))
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .frame(minHeight: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                // Кнопки
                VStack(spacing: 12) {
                    Button(action: importCharacter) {
                        HStack {
                            Image(systemName: "arrow.down.doc")
                            Text("Импортировать из текста")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(jsonText.isEmpty ? Color.gray : Color.orange)
                        .cornerRadius(12)
                    }
                    .disabled(jsonText.isEmpty)
                    
                    Button(action: { dismiss() }) {
                        Text("Отмена")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color("BackgroundColor"))
            .navigationTitle("Импорт")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isSuccess ? "Успех!" : "Ошибка", isPresented: $showingAlert) {
                Button("OK") {
                    if isSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.json, .text],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .fileImporter(
                isPresented: $showingDocumentPicker,
                allowedContentTypes: [.json, .text, .plainText],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
        }
    }
    
    private func importCharacter() {
        guard !jsonText.isEmpty else { return }
        
        if let importedCharacter = store.importCharacterFromJSON(jsonText) {
            isSuccess = true
            alertMessage = "Персонаж успешно импортирован!"
            
            // Если есть callback, используем его
            if let onImport = onImport {
                onImport(importedCharacter)
                dismiss()
            } else {
                // Иначе добавляем в список
                store.add(importedCharacter)
                dismiss()
            }
        } else {
            isSuccess = false
            alertMessage = "Ошибка при импорте. Проверьте формат JSON файла."
        }
        
        showingAlert = true
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                alertMessage = "Файл не выбран"
                isSuccess = false
                showingAlert = true
                return
            }
            
            do {
                // Начинаем доступ к файлу
                guard url.startAccessingSecurityScopedResource() else {
                    alertMessage = "Нет доступа к файлу"
                    isSuccess = false
                    showingAlert = true
                    return
                }
                
                defer {
                    url.stopAccessingSecurityScopedResource()
                }
                
                // Читаем содержимое файла
                let fileContent = try String(contentsOf: url, encoding: .utf8)
                
                // Сразу импортируем персонажа
                if let importedCharacter = store.importCharacterFromJSON(fileContent) {
                    isSuccess = true
                    alertMessage = "Персонаж успешно импортирован из файла!"
                    
                    // Если есть callback, используем его
                    if let onImport = onImport {
                        onImport(importedCharacter)
                        dismiss()
                    } else {
                        // Иначе добавляем в список
                        store.add(importedCharacter)
                        dismiss()
                    }
                } else {
                    isSuccess = false
                    alertMessage = "Ошибка при импорте. Проверьте формат JSON файла."
                }
                
                showingAlert = true
                
            } catch {
                alertMessage = "Ошибка чтения файла: \(error.localizedDescription)"
                isSuccess = false
                showingAlert = true
            }
            
        case .failure(let error):
            alertMessage = "Ошибка выбора файла: \(error.localizedDescription)"
            isSuccess = false
            showingAlert = true
        }
    }
}

// MARK: - Character Card

struct CharacterCard: View {
    let character: Character
    let store: CharacterStore
    @State private var showingEditor = false
    @State private var showingViewer = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Основная информация
            HStack(spacing: 16) {
                // Аватар
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .orange.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name.isEmpty ? "Без имени" : character.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(character.race) • \(character.displayClassName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Игрок: \(character.playerName.isEmpty ? "Не указан" : character.playerName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Уровень \(character.totalLevel > 0 ? character.totalLevel : character.level)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text("\(character.currentHitPoints)/\(character.maxHitPoints) HP")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
            
            // Статистики
            HStack(spacing: 20) {
                StatBadge(title: "КЗ", value: "\(character.armorClass)", color: .blue)
                StatBadge(title: "Инициатива", value: "\(character.initiative >= 0 ? "+" : "")\(character.initiative)", color: .green)
                StatBadge(title: "Скорость", value: "\(character.effectiveSpeed) фт", color: .purple)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onTapGesture {
            showingViewer = true
        }
        .sheet(isPresented: $showingViewer) {
            CharacterViewerView(originalCharacter: character, store: store)
        }
        .sheet(isPresented: $showingEditor) {
            CharacterEditorView(store: store, character: character)
        }
    }
}





// MARK: - Character Viewer View

struct CharacterViewerView: View {
    let originalCharacter: Character
    let store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditor = false
    
    private var character: Character {
        store.characters.first(where: { $0.id == originalCharacter.id }) ?? originalCharacter
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.988, green: 0.933, blue: 0.855),
                        Color(red: 0.988, green: 0.933, blue: 0.855).opacity(0.9),
                        Color(red: 0.988, green: 0.933, blue: 0.855)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                    // Заголовок персонажа
                    CharacterDisplayHeaderView(character: character)
                    
                    // Основные характеристики
                    MainStatsView(character: character, store: store)
                    
                    // Характеристики и модификаторы
                    AbilityScoresViewerView(character: character)
                    
                    // Боевые характеристики
                    CombatStatsViewerView(character: character, store: store)
                    
                    // Спасброски и навыки
                    SkillsViewerView(character: character)
                    
                    // Черты характера
                    PersonalityViewerView(character: character)
                    
                    // Снаряжение и особенности
                    EquipmentViewerView(character: character)
                    
                    // Атаки
                    AttacksViewerView(character: character)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color("BackgroundColor"),
                        Color("BackgroundColor").opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("\(character.name.isEmpty ? "Персонаж" : character.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Редактировать") {
                        showingEditor = true
                    }
                    .foregroundColor(.orange)
                }
            }
            .sheet(isPresented: $showingEditor) {
                CharacterEditorView(store: store, character: character)
            }
        }
    }
}




struct InfoCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Main Stats View

struct MainStatsView: View {
    let character: Character
    let store: CharacterStore
    @State private var showingHPEditor = false
    @State private var tempCurrentHP = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Основные характеристики")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                StatCard(title: "КЗ", value: "\(character.armorClass)", color: .blue)
                StatCard(title: "Инициатива", value: "\(character.initiative >= 0 ? "+" : "")\(character.initiative)", color: .green)
                StatCard(title: "Скорость", value: "\(character.effectiveSpeed) фт", color: .purple)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                // Редактируемые хиты
                Button(action: {
                    tempCurrentHP = character.currentHitPoints
                    showingHPEditor = true
                }) {
                    StatCard(title: "Хиты", value: "\(character.currentHitPoints)/\(character.maxHitPoints)", color: .red)
                }
                .buttonStyle(PlainButtonStyle())
                
                StatCard(title: "Бонус мастерства", value: "+\(character.proficiencyBonus)", color: .orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .alert("Изменить текущие хиты", isPresented: $showingHPEditor) {
            TextField("Текущие хиты", value: $tempCurrentHP, format: .number)
                .keyboardType(.numberPad)
            
            Button("Отмена", role: .cancel) { }
            
            Button("Сохранить") {
                var updatedCharacter = character
                updatedCharacter.currentHitPoints = max(0, min(tempCurrentHP, character.maxHitPoints))
                store.update(updatedCharacter)
            }
        } message: {
            Text("Введите новое значение текущих хитов (от 0 до \(character.maxHitPoints))")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Ability Scores Viewer

struct AbilityScoresViewerView: View {
    let character: Character
    
    var abilities: [(String, String, Int, Int)] {
        [
            ("Сила", "strength", character.strength, character.savingThrowModifier(for: "strength")),
            ("Ловкость", "dexterity", character.dexterity, character.savingThrowModifier(for: "dexterity")),
            ("Телосложение", "constitution", character.constitution, character.savingThrowModifier(for: "constitution")),
            ("Интеллект", "intelligence", character.intelligence, character.savingThrowModifier(for: "intelligence")),
            ("Мудрость", "wisdom", character.wisdom, character.savingThrowModifier(for: "wisdom")),
            ("Харизма", "charisma", character.charisma, character.savingThrowModifier(for: "charisma"))
        ]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Характеристики")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                ForEach(abilities, id: \.0) { ability in
                    AbilityScoreViewerCard(
                        name: ability.0,
                        score: ability.2,
                        modifier: ability.3,
                        savingThrow: character.savingThrows[ability.1] ?? false
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct AbilityScoreViewerCard: View {
    let name: String
    let score: Int
    let modifier: Int
    let savingThrow: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("\(score)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            
            VStack(spacing: 2) {
                Text("\(modifier >= 0 ? "+" : "")\(modifier)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(modifier >= 0 ? .green : .red)
                
                if savingThrow {
                    Text("Спасбросок")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Combat Stats Viewer

struct CombatStatsViewerView: View {
    let character: Character
    let store: CharacterStore
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Боевые характеристики")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Кость хитов
                HStack {
                    Text("Кость хитов")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(character.hitDiceTotal)\(character.hitDiceType)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                
                Divider()
                
                // Вдохновение
                Button(action: {
                    var updatedCharacter = character
                    updatedCharacter.inspiration.toggle()
                    store.update(updatedCharacter)
                }) {
                    HStack {
                        Text("Вдохновение")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: character.inspiration ? "star.fill" : "star")
                            .foregroundColor(character.inspiration ? .yellow : .gray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                
                // Спасброски от смерти
                VStack(alignment: .leading, spacing: 8) {
                    Text("Спасброски от смерти")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("Успехи")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                ForEach(0..<3) { index in
                                    Button(action: {
                                        var updatedCharacter = character
                                        if index < updatedCharacter.deathSaveSuccesses {
                                            updatedCharacter.deathSaveSuccesses -= 1
                                        } else {
                                            updatedCharacter.deathSaveSuccesses = index + 1
                                        }
                                        store.update(updatedCharacter)
                                    }) {
                                        Circle()
                                            .fill(index < character.deathSaveSuccesses ? Color.green : Color.gray.opacity(0.3))
                                            .frame(width: 16, height: 16)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text("Провалы")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                ForEach(0..<3) { index in
                                    Button(action: {
                                        var updatedCharacter = character
                                        if index < updatedCharacter.deathSaveFailures {
                                            updatedCharacter.deathSaveFailures -= 1
                                        } else {
                                            updatedCharacter.deathSaveFailures = index + 1
                                        }
                                        store.update(updatedCharacter)
                                    }) {
                                        Circle()
                                            .fill(index < character.deathSaveFailures ? Color.red : Color.gray.opacity(0.3))
                                            .frame(width: 16, height: 16)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Skills Viewer

struct SkillsViewerView: View {
    let character: Character
    
    let skills = [
        ("Акробатика", "acrobatics", "Лов"),
        ("Анализ", "investigation", "Инт"),
        ("Атлетика", "athletics", "Сил"),
        ("Восприятие", "perception", "Муд"),
        ("Выживание", "survival", "Муд"),
        ("Выступление", "performance", "Хар"),
        ("Запугивание", "intimidation", "Хар"),
        ("История", "history", "Инт"),
        ("Ловкость рук", "sleight_of_hand", "Лов"),
        ("Магия", "arcana", "Инт"),
        ("Медицина", "medicine", "Муд"),
        ("Обман", "deception", "Хар"),
        ("Природа", "nature", "Инт"),
        ("Проницательность", "insight", "Муд"),
        ("Религия", "religion", "Инт"),
        ("Скрытность", "stealth", "Лов"),
        ("Убеждение", "persuasion", "Хар"),
        ("Уход за животными", "animal_handling", "Муд")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Навыки")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
                ForEach(skills, id: \.0) { skill in
                    SkillViewerCard(
                        name: skill.0,
                        ability: skill.2,
                        isProficient: character.skills[skill.1] ?? false,
                        modifier: character.skillModifier(for: skill.1)
                    )
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Пассивная мудрость (восприятие)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(character.passivePerception)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct SkillViewerCard: View {
    let name: String
    let ability: String
    let isProficient: Bool
    let modifier: Int
    
    var body: some View {
        HStack {
            Image(systemName: isProficient ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isProficient ? .green : .gray)
                .font(.caption)
            
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("(\(ability))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("\(modifier >= 0 ? "+" : "")\(modifier)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(modifier >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Personality Viewer

struct PersonalityViewerView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Черты характера")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                PersonalityCard(title: "Черты характера", text: character.personalityTraits)
                PersonalityCard(title: "Идеалы", text: character.ideals)
                PersonalityCard(title: "Привязанности", text: character.bonds)
                PersonalityCard(title: "Слабости", text: character.flaws)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct PersonalityCard: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(text.isEmpty ? "Не указано" : text)
                .font(.body)
                .foregroundColor(text.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Equipment Viewer

struct EquipmentViewerView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Снаряжение и особенности")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                EquipmentCard(title: "Снаряжение", text: character.equipment)
                EquipmentCard(title: "Особенности и черты", text: character.featuresAndTraits)
                EquipmentCard(title: "Прочие владения и языки", text: character.otherProficiencies)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct EquipmentCard: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(text.isEmpty ? "Не указано" : text)
                .font(.body)
                .foregroundColor(text.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Attacks Viewer

struct AttacksViewerView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Атаки и заклинания")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if character.attacks.isEmpty {
                Text("Атаки не указаны")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                VStack(spacing: 8) {
                    ForEach(character.attacks) { attack in
                        AttackViewerCard(attack: attack)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct AttackViewerCard: View {
    let attack: Attack
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(attack.name.isEmpty ? "Без названия" : attack.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(attack.attackBonus.isEmpty ? "Бонус не указан" : attack.attackBonus)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(attack.damageType.isEmpty ? "Тип не указан" : attack.damageType)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.orange)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// CharacterEditorView moved to its own file for clarity

// MARK: - Basic Info Section

struct BasicInfoSection: View {
    @Binding var character: Character
    
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
                    Text("Класс")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите класс", text: $character.characterClass)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Предыстория")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Введите предысторию", text: $character.background)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
                                // Обновляем бонус владения
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
                                // Обновляем бонус владения
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
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .stroke(LinearGradient(colors: [.orange.opacity(0.3), .orange.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
}

// MARK: - Combat Stats Section

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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Бонус владения")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(character.proficiencyBonus)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Максимум хитов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Макс. хиты", value: $character.maxHitPoints, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Текущие хиты")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Текущие хиты", value: $character.currentHitPoints, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Временные хиты")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Временные хиты", value: $character.temporaryHitPoints, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Кость хитов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("d6", text: $character.hitDiceType)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            // Вдохновение
            HStack {
                Toggle("Вдохновение", isOn: $character.inspiration)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                Spacer()
            }
            
            // Спасброски от смерти
            VStack(alignment: .leading, spacing: 8) {
                Text("Спасброски от смерти")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Успехи")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(index < character.deathSaveSuccesses ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: 20, height: 20)
                                    .onTapGesture {
                                        if index < character.deathSaveSuccesses {
                                            character.deathSaveSuccesses -= 1
                                        } else {
                                            character.deathSaveSuccesses = index + 1
                                        }
                                    }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Провалы")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(index < character.deathSaveFailures ? Color.red : Color.gray.opacity(0.3))
                                    .frame(width: 20, height: 20)
                                    .onTapGesture {
                                        if index < character.deathSaveFailures {
                                            character.deathSaveFailures -= 1
                                        } else {
                                            character.deathSaveFailures = index + 1
                                        }
                                    }
                            }
                        }
                    }
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

// MARK: - Ability Scores Section

struct AbilityScoresSection: View {
    @Binding var character: Character
    
    let abilities = [
        ("Сила", "strength"),
        ("Ловкость", "dexterity"),
        ("Телосложение", "constitution"),
        ("Интеллект", "intelligence"),
        ("Мудрость", "wisdom"),
        ("Харизма", "charisma")
    ]
    
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
                ForEach(abilities, id: \.0) { ability in
                    AbilityScoreCard(
                        name: ability.0,
                        score: binding(for: ability.1),
                        modifier: modifier(for: ability.1),
                        savingThrow: binding(for: ability.1, in: \.savingThrows),
                        savingThrowModifier: character.savingThrowModifier(for: ability.1)
                    )
                }
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
    
    private func binding(for ability: String) -> Binding<Int> {
        Binding(
            get: { 
                switch ability {
                case "strength": return character.strength
                case "dexterity": return character.dexterity
                case "constitution": return character.constitution
                case "intelligence": return character.intelligence
                case "wisdom": return character.wisdom
                case "charisma": return character.charisma
                default: return 10
                }
            },
            set: { newValue in
                switch ability {
                case "strength": character.strength = newValue
                case "dexterity": character.dexterity = newValue
                case "constitution": character.constitution = newValue
                case "intelligence": character.intelligence = newValue
                case "wisdom": character.wisdom = newValue
                case "charisma": character.charisma = newValue
                default: break
                }
            }
        )
    }
    
    private func modifier(for ability: String) -> Int {
        let score: Int
        switch ability {
        case "strength": score = character.strength
        case "dexterity": score = character.dexterity
        case "constitution": score = character.constitution
        case "intelligence": score = character.intelligence
        case "wisdom": score = character.wisdom
        case "charisma": score = character.charisma
        default: score = 10
        }
        return (score - 10) / 2
    }
    
    private func binding(for key: String, in keyPath: WritableKeyPath<Character, [String: Bool]>) -> Binding<Bool> {
        Binding(
            get: { character[keyPath: keyPath][key] ?? false },
            set: { character[keyPath: keyPath][key] = $0 }
        )
    }
}

struct AbilityScoreCard: View {
    let name: String
    @Binding var score: Int
    let modifier: Int
    @Binding var savingThrow: Bool
    let savingThrowModifier: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                Button(action: {
                    if score > 1 {
                        score -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                
                Text("\(score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(minWidth: 40)
                
                Button(action: {
                    if score < 30 {
                        score += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                }
            }
            
            VStack(spacing: 2) {
                Text("\(modifier >= 0 ? "+" : "")\(modifier)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(modifier >= 0 ? .green : .red)
                
                HStack {
                    Text("Спасбросок")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Toggle("", isOn: $savingThrow)
                        .toggleStyle(CheckboxToggleStyle())
                }
                
                if savingThrow {
                    Text("\(savingThrowModifier >= 0 ? "+" : "")\(savingThrowModifier)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .orange : .gray)
        }
    }
}

// MARK: - Skills Section

struct SkillsSection: View {
    @Binding var character: Character
    
    let skills = [
        ("Акробатика", "acrobatics", "Лов"),
        ("Анализ", "investigation", "Инт"),
        ("Атлетика", "athletics", "Сил"),
        ("Восприятие", "perception", "Муд"),
        ("Выживание", "survival", "Муд"),
        ("Выступление", "performance", "Хар"),
        ("Запугивание", "intimidation", "Хар"),
        ("История", "history", "Инт"),
        ("Ловкость рук", "sleight_of_hand", "Лов"),
        ("Магия", "arcana", "Инт"),
        ("Медицина", "medicine", "Муд"),
        ("Обман", "deception", "Хар"),
        ("Природа", "nature", "Инт"),
        ("Проницательность", "insight", "Муд"),
        ("Религия", "religion", "Инт"),
        ("Скрытность", "stealth", "Лов"),
        ("Убеждение", "persuasion", "Хар"),
        ("Уход за животными", "animal_handling", "Муд")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.green.opacity(0.2)).frame(width: 28, height: 28)
                    Image(systemName: "brain.head.profile").foregroundColor(.green).font(.caption)
                }
                Text("Навыки").font(.headline).fontWeight(.semibold)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
                ForEach(skills, id: \.0) { skill in
                    HStack {
                        Toggle("", isOn: binding(for: skill.1, in: \.skills))
                            .toggleStyle(CheckboxToggleStyle())
                        
                        Text(skill.0)
                            .font(.caption)
                        
                        HStack(spacing: 4) {
                            Text("(\(skill.2))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("\(character.skillModifier(for: skill.1) >= 0 ? "+" : "")\(character.skillModifier(for: skill.1))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(character.skillModifier(for: skill.1) >= 0 ? .green : .red)
                        }
                        
                        Spacer()
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Пассивная мудрость (восприятие)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(character.passivePerception)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
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
    
    private func binding(for key: String, in keyPath: WritableKeyPath<Character, [String: Bool]>) -> Binding<Bool> {
        Binding(
            get: { character[keyPath: keyPath][key] ?? false },
            set: { character[keyPath: keyPath][key] = $0 }
        )
    }
}

// MARK: - Personality Section

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

// MARK: - Equipment Section

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

// MARK: - Attacks Section

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
            
            // Ячейки заклинаний
            VStack(alignment: .leading, spacing: 8) {
                Text("Ячейки заклинаний")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { level in
                        VStack(spacing: 4) {
                            Text("\(level) ур.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            TextField("0", value: $character.spellSlots[level], format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
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

// MARK: - Character Detail Views

struct CharacterDisplayHeaderView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            // Аватар и имя
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                }
                
                VStack(spacing: 4) {
                    Text(character.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("\(character.race) • \(character.displayClassName)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Уровень \(character.totalLevel > 0 ? character.totalLevel : character.level)")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }
            }
            
            // Основная информация
            HStack(spacing: 20) {
                InfoItem(title: "Игрок", value: character.playerName)
                InfoItem(title: "Предыстория", value: character.background)
                InfoItem(title: "Мировоззрение", value: character.alignment)
            }
        }
    }
}

struct InfoItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value.isEmpty ? "—" : value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

struct CharacterStatsView: View {
    let character: Character
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
            StatItem(name: "СИЛ", score: character.strength, modifier: character.strengthModifier)
            StatItem(name: "ЛОВ", score: character.dexterity, modifier: character.dexterityModifier)
            StatItem(name: "ТЕЛ", score: character.constitution, modifier: character.constitutionModifier)
            StatItem(name: "ИНТ", score: character.intelligence, modifier: character.intelligenceModifier)
            StatItem(name: "МДР", score: character.wisdom, modifier: character.wisdomModifier)
            StatItem(name: "ХАР", score: character.charisma, modifier: character.charismaModifier)
        }
    }
}

struct StatItem: View {
    let name: String
    let score: Int
    let modifier: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("\(score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(modifier >= 0 ? .green : .red)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct CharacterCombatView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                CombatStatItem(title: "Класс брони", value: "\(character.armorClass)", icon: "shield.fill", color: .blue)
                CombatStatItem(title: "Инициатива", value: character.initiative >= 0 ? "+\(character.initiative)" : "\(character.initiative)", icon: "bolt.fill", color: .yellow)
                CombatStatItem(title: "Скорость", value: "\(character.effectiveSpeed) фт.", icon: "figure.walk", color: .green)
                CombatStatItem(title: "Пассивное восприятие", value: "\(character.passivePerception)", icon: "eye.fill", color: .purple)
            }
            
            // Хиты
            VStack(spacing: 8) {
                HStack {
                    Text("Хиты")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(character.currentHitPoints)/\(character.maxHitPoints)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                ProgressView(value: min(1.0, max(0.0, Double(character.currentHitPoints) / Double(character.maxHitPoints))))
                    .progressViewStyle(LinearProgressViewStyle(tint: .red))
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct CombatStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

struct CharacterSkillsView: View {
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
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
            ForEach(skillNames.sorted(by: { $0.value < $1.value }), id: \.key) { skillKey, skillName in
                SkillItem(
                    name: skillName,
                    modifier: character.skillModifier(for: skillKey),
                    isProficient: character.skills[skillKey] == true
                )
            }
        }
    }
}

struct SkillItem: View {
    let name: String
    let modifier: Int
    let isProficient: Bool
    
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            if isProficient {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
            
            Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(modifier >= 0 ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

struct CharacterDetailsView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 12) {
            DetailSection(title: "Черты характера", text: character.personalityTraits)
            DetailSection(title: "Идеалы", text: character.ideals)
            DetailSection(title: "Привязанности", text: character.bonds)
            DetailSection(title: "Слабости", text: character.flaws)
            DetailSection(title: "Снаряжение", text: character.equipment)
            DetailSection(title: "Умения и способности", text: character.featuresAndTraits)
        }
    }
}

struct DetailSection: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            if text.isEmpty {
                Text("—")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct CharacterAttacksView: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(character.attacks) { attack in
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
                .padding(.vertical, 4)
            }
        }
    }
}

struct CharacterSavesView: View {
    let character: Character
    
    private let saveNames = [
        "strength": "СИЛ",
        "dexterity": "ЛОВ", 
        "constitution": "ТЕЛ",
        "intelligence": "ИНТ",
        "wisdom": "МДР",
        "charisma": "ХАР"
    ]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
            ForEach(Array(saveNames.keys.sorted()), id: \.self) { saveKey in
                if let saveName = saveNames[saveKey] {
                    SaveItem(
                        name: saveName,
                        modifier: character.savingThrowModifier(for: saveKey),
                        isProficient: character.savingThrows[saveKey] == true
                    )
                }
            }
        }
    }
}

struct SaveItem: View {
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
                .fontWeight(.medium)
                .foregroundColor(modifier >= 0 ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}
}
