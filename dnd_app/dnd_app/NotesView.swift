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

@MainActor
final class NotesStore: ObservableObject {
    @Published var notes: [Note] = [] {
        didSet { save() }
    }

    private let key = "notes_v1"
    private let cacheManager = CacheManager.shared

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
            // Обновляем кэш
            cacheManager.cacheNotes(notes)
        } catch {
            print("❌ Failed to encode notes: \(error)")
        }
    }
    
    private func load() {
        // Сначала пытаемся загрузить из кэша
        if let cachedNotes = cacheManager.getCachedNotes() {
            notes = cachedNotes
            print("✅ [NOTES] Загружено \(cachedNotes.count) заметок из кэша")
            return
        }
        
        // Если кэша нет, загружаем из UserDefaults
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            notes = try JSONDecoder().decode([Note].self, from: data)
            // Кэшируем заметки
            cacheManager.cacheNotes(notes)
            print("✅ [NOTES] Загружено \(notes.count) заметок из UserDefaults и закэшировано")
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
                        Color("BackgroundColor"),
                        Color("BackgroundColor").opacity(0.9),
                        Color("BackgroundColor")
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
                            }
                            .onDelete(perform: deleteNotes)
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle("Заметки")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddNoteView(store: store)
            }
        }
    }
    
    private func deleteNotes(at offsets: IndexSet) {
        store.remove(at: offsets)
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
        VStack(alignment: .leading, spacing: 0) {
            if isEditing {
                // Режим редактирования
                VStack(alignment: .leading, spacing: 16) {
                    // Заголовок
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Название")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        TextField("Введите название", text: $editedTitle)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                            .submitLabel(.done)
                            .onSubmit {
                                // Скрываем клавиатуру при нажатии "Готово"
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                    }
                    
                    // Описание
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Описание")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $editedDescription)
                            .font(.body)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                            .frame(minHeight: 100)
                            .submitLabel(.done)
                            .onSubmit {
                                // Скрываем клавиатуру при нажатии "Готово"
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                    }
                    
                    // Категория и важность
                    HStack(spacing: 16) {
                        // Категория
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Категория")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
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
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(editedCategory.color.opacity(0.15))
                                        .stroke(editedCategory.color.opacity(0.3), lineWidth: 1)
                                )
                                .foregroundColor(editedCategory.color)
                            }
                        }
                        
                        // Важность
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Важность")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                ForEach(1...Note.maxImportance, id: \.self) { star in
                                    Button(action: { 
                                        editedImportance = star
                                        print("⭐ [NOTES] Установлена важность: \(star) для заметки: \(note.title)")
                                    }) {
                                        Image(systemName: star <= editedImportance ? "star.fill" : "star")
                                            .foregroundColor(star <= editedImportance ? .yellow : .gray)
                                            .font(.title3)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }
                    
                    // Кнопки
                    HStack(spacing: 12) {
                        Button(action: {
                            print("🔄 [NOTES] Нажата кнопка 'Отмена' для заметки: \(note.title)")
                            print("🔄 [NOTES] Текущее состояние: isEditing=\(isEditing)")
                            
                            // Сброс изменений
                            editedTitle = note.title
                            editedDescription = note.description
                            editedCategory = note.category
                            editedImportance = note.importance
                            
                            print("🔄 [NOTES] Изменения сброшены")
                            
                            // Выход из режима редактирования
                            isEditing = false
                            print("🔄 [NOTES] Режим редактирования отключен")
                        }) {
                            Text("Отмена")
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray5))
                        )
                        .foregroundColor(.secondary)
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        Button(action: {
                            print("💾 [NOTES] Нажата кнопка 'Сохранить' для заметки: \(note.title)")
                            print("💾 [NOTES] Текущее состояние: isEditing=\(isEditing)")
                            print("💾 [NOTES] Новые значения: title=\(editedTitle), importance=\(editedImportance)")
                            
                            // Создание обновленной заметки
                            var updatedNote = note
                            updatedNote.title = editedTitle
                            updatedNote.description = editedDescription
                            updatedNote.category = editedCategory
                            updatedNote.importance = editedImportance
                            updatedNote.dateModified = Date()
                            
                            // Сохранение в store
                            store.update(updatedNote)
                            print("💾 [NOTES] Изменения сохранены: title=\(updatedNote.title), importance=\(updatedNote.importance)")
                            
                            // Выход из режима редактирования
                            isEditing = false
                            print("💾 [NOTES] Режим редактирования отключен")
                        }) {
                            Text("Сохранить")
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .foregroundColor(.white)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else {
                // Режим просмотра
                VStack(alignment: .leading, spacing: 12) {
                    // Заголовок и кнопка редактирования
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: note.category.icon)
                                    .foregroundColor(note.category.color)
                                    .font(.title3)
                                
                                Text(note.title)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .lineLimit(2)
                            }
                            
                            Text(note.category.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(note.category.color.opacity(0.15))
                                )
                                .foregroundColor(note.category.color)
                        }
                        
                        Spacer()
                        
                        // Кнопка редактирования в стиле карточки персонажа
                        Button(action: { isEditing = true }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .allowsHitTesting(true)
                        .contentShape(Rectangle())
                    }
                    
                    // Описание
                    Text(note.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(4)
                    
                    // Важность внизу карточки
                    HStack(spacing: 2) {
                        ForEach(1...Note.maxImportance, id: \.self) { star in
                            Image(systemName: star <= note.importance ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(star <= note.importance ? .yellow : .gray)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    @MainActor
    private func resetEditing() {
        print("🔄 [NOTES] Сброс изменений заметки: \(note.title)")
        print("🔄 [NOTES] Текущие значения: title=\(editedTitle), importance=\(editedImportance)")
        
        editedTitle = note.title
        editedDescription = note.description
        editedCategory = note.category
        editedImportance = note.importance
        
        print("✅ [NOTES] Изменения сброшены: title=\(editedTitle), importance=\(editedImportance)")
    }
    
    @MainActor
    private func saveChanges() {
        print("💾 [NOTES] Сохранение изменений заметки: \(note.title)")
        print("💾 [NOTES] Новые значения: title=\(editedTitle), importance=\(editedImportance)")
        
        var updatedNote = note
        updatedNote.title = editedTitle
        updatedNote.description = editedDescription
        updatedNote.category = editedCategory
        updatedNote.importance = editedImportance
        updatedNote.dateModified = Date()
        
        store.update(updatedNote)
        print("✅ [NOTES] Изменения сохранены: title=\(updatedNote.title), importance=\(updatedNote.importance)")
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
                LinearGradient(
                    colors: [
                        Color("BackgroundColor"),
                        Color("BackgroundColor").opacity(0.9),
                        Color("BackgroundColor")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Название
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Название")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            TextField("Введите название заметки", text: $title)
                                .font(.title3)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                                .submitLabel(.done)
                                .onSubmit {
                                    // Скрываем клавиатуру при нажатии "Готово"
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                        }
                        
                        // Описание
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Описание")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            TextEditor(text: $description)
                                .font(.body)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                                .frame(minHeight: 120)
                                .submitLabel(.done)
                                .onSubmit {
                                    // Скрываем клавиатуру при нажатии "Готово"
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                        }
                        
                        // Категория
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Категория")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(NoteCategory.allCases, id: \.self) { category in
                                    Button(action: { selectedCategory = category }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: category.icon)
                                                .font(.title2)
                                                .foregroundColor(selectedCategory == category ? .white : category.color)
                                            
                                            Text(category.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedCategory == category ? 
                                                      LinearGradient(colors: [category.color, category.color.opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                                                      LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground)], startPoint: .leading, endPoint: .trailing)
                                                )
                                                .stroke(selectedCategory == category ? Color.clear : category.color.opacity(0.3), lineWidth: 1)
                                        )
                                        .shadow(color: selectedCategory == category ? category.color.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                        }
                        
                        // Важность
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Важность")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    HStack(spacing: 8) {
                                        ForEach(1...Note.maxImportance, id: \.self) { star in
                                            Button(action: { importance = star }) {
                                                Image(systemName: star <= importance ? "star.fill" : "star")
                                                    .font(.title2)
                                                    .foregroundColor(star <= importance ? .yellow : .gray)
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(importance)/\(Note.maxImportance)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(.systemGray6))
                                        )
                                }
                                
                                Slider(value: Binding(
                                    get: { Double(importance) },
                                    set: { importance = Int($0) }
                                ), in: 1...Double(Note.maxImportance), step: 1)
                                .accentColor(.orange)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Новая заметка")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        addNote()
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                    .foregroundColor(title.isEmpty || description.isEmpty ? .gray : .orange)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    @MainActor
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
