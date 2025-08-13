import SwiftUI

// MARK: - Models

enum NoteCategory: String, CaseIterable, Codable {
    case places = "Места"
    case people = "Люди"
    case enemies = "Враги"
    case items = "Вещи"
    case artifacts = "Артефакты"
    
    var icon: String {
        switch self {
        case .places: return "mappin.circle.fill"
        case .people: return "person.2.circle.fill"
        case .enemies: return "exclamationmark.triangle.fill"
        case .items: return "cube.box.fill"
        case .artifacts: return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .places: return .blue
        case .people: return .green
        case .enemies: return .red
        case .items: return .orange
        case .artifacts: return .purple
        }
    }
}

struct Note: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var category: NoteCategory
    var importance: Int // 1-5 звезд
    var dateCreated: Date
    var dateModified: Date
    
    static let maxImportance = 5
}

// MARK: - Store

final class NotesStore: ObservableObject {
    @Published var notes: [Note] = [] {
        didSet { save() }
    }
    
    private let key = "notes_v1"
    
    init() {
        load()

    }
    
    func add(_ note: Note) { notes.append(note) }
    func remove(at offsets: IndexSet) { notes.remove(atOffsets: offsets) }
    func remove(note: Note) {
        if let idx = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: idx)
        }
    }
    func update(_ note: Note) {
        if let idx = notes.firstIndex(where: { $0.id == note.id }) {
            notes[idx] = note
        }
    }
    
    func notesByCategory(_ category: NoteCategory) -> [Note] {
        return notes.filter { $0.category == category }
    }
    
    func notesByImportance(_ importance: Int) -> [Note] {
        return notes.filter { $0.importance == importance }
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("❌ Failed to encode notes: \(error)")
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            notes = try JSONDecoder().decode([Note].self, from: data)
        } catch {
            print("❌ Failed to decode notes: \(error)")
        }
    }
}

// MARK: - Views

struct NotesView: View {
    @StateObject private var store = NotesStore()
    @StateObject private var themeManager = ThemeManager()
    @State private var showingAdd = false
    @State private var selectedCategory: NoteCategory? = nil
    @State private var searchText = ""
    
    var filteredNotes: [Note] {
        var notes = store.notes
        
        // Фильтр по поиску
        if !searchText.isEmpty {
            notes = notes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Фильтр по категории
        if let category = selectedCategory {
            notes = notes.filter { $0.category == category }
        }
        
        // Сортировка по важности (от высокой к низкой)
        return notes.sorted { $0.importance > $1.importance }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#fceeda"),
                        Color(hex: "#fceeda").opacity(0.9),
                        Color(hex: "#fceeda")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Поиск
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Поиск заметок...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .stroke(
                                LinearGradient(
                                    colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Категории
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Кнопка "Все"
                            Button(action: {
                                selectedCategory = nil
                            }) {
                                HStack {
                                    Image(systemName: "list.bullet")
                                    Text("Все")
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        colors: selectedCategory == nil ? 
                                            [Color.orange, Color.orange.opacity(0.8)] : 
                                            [Color(.systemGray5), Color(.systemGray5)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(selectedCategory == nil ? .white : .primary)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                            
                            // Категории
                            ForEach(NoteCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }) {
                                    HStack {
                                        Image(systemName: category.icon)
                                        Text(category.rawValue)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        LinearGradient(
                                            colors: selectedCategory == category ? 
                                                [category.color, category.color.opacity(0.8)] : 
                                                [Color(.systemGray5), Color(.systemGray5)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    
                    // Список заметок
                    if filteredNotes.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "note.text")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("Нет заметок")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Добавьте свою первую заметку")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(filteredNotes) { note in
                                NoteCard(note: note, store: store)
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .padding(.vertical, 4)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            deleteNote(note)
                                        } label: {
                                            Label("Удалить", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                    }
                }
            }
            .navigationTitle("📝 Заметки")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddNoteView(store: store)
            }
        }
    }
    
    private func deleteNote(_ note: Note) {
        store.remove(note: note)
    }
}

// MARK: - Components

struct NoteCard: View {
    let note: Note
    let store: NotesStore
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedDescription: String
    @State private var editedCategory: NoteCategory
    @State private var editedImportance: Int
    
    init(note: Note, store: NotesStore) {
        self.note = note
        self.store = store
        self._editedTitle = State(initialValue: note.title)
        self._editedDescription = State(initialValue: note.description)
        self._editedCategory = State(initialValue: note.category)
        self._editedImportance = State(initialValue: note.importance)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isEditing {
                // Режим редактирования
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Название", text: $editedTitle)
                        .font(.headline)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Описание", text: $editedDescription, axis: .vertical)
                        .lineLimit(3...10)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(minHeight: 80)
                    
                    // Категория
                    HStack {
                        Text("Категория:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(NoteCategory.allCases, id: \.self) { category in
                                Button(action: { editedCategory = category }) {
                                    HStack {
                                        Image(systemName: category.icon)
                                        Text(category.rawValue)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: editedCategory.icon)
                                Text(editedCategory.rawValue)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(editedCategory.color.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Важность
                    HStack {
                        Text("Важность:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            ForEach(1...Note.maxImportance, id: \.self) { star in
                                Button(action: { editedImportance = star }) {
                                    Image(systemName: star <= editedImportance ? "star.fill" : "star")
                                        .foregroundColor(star <= editedImportance ? .yellow : .gray)
                                }
                            }
                        }
                    }
                    
                    // Кнопки
                    HStack {
                        Button("Отмена") {
                            isEditing = false
                            resetEditing()
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Сохранить") {
                            saveChanges()
                            isEditing = false
                        }
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                    }
                }
            } else {
                // Режим просмотра
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: note.category.icon)
                            .foregroundColor(note.category.color)
                        
                        Text(note.title)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Звезды важности
                        HStack(spacing: 2) {
                            ForEach(1...Note.maxImportance, id: \.self) { star in
                                Image(systemName: star <= note.importance ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundColor(star <= note.importance ? .yellow : .gray)
                            }
                        }
                    }
                    
                    Text(note.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    
                    HStack {
                        Button("Редактировать") {
                            isEditing = true
                        }
                        .font(.caption)
                        .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Text(note.category.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(note.category.color.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func resetEditing() {
        editedTitle = note.title
        editedDescription = note.description
        editedCategory = note.category
        editedImportance = note.importance
    }
    
    private func saveChanges() {
        var updatedNote = note
        updatedNote.title = editedTitle
        updatedNote.description = editedDescription
        updatedNote.category = editedCategory
        updatedNote.importance = editedImportance
        updatedNote.dateModified = Date()
        
        store.update(updatedNote)
    }
}

struct AddNoteView: View {
    let store: NotesStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: NoteCategory = .places
    @State private var importance = 3
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#fceeda")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Название
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Название")
                            .font(.headline)
                        
                        TextField("Введите название", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Описание
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Описание")
                            .font(.headline)
                        
                        TextField("Введите описание", text: $description, axis: .vertical)
                            .lineLimit(3...10)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(minHeight: 80)
                    }
                    
                    // Категория
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Категория")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(NoteCategory.allCases, id: \.self) { category in
                                Button(action: { selectedCategory = category }) {
                                    HStack {
                                        Image(systemName: category.icon)
                                        Text(category.rawValue)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedCategory == category ? 
                                                  LinearGradient(colors: [category.color, category.color.opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                                                  LinearGradient(colors: [Color(.systemGray5), Color(.systemGray5)], startPoint: .leading, endPoint: .trailing)
                                            )
                                    )
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                }
                            }
                        }
                    }
                    
                    // Важность
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Важность")
                            .font(.headline)
                        
                        HStack {
                            HStack(spacing: 4) {
                                ForEach(1...Note.maxImportance, id: \.self) { star in
                                    Image(systemName: star <= importance ? "star.fill" : "star")
                                        .foregroundColor(star <= importance ? .yellow : .gray)
                                        .onTapGesture {
                                            importance = star
                                        }
                                }
                            }
                            
                            Spacer()
                            
                            Text("\(importance)/\(Note.maxImportance)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(importance) },
                            set: { importance = Int($0) }
                        ), in: 1...Double(Note.maxImportance), step: 1)
                        .accentColor(.orange)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Новая заметка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        addNote()
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private func addNote() {
        let note = Note(
            title: title,
            description: description,
            category: selectedCategory,
            importance: importance,
            dateCreated: Date(),
            dateModified: Date()
        )
        
        store.add(note)
        dismiss()
    }
}
