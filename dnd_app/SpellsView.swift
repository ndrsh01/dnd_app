import SwiftUI

struct SpellsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddSpell = false
    @State private var selectedSpell: Spell?
    @State private var searchText = ""
    @State private var selectedLevel: Int? = nil
    
    var filteredSpells: [Spell] {
        var spells = dataManager.spells
        
        if !searchText.isEmpty {
            spells = spells.filter { spell in
                spell.name.localizedCaseInsensitiveContains(searchText) ||
                spell.school.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let level = selectedLevel {
            spells = spells.filter { $0.level == level }
        }
        
        return spells
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter
                VStack(spacing: 12) {
                    SearchBar(text: $searchText, placeholder: "Поиск заклинаний...")
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterButton(title: "Все", isSelected: selectedLevel == nil) {
                                selectedLevel = nil
                            }
                            
                            ForEach(0...9, id: \.self) { level in
                                FilterButton(
                                    title: level == 0 ? "Заговоры" : "\(level) уровень",
                                    isSelected: selectedLevel == level
                                ) {
                                    selectedLevel = level
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                // Spells List
                List {
                    ForEach(filteredSpells) { spell in
                        SpellRow(spell: spell) {
                            selectedSpell = spell
                        }
                    }
                    .onDelete(perform: deleteSpells)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Заклинания")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSpell = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSpell) {
                AddSpellView()
                    .environmentObject(dataManager)
            }
            .sheet(item: $selectedSpell) { spell in
                SpellDetailView(spell: spell)
                    .environmentObject(dataManager)
            }
        }
    }
    
    private func deleteSpells(offsets: IndexSet) {
        for index in offsets {
            dataManager.removeSpell(filteredSpells[index])
        }
    }
}

struct SpellRow: View {
    let spell: Spell
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(spell.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if spell.isPrepared {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    
                    HStack {
                        Text(spell.school)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(spell.level == 0 ? "Заговор" : "\(spell.level) уровень")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(spell.castingTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(spell.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
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

struct SpellDetailView: View {
    let spell: Spell
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Spell Header
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(spell.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text(spell.school)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(spell.level == 0 ? "Заговор" : "\(spell.level) уровень")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                
                                if spell.isPrepared {
                                    Text("Подготовлено")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Spell Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(title: "Время накладывания", value: spell.castingTime)
                        DetailRow(title: "Дистанция", value: spell.range)
                        DetailRow(title: "Компоненты", value: spell.components.joined(separator: ", "))
                        DetailRow(title: "Длительность", value: spell.duration)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Описание")
                                .font(.headline)
                            
                            Text(spell.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Детали заклинания")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(spell.isPrepared ? "Отменить подготовку" : "Подготовить") {
                        dataManager.toggleSpellPrepared(spell)
                    }
                    .foregroundColor(spell.isPrepared ? .red : .green)
                }
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.orange : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddSpellView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var level = 1
    @State private var school = ""
    @State private var castingTime = ""
    @State private var range = ""
    @State private var components: [String] = []
    @State private var duration = ""
    @State private var description = ""
    @State private var newComponent = ""
    
    private let schools = ["Воплощение", "Прорицание", "Преобразование", "Иллюзия", "Некромантия", "Воплощение"]
    private let componentTypes = ["В", "С", "М"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Название", text: $name)
                    
                    Stepper("Уровень: \(level)", value: $level, in: 0...9)
                    
                    Picker("Школа", selection: $school) {
                        ForEach(schools, id: \.self) { school in
                            Text(school).tag(school)
                        }
                    }
                }
                
                Section("Характеристики") {
                    TextField("Время накладывания", text: $castingTime)
                    TextField("Дистанция", text: $range)
                    TextField("Длительность", text: $duration)
                }
                
                Section("Компоненты") {
                    ForEach(components, id: \.self) { component in
                        Text(component)
                    }
                    .onDelete(perform: deleteComponents)
                    
                    HStack {
                        TextField("Новый компонент", text: $newComponent)
                        Button("Добавить") {
                            if !newComponent.isEmpty {
                                components.append(newComponent)
                                newComponent = ""
                            }
                        }
                        .disabled(newComponent.isEmpty)
                    }
                }
                
                Section("Описание") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Новое заклинание")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        let spell = Spell(
                            name: name,
                            level: level,
                            school: school,
                            castingTime: castingTime,
                            range: range,
                            components: components,
                            duration: duration,
                            description: description
                        )
                        dataManager.addSpell(spell)
                        dismiss()
                    }
                    .disabled(name.isEmpty || school.isEmpty || castingTime.isEmpty || range.isEmpty || duration.isEmpty)
                }
            }
        }
    }
    
    private func deleteComponents(offsets: IndexSet) {
        components.remove(atOffsets: offsets)
    }
}

#Preview {
    SpellsView()
        .environmentObject(DataManager())
}
