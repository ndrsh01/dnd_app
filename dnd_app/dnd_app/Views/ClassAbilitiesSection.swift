import SwiftUI

struct ClassAbilitiesSection: View {
    @Binding var character: Character
    let onSaveChanges: ((Character) -> Void)?
    @StateObject private var classesStore = ClassesStore()
    
    private func getClassSlug(for className: String) -> String {
        return classesStore.slug(for: className) ?? "fighter"
    }
    
    private func debugReloadClassFeatures() {
        print("🔍 === DEBUG: ПЕРЕЗАГРУЗКА КЛАССОВЫХ УМЕНИЙ ===")
        print("🔍 Персонаж: \(character.name)")
        print("🔍 Класс: \(character.characterClass)")
        print("🔍 Подкласс: \(character.subclass)")
        print("🔍 Уровень: \(character.level)")
        print("🔍 Текущие умения: \(character.classFeatures)")
        
        // Проверяем загрузку данных классов
        print("🔍 ClassesStore состояние:")
        print("  - classesBySlug пустой: \(classesStore.classesBySlug.isEmpty)")
        print("  - classTablesBySlug пустой: \(classesStore.classTablesBySlug.isEmpty)")
        print("  - isLoading: \(classesStore.isLoading)")
        
        if !classesStore.classesBySlug.isEmpty {
            print("🔍 Доступные классы: \(classesStore.classesBySlug.keys.sorted())")
        }
        
        // Получаем slug класса
        let classSlug = getClassSlug(for: character.characterClass)
        print("🔍 Slug класса: \(classSlug)")
        
        // Загружаем данные если нужно
        if classesStore.classesBySlug.isEmpty {
            print("🔍 Загружаем данные классов...")
            classesStore.loadClasses()
        }
        
        if classesStore.classTablesBySlug.isEmpty {
            print("🔍 Загружаем таблицы классов...")
            classesStore.loadClassTables()
        }
        
        // Проверяем класс в данных
        if let gameClass = classesStore.classesBySlug[classSlug] {
            print("🔍 Класс найден в данных!")
            print("🔍 Название класса: \(gameClass.name)")
            print("🔍 Slug класса: \(gameClass.slug)")
            print("🔍 Количество подклассов: \(gameClass.subclasses.count)")
            print("🔍 Доступные уровни: \(gameClass.featuresByLevel.keys.sorted())")
            
            // Показываем умения для каждого уровня
            for level in 1...character.level {
                let levelString = String(level)
                if let features = gameClass.featuresByLevel[levelString] {
                    print("🔍 Уровень \(level): \(features.count) умений")
                    for feature in features {
                        print("  - \(feature.name)")
                    }
                } else {
                    print("🔍 Уровень \(level): нет умений")
                }
            }
            
            // Показываем подклассы
            for (index, subclass) in gameClass.subclasses.enumerated() {
                print("🔍 Подкласс \(index + 1): \(subclass.name)")
                print("  - Уровни: \(subclass.featuresByLevel.keys.sorted())")
                for (level, features) in subclass.featuresByLevel {
                    print("  - Уровень \(level): \(features.count) умений")
                }
            }
        } else {
            print("❌ Класс НЕ найден в данных!")
            print("❌ Доступные классы: \(classesStore.classesBySlug.keys)")
        }
        
        print("🔍 === КОНЕЦ ОТЛАДКИ ===")
    }
    
    // MARK: - Helper Functions
    private func reloadClassFeatures() {
        print("🔍 [reloadClassFeatures] Начинаем перезагрузку умений класса")
        
        var updatedCharacter = character
        
        // Очищаем старые умения класса
        if !character.characterClass.isEmpty {
            let classSlug = getClassSlug(for: character.characterClass)
            updatedCharacter.classFeatures[classSlug] = [:]
            print("🔍 [reloadClassFeatures] Очищены умения для класса: \(character.characterClass)")
        }
        
        // Перезагружаем умения для всех классов персонажа
        for characterClass in character.characterClasses {
            updatedCharacter.classFeatures[characterClass.slug] = [:]
            print("🔍 [reloadClassFeatures] Очищены умения для класса: \(characterClass.name)")
        }
        
        // Сохраняем изменения
        onSaveChanges?(updatedCharacter)
        
        print("🔍 [reloadClassFeatures] Перезагрузка завершена")
    }


    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.purple.opacity(0.2)).frame(width: 28, height: 28)
                    Image(systemName: "sparkles").foregroundColor(.purple).font(.caption)
                }
                Text("Классовые умения").font(.headline).fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    debugReloadClassFeatures()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                        Text("Перезагрузить")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.purple.opacity(0.1))
                    )
                }
                
                // Кнопка перезагрузки умений класса
                Button(action: {
                    reloadClassFeatures()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "brain.head.profile")
                            .font(.caption)
                        Text("Перезагрузить умения")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.green.opacity(0.1))
                    )
                }
                
                // Кнопка принудительной загрузки данных классов
                Button(action: {
                    print("🔍 [ClassAbilitiesSection] Принудительная загрузка данных классов...")
                    classesStore.loadClasses()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle")
                            .font(.caption)
                        Text("Загрузить данные")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                
                // Кнопка сброса всех изменений (показывается только если есть изменения)
                if !character.modifiedClassStats.isEmpty {
                    Button(action: {
                        var updatedCharacter = character
                        updatedCharacter.modifiedClassStats.removeAll()
                        onSaveChanges?(updatedCharacter)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.caption)
                            Text("Сбросить все")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                }
            }
            
            // Check if we have new multi-class system or legacy single class
            let hasMultiClasses = !character.characterClasses.isEmpty
            let hasLegacyClass = !character.characterClass.isEmpty
            
            if !hasMultiClasses && !hasLegacyClass {
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(.purple.opacity(0.6))
                    
                    Text("Добавьте классы персонажа")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("Классовые умения будут отображаться здесь")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .stroke(Color.purple.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
            } else {
                if classesStore.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Загрузка классовых умений...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    // Show multi-class characters
                    if hasMultiClasses {
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
                    }
                    
                    // Show legacy single class characters  
                    if hasLegacyClass {
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
        .onChange(of: character.subclass) { _ in
            print("🔍 [ClassAbilitiesSection] Подкласс изменился, обновляем таблицу прогрессии")
            reloadClassFeatures()
        }
        .onChange(of: character.characterClass) { _ in
            print("🔍 [ClassAbilitiesSection] Класс изменился, обновляем таблицу прогрессии")
            reloadClassFeatures()
        }
        .onChange(of: character.level) { _ in
            print("🔍 [ClassAbilitiesSection] Уровень изменился, обновляем таблицу прогрессии")
            reloadClassFeatures()
        }
    }
}



struct ClassAbilitiesCard: View {
    let characterClass: CharacterClass
    let classFeatures: [String: [ClassFeature]]
    let classTable: ClassTable?
    @ObservedObject var classesStore: ClassesStore
    let onSaveChanges: ((Character) -> Void)?
    let character: Character
    @State private var showingProgressionTable = false
    @State private var showingFeatures = false
    
    @State private var showingLevelAbilities = true
    @State private var collapsedLevels: Set<Int> = []
    @State private var showingProgressionStats = true
    
    // Helper functions for modified class stats
    private func getModifiedValue(for statName: String, level: String) -> String? {
        return character.modifiedClassStats[characterClass.slug]?[level]?[statName]
    }
    
    private func updateModifiedValue(for statName: String, level: String, value: String) {
        var updatedCharacter = character
        
        // Initialize nested dictionaries if they don't exist
        if updatedCharacter.modifiedClassStats[characterClass.slug] == nil {
            updatedCharacter.modifiedClassStats[characterClass.slug] = [:]
        }
        if updatedCharacter.modifiedClassStats[characterClass.slug]?[level] == nil {
            updatedCharacter.modifiedClassStats[characterClass.slug]?[level] = [:]
        }
        
        // Update the value
        updatedCharacter.modifiedClassStats[characterClass.slug]?[level]?[statName] = value
        
        // Save changes
        onSaveChanges?(updatedCharacter)
    }
    
    private func resetModifiedValues() {
        var updatedCharacter = character
        
        // Remove all modified values for this class and level
        updatedCharacter.modifiedClassStats[characterClass.slug]?["\(characterClass.level)"] = nil
        
        // If the class has no more modified values, remove the entire class entry
        if updatedCharacter.modifiedClassStats[characterClass.slug]?.isEmpty == true {
            updatedCharacter.modifiedClassStats[characterClass.slug] = nil
        }
        
            // Save changes
    onSaveChanges?(updatedCharacter)
}

// MARK: - Computed Properties
private var progressionTable: ClassTable? {
    return classTable ?? classesStore.classTablesBySlug[characterClass.slug]
}

private var currentLevelRow: [String: String]? {
    guard let table = progressionTable else { return nil }
    return table.rows.first(where: { $0["Уровень"] == "\(characterClass.level)" })
}

private var hasProgressionData: Bool {
    return progressionTable != nil && currentLevelRow != nil
}

private var availableFeatures: [String: [ClassFeature]] {
    // Всегда пытаемся получить данные из ClassesStore
    if let gameClass = classesStore.classesBySlug[characterClass.slug] {
        var allFeatures: [String: [ClassFeature]] = [:]
        
        print("🔍 [availableFeatures] Загружаем умения для класса: \(gameClass.name)")
        print("🔍 [availableFeatures] Уровень персонажа: \(characterClass.level)")
        print("🔍 [availableFeatures] Подкласс: \(characterClass.subclass ?? "не выбран")")
        
        // Загружаем умения для всех уровней от 1 до текущего уровня персонажа
        for level in 1...characterClass.level {
            let levelString = String(level)
            var levelFeatures: [ClassFeature] = []
            
            // Добавляем базовые умения класса
            if let baseFeatures = gameClass.featuresByLevel[levelString] {
                levelFeatures.append(contentsOf: baseFeatures)
                print("🔍 [availableFeatures] Уровень \(level): добавлено \(baseFeatures.count) базовых умений")
            }
            
            // Добавляем умения подкласса, если он выбран
            if let subclass = characterClass.subclass, !subclass.isEmpty {
                if let selectedSubclass = gameClass.subclasses.first(where: { $0.name.lowercased() == subclass.lowercased() }) {
                    let subclassFeaturesForLevel = selectedSubclass.features.filter { $0.level == level }
                    for feature in subclassFeaturesForLevel {
                        let classFeature = ClassFeature(name: feature.name, description: feature.description)
                        levelFeatures.append(classFeature)
                    }
                    print("🔍 [availableFeatures] Уровень \(level): добавлено \(subclassFeaturesForLevel.count) умений подкласса '\(selectedSubclass.name)'")
                } else {
                    print("❌ [availableFeatures] Подкласс '\(subclass)' не найден в классе '\(gameClass.name)'")
                }
            }
            
            if !levelFeatures.isEmpty {
                allFeatures[levelString] = levelFeatures
            }
        }
        
        print("🔍 [availableFeatures] Итого загружено умений: \(allFeatures.values.flatMap { $0 }.count)")
        return allFeatures
    } else {
        print("❌ [availableFeatures] Класс '\(characterClass.slug)' не найден в ClassesStore")
        return classFeatures
    }
}

    // MARK: - Subviews
    @ViewBuilder
    private var classHeaderView: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(characterClass.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    if let subclass = characterClass.subclass, !subclass.isEmpty {
                        Text(subclass)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Уровень \(characterClass.level)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(colors: [.purple, .purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                    
                    if classTable != nil {
                        Text("Таблица прогрессии")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                }
                    }
                }
            }
            
    @ViewBuilder
    private var progressionStatsView: some View {
        if hasProgressionData, let table = progressionTable, let currentLevelRow = currentLevelRow {
                VStack(spacing: 8) {
                Button(action: {
                    showingProgressionStats.toggle()
                }) {
                    HStack {
                        Image(systemName: showingProgressionStats ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(.purple)
                        
                        Text("Умения уровня \(characterClass.level)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                        Spacer()
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                if showingProgressionStats {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                        ForEach(table.columns.dropFirst(), id: \.self) { column in
                            if let value = currentLevelRow[column] {
                                VStack(spacing: 2) {
                                    Text(column)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    
                                    Text(value)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(.systemGray6))
                                )
                            }
                            }
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                )
        }
            }
            
    @ViewBuilder
    private var actionButtonsView: some View {
            HStack(spacing: 12) {
                Button(action: { showingProgressionTable.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "tablecells")
                            .font(.caption)
                        Text("Таблица прогрессии")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.purple.opacity(0.1))
                    )
                }
                
                Button(action: { showingFeatures.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "list.bullet")
                            .font(.caption)
                        Text("Классовые умения")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.purple.opacity(0.1))
                    )
                }
            

                
                Spacer()
        }
    }
    
    @ViewBuilder
    private var expandedContentView: some View {
        if showingProgressionTable {
            if let table = progressionTable {
                ProgressionTableView(classTable: table, currentLevel: characterClass.level)
            } else {
                Text("Таблица прогрессии не найдена")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            }
            }
            
            if showingFeatures {
            ClassFeaturesView(classFeatures: availableFeatures, characterClass: characterClass)
        }
        

    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            classHeaderView
            progressionStatsView
            actionButtonsView
            expandedContentView
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ProgressionTableView: View {
    let classTable: ClassTable
    let currentLevel: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Таблица прогрессии")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header row
                    HStack(spacing: 0) {
                        ForEach(classTable.columns, id: \.self) { column in
                            Text(column)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(minWidth: 60, maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                                .background(Color.purple)
                        }
                    }
                    
                    // Data rows
                    ForEach(Array(classTable.rows.enumerated()), id: \.offset) { index, row in
                        HStack(spacing: 0) {
                            ForEach(classTable.columns, id: \.self) { column in
                                Text(row[column] ?? "")
                                    .font(.caption2)
                                    .foregroundColor(index == currentLevel - 1 ? .white : .primary)
                                    .frame(minWidth: 60, maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 4)
                                    .background(
                                        index == currentLevel - 1 ? Color.purple : Color.clear
                                    )
                            }
                        }
                        .background(
                            index % 2 == 0 ? Color(.systemGray6) : Color.clear
                        )
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ClassFeaturesView: View {
    let classFeatures: [String: [ClassFeature]]
    let characterClass: CharacterClass
    @State private var collapsedLevels: Set<Int> = []
    @State private var collapsedFeatures: Set<String> = []
    
    var body: some View {
        ScrollView {
        VStack(alignment: .leading, spacing: 12) {
            Text("Классовые умения")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            

            
            // Main class features
            ForEach(1...characterClass.level, id: \.self) { level in
                let features = classFeatures["\(level)"] ?? []
                if !features.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            if collapsedLevels.contains(level) {
                                collapsedLevels.remove(level)
                            } else {
                                collapsedLevels.insert(level)
                            }
                        }) {
                        HStack {
                                Image(systemName: collapsedLevels.contains(level) ? "chevron.right" : "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                                
                            Text("Уровень \(level)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.purple)
                                )
                            
                            Spacer()
                        }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if !collapsedLevels.contains(level) {
                        ForEach(features, id: \.name) { feature in
                            VStack(alignment: .leading, spacing: 4) {
                                    Button(action: {
                                        if collapsedFeatures.contains(feature.name) {
                                            collapsedFeatures.remove(feature.name)
                                        } else {
                                            collapsedFeatures.insert(feature.name)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: collapsedFeatures.contains(feature.name) ? "chevron.right" : "chevron.down")
                                                .font(.caption2)
                                                .foregroundColor(.purple)
                                            
                                Text(feature.name)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                            Spacer()
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if !collapsedFeatures.contains(feature.name) && !feature.text.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                    Text(feature.text)
                                                .font(.caption)
                                        .foregroundColor(.secondary)
                                                .lineLimit(nil)
                                                .multilineTextAlignment(.leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .textSelection(.enabled)
                                        }
                                        .padding(.leading, 16)
                                        .padding(.top, 8)
                                        .padding(.bottom, 8)
                                        .padding(.trailing, 8)
                                }
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }
                }
            }
            }
        }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
}
