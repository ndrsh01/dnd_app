import SwiftUI

struct CharacterClassesSection: View {
    @Binding var character: Character
    let classesStore: ClassesStore
    @State private var showingAddClass = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.blue.opacity(0.2)).frame(width: 28, height: 28)
                    Image(systemName: "graduationcap").foregroundColor(.blue).font(.caption)
                }
                Text("Классы персонажа").font(.headline).fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { showingAddClass = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            
            if character.characterClasses.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "graduationcap")
                        .font(.title2)
                        .foregroundColor(.blue.opacity(0.6))
                    
                    Text("Добавьте класс персонажа")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("Нажмите + чтобы добавить класс")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .stroke(Color.blue.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(character.characterClasses.indices, id: \.self) { index in
                        CharacterClassCard(
                            characterClass: $character.characterClasses[index],
                            onDelete: {
                                let removedClass = character.characterClasses[index]
                                character.characterClasses.remove(at: index)
                                
                                // Clear cached data for removed class
                                character.classFeatures.removeValue(forKey: removedClass.slug)
                                character.classProgression.removeValue(forKey: removedClass.slug)
                                
                                // Update character's total level and proficiency bonus
                                character.level = character.totalLevel
                                character.proficiencyBonus = (character.totalLevel - 1) / 4 + 2
                            },
                            onUpdate: {
                                print("🔍 === DEBUG: ОБНОВЛЕНИЕ КЛАССА В CharacterClassesSection ===")
                                print("🔍 Индекс класса: \(index)")
                                
                                // Update character's total level and proficiency bonus
                                character.level = character.totalLevel
                                character.proficiencyBonus = (character.totalLevel - 1) / 4 + 2
                                
                                // Update cached class features for the updated class
                                let updatedClass = character.characterClasses[index]
                                print("🔍 Обновляемый класс: \(updatedClass.name) (slug: \(updatedClass.slug))")
                                print("🔍 Уровень класса: \(updatedClass.level)")
                                print("🔍 ClassesStore состояние:")
                                print("  - classesBySlug пустой: \(classesStore.classesBySlug.isEmpty)")
                                print("  - Доступные классы: \(classesStore.classesBySlug.keys.sorted())")
                                
                                if let gameClass = classesStore.classesBySlug[updatedClass.slug] {
                                    print("✅ Класс найден в данных!")
                                    var updatedFeatures: [String: [ClassFeature]] = [:]
                                    
                                    // Add features for all levels up to the current level
                                    for levelNum in 1...updatedClass.level {
                                        let levelString = String(levelNum)
                                        if let features = gameClass.featuresByLevel[levelString] {
                                            updatedFeatures[levelString] = features
                                            print("🔍 Уровень \(levelNum): \(features.count) умений")
                                        } else {
                                            print("⚠️ Уровень \(levelNum): нет умений")
                                        }
                                    }
                                    
                                    character.classFeatures[updatedClass.slug] = updatedFeatures
                                    print("✅ Умения обновлены для класса \(updatedClass.slug)")
                                } else {
                                    print("❌ Класс НЕ найден в данных!")
                                    print("❌ Доступные классы: \(classesStore.classesBySlug.keys.sorted())")
                                }
                                
                                // Update class progression table
                                if let classTable = classesStore.classTablesBySlug[updatedClass.slug] {
                                    character.classProgression[updatedClass.slug] = classTable
                                    print("✅ Таблица прогрессии обновлена")
                                } else {
                                    print("⚠️ Таблица прогрессии не найдена в кэше, пытаемся загрузить...")
                                    // Try to load the table if it's not in cache
                                    classesStore.loadClassTables()
                                    
                                    // Check again after a short delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        if let classTable = classesStore.classTablesBySlug[updatedClass.slug] {
                                            character.classProgression[updatedClass.slug] = classTable
                                            print("✅ Таблица прогрессии загружена и обновлена")
                                        } else {
                                            print("❌ Таблица прогрессии все еще не найдена")
                                        }
                                    }
                                }
                                
                                print("🔍 === КОНЕЦ ОТЛАДКИ ===")
                            }
                        )
                    }
                }
            }
            
            // Total level display
            if !character.characterClasses.isEmpty {
                HStack {
                    Text("Общий уровень:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(character.totalLevel)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .stroke(LinearGradient(colors: [.blue.opacity(0.3), .blue.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .sheet(isPresented: $showingAddClass) {
            AddClassView(character: $character, classesStore: classesStore)
        }
    }
}

struct CharacterClassCard: View {
    @Binding var characterClass: CharacterClass
    let onDelete: () -> Void
    let onUpdate: () -> Void
    @StateObject private var classesStore = ClassesStore()
    @State private var showingEdit = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Class icon
            ZStack {
                Circle().fill(Color.blue.opacity(0.2)).frame(width: 40, height: 40)
                Image(systemName: "graduationcap")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            // Class info
            VStack(alignment: .leading, spacing: 4) {
                Text(characterClass.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text("Уровень \(characterClass.level)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.blue.opacity(0.1))
                        )
                    
                    if let subclass = characterClass.subclass, !subclass.isEmpty {
                        Text(subclass)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray5))
                            )
                    }
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                Button(action: { showingEdit = true }) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.red.opacity(0.1))
                        )
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
        .sheet(isPresented: $showingEdit) {
            EditClassView(characterClass: $characterClass, onUpdate: onUpdate, classesStore: classesStore)
        }
    }
}

struct AddClassView: View {
    @Binding var character: Character
    let classesStore: ClassesStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedClass = ""
    @State private var level = 1
    @State private var subclass = ""
    
    private var availableClasses: [String] {
        Array(classesStore.classesBySlug.keys.sorted())
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Class selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Выберите класс")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Picker("Класс", selection: $selectedClass) {
                        Text("Выберите класс").tag("")
                        ForEach(availableClasses, id: \.self) { className in
                            Text(className.capitalized).tag(className)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                }
                
                // Level selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Уровень")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Button(action: { if level > 1 { level -= 1 } }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                        
                        Text("\(level)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(minWidth: 60)
                        
                        Spacer()
                        
                        Button(action: { if level < 20 { level += 1 } }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                }
                
                // Subclass selection (if available)
                if let gameClass = classesStore.classesBySlug[selectedClass],
                   !gameClass.subclasses.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Подкласс (опционально)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Picker("Подкласс", selection: $subclass) {
                            Text("Без подкласса").tag("")
                            ForEach(gameClass.subclasses, id: \.name) { subclass in
                                Text(subclass.name).tag(subclass.name)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Добавить класс")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        addClass()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .disabled(selectedClass.isEmpty)
                }
            }
        }
    }
    
    private func addClass() {
        let newClass = CharacterClass(
            slug: selectedClass,
            name: selectedClass.capitalized,
            level: level,
            subclass: subclass.isEmpty ? nil : subclass
        )
        character.characterClasses.append(newClass)
        
        // Cache class features and progression data
        if let gameClass = classesStore.classesBySlug[selectedClass] {
            character.classFeatures[selectedClass] = gameClass.featuresByLevel
        }
        
        if let classTable = classesStore.classTablesBySlug[selectedClass] {
            character.classProgression[selectedClass] = classTable
        }
        
        // Update character's total level and proficiency bonus
        character.level = character.totalLevel
        character.proficiencyBonus = (character.totalLevel - 1) / 4 + 2
        
        dismiss()
    }
}

struct EditClassView: View {
    @Binding var characterClass: CharacterClass
    let onUpdate: () -> Void
    @ObservedObject var classesStore: ClassesStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var level: Int
    @State private var subclass: String
    
    init(characterClass: Binding<CharacterClass>, onUpdate: @escaping () -> Void, classesStore: ClassesStore) {
        self._characterClass = characterClass
        self.onUpdate = onUpdate
        self.classesStore = classesStore
        self._level = State(initialValue: characterClass.wrappedValue.level)
        self._subclass = State(initialValue: characterClass.wrappedValue.subclass ?? "")
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Class info
                VStack(spacing: 8) {
                    Text(characterClass.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Редактирование класса")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
                
                // Level selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Уровень")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Button(action: { if level > 1 { level -= 1 } }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                        
                        Text("\(level)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(minWidth: 60)
                        
                        Spacer()
                        
                        Button(action: { if level < 20 { level += 1 } }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                }
                
                // Subclass field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Подкласс")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextField("Введите подкласс", text: $subclass)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Редактировать класс")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func saveChanges() {
        print("🔍 === DEBUG: СОХРАНЕНИЕ ИЗМЕНЕНИЙ КЛАССА ===")
        print("🔍 Класс: \(characterClass.name) (slug: \(characterClass.slug))")
        print("🔍 Новый уровень: \(level)")
        print("🔍 Новый подкласс: \(subclass)")
        
        characterClass.level = level
        characterClass.subclass = subclass.isEmpty ? nil : subclass
        
        // Update character's total level and proficiency bonus
        onUpdate()
        
        // Update cached class features and progression data
        print("🔍 ClassesStore состояние:")
        print("  - classesBySlug пустой: \(classesStore.classesBySlug.isEmpty)")
        print("  - classTablesBySlug пустой: \(classesStore.classTablesBySlug.isEmpty)")
        
        if let gameClass = classesStore.classesBySlug[characterClass.slug] {
            print("✅ Класс найден в данных!")
            print("🔍 Доступные уровни: \(gameClass.featuresByLevel.keys.sorted())")
            
            // Update features for the new level
            var updatedFeatures: [String: [ClassFeature]] = [:]
            
            // Add features for all levels up to the new level
            for levelNum in 1...level {
                let levelString = String(levelNum)
                if let features = gameClass.featuresByLevel[levelString] {
                    updatedFeatures[levelString] = features
                    print("🔍 Уровень \(levelNum): \(features.count) умений")
                } else {
                    print("⚠️ Уровень \(levelNum): нет умений")
                }
            }
            
            print("🔍 Всего обновлено уровней: \(updatedFeatures.count)")
        } else {
            print("❌ Класс НЕ найден в данных!")
            print("❌ Доступные классы: \(classesStore.classesBySlug.keys.sorted())")
        }
        
        print("🔍 === КОНЕЦ ОТЛАДКИ ===")
        dismiss()
    }
}
