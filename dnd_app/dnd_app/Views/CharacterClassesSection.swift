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
                                let updatedClass = character.characterClasses[index]

                                if let gameClass = classesStore.classesBySlug[updatedClass.slug] {
                                    var filtered = gameClass.featuresByLevel.filter { key, _ in
                                        (Int(key) ?? 0) <= updatedClass.level
                                    }
                                    if let subclassName = updatedClass.subclass,
                                       let sub = gameClass.subclasses.first(where: { $0.name == subclassName }) {
                                        let subFeatures = sub.featuresByLevel.filter { key, _ in
                                            (Int(key) ?? 0) <= updatedClass.level
                                        }
                                        for (k, v) in subFeatures {
                                            filtered[k, default: []].append(contentsOf: v)
                                        }
                                    }
                                    character.classFeatures[updatedClass.slug] = filtered
                                }

                                if let classTable = classesStore.classTablesBySlug[updatedClass.slug] {
                                    character.classProgression[updatedClass.slug] = classTable
                                }

                                // Update character's total level and proficiency bonus
                                character.level = character.totalLevel
                                character.proficiencyBonus = (character.totalLevel - 1) / 4 + 2
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
            EditClassView(characterClass: $characterClass, onUpdate: onUpdate)
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
                    CommonSectionHeader("Выберите класс", icon: "graduationcap")

                    Picker("Класс", selection: $selectedClass) {
                        Text("Выберите класс").tag("")
                        ForEach(availableClasses, id: \.self) { className in
                            Text(className.capitalized).tag(className)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .modifier(CommonTextFieldStyle())
                }

                // Level selection
                VStack(alignment: .leading, spacing: 8) {
                    CommonSectionHeader("Уровень", icon: "number.square")

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
                    .modifier(CommonTextFieldStyle())
                }
                
                // Subclass selection (if available)
                if let gameClass = classesStore.classesBySlug[selectedClass],
                   !gameClass.subclasses.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        CommonSectionHeader("Подкласс", icon: "line.3.horizontal")

                        Picker("Подкласс", selection: $subclass) {
                            Text("Без подкласса").tag("")
                            ForEach(gameClass.subclasses, id: \.name) { subclass in
                                Text(subclass.name).tag(subclass.name)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .modifier(CommonTextFieldStyle())
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
            var filtered = gameClass.featuresByLevel.filter { key, _ in
                (Int(key) ?? 0) <= level
            }
            if !subclass.isEmpty,
               let sub = gameClass.subclasses.first(where: { $0.name == subclass }) {
                let subFeatures = sub.featuresByLevel.filter { key, _ in
                    (Int(key) ?? 0) <= level
                }
                for (k, v) in subFeatures {
                    filtered[k, default: []].append(contentsOf: v)
                }
            }
            character.classFeatures[selectedClass] = filtered
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
    @Environment(\.dismiss) private var dismiss
    
    @State private var level: Int
    @State private var subclass: String
    
    init(characterClass: Binding<CharacterClass>, onUpdate: @escaping () -> Void) {
        self._characterClass = characterClass
        self.onUpdate = onUpdate
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
                    CommonSectionHeader("Уровень", icon: "number.square")

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
                    .modifier(CommonTextFieldStyle())
                }

                // Subclass field
                VStack(alignment: .leading, spacing: 8) {
                    CommonSectionHeader("Подкласс", icon: "line.3.horizontal")

                    TextField("Введите подкласс", text: $subclass)
                        .modifier(CommonTextFieldStyle())
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
        characterClass.level = level
        characterClass.subclass = subclass.isEmpty ? nil : subclass
        
        // Update character's total level and proficiency bonus
        onUpdate()
        
        // Update cached data if needed
        // Note: This would need access to ClassesStore, but for now we'll rely on the cached data
        // being updated when the class was first added
        
        dismiss()
    }
}
