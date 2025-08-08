import SwiftUI

struct CharactersView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddCharacter = false
    @State private var selectedCharacter: Character?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.characters) { character in
                    CharacterRow(character: character) {
                        selectedCharacter = character
                    }
                }
                .onDelete(perform: deleteCharacters)
            }
            .navigationTitle("Персонажи")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCharacter = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCharacter) {
                AddCharacterView()
                    .environmentObject(dataManager)
            }
            .sheet(item: $selectedCharacter) { character in
                CharacterDetailView(character: character)
                    .environmentObject(dataManager)
            }
        }
    }
    
    private func deleteCharacters(offsets: IndexSet) {
        for index in offsets {
            dataManager.removeCharacter(dataManager.characters[index])
        }
    }
}

struct CharacterRow: View {
    let character: Character
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(character.name.prefix(1)))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(character.race) \(character.class) \(character.level) уровня")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !character.relationships.isEmpty {
                        HStack {
                            Text("Отношения:")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            ForEach(character.relationships.prefix(3)) { relationship in
                                HeartRatingView(
                                    rating: relationship.strength,
                                    size: 12,
                                    color: relationship.relationshipType.color
                                )
                            }
                            
                            if character.relationships.count > 3 {
                                Text("+\(character.relationships.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CharacterDetailView: View {
    let character: Character
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    @State private var showingAddRelationship = false
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Character Header
                    VStack(spacing: 12) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(String(character.name.prefix(1)))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text(character.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("\(character.race) \(character.class)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Уровень \(character.level)")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    
                    // Description
                    if !character.description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Описание")
                                .font(.headline)
                            
                            Text(character.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }
                    
                    // Relationships
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Отношения")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                showingAddRelationship = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                            }
                        }
                        .padding(.horizontal)
                        
                        if character.relationships.isEmpty {
                            Text("Нет отношений")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(character.relationships) { relationship in
                                    RelationshipStrengthView(relationship: relationship)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    
                    // Notes
                    if !character.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Заметки")
                                .font(.headline)
                            
                            Text(character.notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Детали персонажа")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Изменить") {
                        isEditing = true
                    }
                }
            }
            .sheet(isPresented: $showingAddRelationship) {
                AddRelationshipView(character: character)
                    .environmentObject(dataManager)
            }
            .sheet(isPresented: $isEditing) {
                EditCharacterView(character: character)
                    .environmentObject(dataManager)
            }
        }
    }
}

struct AddCharacterView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var race = ""
    @State private var characterClass = ""
    @State private var level = 1
    @State private var description = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Имя", text: $name)
                    TextField("Раса", text: $race)
                    TextField("Класс", text: $characterClass)
                    Stepper("Уровень: \(level)", value: $level, in: 1...20)
                }
                
                Section("Описание") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
                
                Section("Заметки") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Новый персонаж")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        let character = Character(
                            name: name,
                            race: race,
                            class: characterClass,
                            level: level,
                            description: description,
                            notes: notes
                        )
                        dataManager.addCharacter(character)
                        dismiss()
                    }
                    .disabled(name.isEmpty || race.isEmpty || characterClass.isEmpty)
                }
            }
        }
    }
}

struct AddRelationshipView: View {
    let character: Character
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var characterName = ""
    @State private var relationshipType: RelationshipType = .friend
    @State private var strength = 3
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Персонаж") {
                    TextField("Имя персонажа", text: $characterName)
                }
                
                Section("Тип отношений") {
                    Picker("Тип", selection: $relationshipType) {
                        ForEach(RelationshipType.allCases, id: \.self) { type in
                            HStack {
                                Circle()
                                    .fill(type.color)
                                    .frame(width: 12, height: 12)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                }
                
                Section("Сила отношений") {
                    HeartRatingPicker(rating: $strength, color: relationshipType.color)
                }
                
                Section("Описание") {
                    TextEditor(text: $description)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Добавить отношения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        let relationship = Relationship(
                            characterName: characterName,
                            relationshipType: relationshipType,
                            strength: strength,
                            description: description
                        )
                        dataManager.addRelationship(to: character, relationship: relationship)
                        dismiss()
                    }
                    .disabled(characterName.isEmpty)
                }
            }
        }
    }
}

struct EditCharacterView: View {
    let character: Character
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var race: String
    @State private var characterClass: String
    @State private var level: Int
    @State private var description: String
    @State private var notes: String
    
    init(character: Character) {
        self.character = character
        self._name = State(initialValue: character.name)
        self._race = State(initialValue: character.race)
        self._characterClass = State(initialValue: character.class)
        self._level = State(initialValue: character.level)
        self._description = State(initialValue: character.description)
        self._notes = State(initialValue: character.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Имя", text: $name)
                    TextField("Раса", text: $race)
                    TextField("Класс", text: $characterClass)
                    Stepper("Уровень: \(level)", value: $level, in: 1...20)
                }
                
                Section("Описание") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
                
                Section("Заметки") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Изменить персонажа")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        var updatedCharacter = character
                        updatedCharacter.name = name
                        updatedCharacter.race = race
                        updatedCharacter.class = characterClass
                        updatedCharacter.level = level
                        updatedCharacter.description = description
                        updatedCharacter.notes = notes
                        
                        dataManager.updateCharacter(updatedCharacter)
                        dismiss()
                    }
                    .disabled(name.isEmpty || race.isEmpty || characterClass.isEmpty)
                }
            }
        }
    }
}

#Preview {
    CharactersView()
        .environmentObject(DataManager())
}
