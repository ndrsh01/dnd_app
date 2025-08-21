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
    var dateCreated: Date
    var dateModified: Date
}

// MARK: - Store

@MainActor
final class NotesStore: ObservableObject {
    @Published var notes: [Note] = []

    private let key = "notes_v1"
    private let cacheManager = CacheManager.shared
    private var saveWorkItem: DispatchWorkItem?
    private var lastSavedData: Data?
    private(set) var saveCallCount = 0

    init() {
        load()
        lastSavedData = try? JSONEncoder().encode(notes)
    }

    func add(_ note: Note) {
        notes.append(note)
        scheduleSave()
    }

    func remove(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        scheduleSave()
    }

    func remove(note: Note) {
        if let idx = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: idx)
            scheduleSave()
        }
    }

    func update(_ note: Note) {
        if let idx = notes.firstIndex(where: { $0.id == note.id }) {
            notes[idx] = note
            scheduleSave()
        }
    }

    func notesByCategory(_ category: NoteCategory) -> [Note] {
        return notes.filter { $0.category == category }
    }



    private func scheduleSave() {
        saveWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.save()
        }
        saveWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(notes)
            guard data != lastSavedData else { return }
            UserDefaults.standard.set(data, forKey: key)
            cacheManager.cacheNotes(notes)
            lastSavedData = data
            saveCallCount += 1
        } catch {
            print("❌ Failed to encode notes: \(error)")
        }
    }

    private func load() {
        if let cachedNotes = cacheManager.getCachedNotes() {
            notes = cachedNotes
            lastSavedData = try? JSONEncoder().encode(notes)
            return
        }

        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            notes = try JSONDecoder().decode([Note].self, from: data)
            cacheManager.cacheNotes(notes)
            lastSavedData = data
        } catch {
            print("❌ Failed to decode notes: \(error)")
        }
    }
}

// MARK: - Notes View

struct NotesView: View {
    @StateObject private var store = NotesStore()
    @State private var showingAdd = false
    @State private var selectedCategory: NoteCategory? = nil
    @State private var searchText = ""
    @State private var showingEmptyState = false
    
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
        
        // Сортировка по дате изменения (новые сверху)
        return notes.sorted { $0.dateModified > $1.dateModified }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Фон
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
                    // Поисковая панель
                    SearchPanel(
                        searchText: $searchText,
                        selectedCategory: $selectedCategory
                    )
                    
                    // Контент
                    if filteredNotes.isEmpty {
                        EmptyStateView(
                            searchText: searchText,
                            selectedCategory: selectedCategory,
                            onAddNote: { showingAdd = true }
                        )
                    } else {
                        NotesGridView(
                            notes: filteredNotes,
                            store: store,
                            onDelete: { note in
                                store.remove(note: note)
                            }
                        )
                    }
                }
            }
            .navigationTitle("Заметки")
            .navigationBarTitleDisplayMode(.large)
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
}

// MARK: - Search Panel

struct SearchPanel: View {
    @Binding var searchText: String
    @Binding var selectedCategory: NoteCategory?
    
    var body: some View {
        VStack(spacing: 16) {
            // Поиск
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Поиск заметок...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal)
            .padding(.top)
            
            // Фильтры и сортировка
            HStack {
                // Категории
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryButton(
                            title: "Все",
                            icon: "list.bullet",
                            color: .orange,
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }
                        
                        ForEach(NoteCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                title: category.rawValue,
                                icon: category.icon,
                                color: category.color,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                

            }
        }
    }
}

// MARK: - Category Button

struct CategoryButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isSelected ? 
                            LinearGradient(colors: [color, color.opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground)], startPoint: .leading, endPoint: .trailing)
                    )
                    .stroke(isSelected ? Color.clear : color.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(isSelected ? .white : color)
            .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        }
    }
}



// MARK: - Empty State

struct EmptyStateView: View {
    let searchText: String
    let selectedCategory: NoteCategory?
    let onAddNote: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Иконка
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: searchText.isEmpty ? "note.text" : "magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
            }
            
            // Текст
            VStack(spacing: 8) {
                Text(searchText.isEmpty ? "Нет заметок" : "Ничего не найдено")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(searchText.isEmpty ? 
                     "Добавьте свою первую заметку для отслеживания важной информации" :
                     "Попробуйте изменить поисковый запрос или фильтры")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

// MARK: - Notes Grid

struct NotesGridView: View {
    let notes: [Note]
    let store: NotesStore
    let onDelete: (Note) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(notes) { note in
                    ModernNoteCard(note: note, store: store, onDelete: onDelete)
                }
            }
            .padding()
        }
    }
}

// MARK: - Modern Note Card

struct ModernNoteCard: View {
    let note: Note
    let store: NotesStore
    let onDelete: (Note) -> Void
    
    @State private var showingDetail = false
    @State private var showingEdit = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(alignment: .leading, spacing: 12) {
                // Заголовок и категория
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: note.category.icon)
                                .foregroundColor(note.category.color)
                                .font(.title3)
                            
                            Text(note.title)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
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
                }
                
                // Описание
                Text(note.description.parseMarkdown())
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                // Дата изменения
                HStack {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(note.dateModified, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Кнопки действий
                    HStack(spacing: 8) {
                        Button(action: { showingEdit = true }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title3)
                                .foregroundColor(.orange)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { onDelete(note) }) {
                            Image(systemName: "trash.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            NoteDetailView(note: note, store: store)
        }
        .sheet(isPresented: $showingEdit) {
            EditNoteView(note: note, store: store)
        }
    }
}

// MARK: - Note Detail View

struct NoteDetailView: View {
    let note: Note
    let store: NotesStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Заголовок
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: note.category.icon)
                                .font(.title)
                                .foregroundColor(note.category.color)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text(note.category.rawValue)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                            .fill(note.category.color.opacity(0.15))
                        )
                                    .foregroundColor(note.category.color)
                            }
                        
                        Spacer()
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    
                    // Описание
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Описание")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(note.description.parseMarkdown())
                            .foregroundColor(.primary)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                    }
                    
                    // Метаданные
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Информация")
                            .font(.headline)
                                .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                    .foregroundColor(.orange)
                                Text("Создано:")
                                Spacer()
                                Text(note.dateCreated, style: .date)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.orange)
                                Text("Изменено:")
                                Spacer()
                                Text(note.dateModified, style: .date)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .font(.subheadline)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
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
            .navigationTitle("Заметка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Редактировать") { showingEdit = true }
                        .foregroundColor(.orange)
                }
            }
            .sheet(isPresented: $showingEdit) {
                EditNoteView(note: note, store: store)
            }
        }
    }
}

// MARK: - Edit Note View

struct EditNoteView: View {
    let note: Note
    let store: NotesStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var selectedCategory: NoteCategory
    
    init(note: Note, store: NotesStore) {
        self.note = note
        self.store = store
        self._title = State(initialValue: note.title)
        self._description = State(initialValue: note.description)
        self._selectedCategory = State(initialValue: note.category)
    }
    
    var body: some View {
        NavigationStack {
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
                    }
                    
                    // Категория
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Категория")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
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
                        
                        Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
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
            .navigationTitle("Редактирование")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveChanges()
                        dismiss()
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                    .foregroundColor(title.isEmpty || description.isEmpty ? .gray : .orange)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    @MainActor
    private func saveChanges() {
        var updatedNote = note
        updatedNote.title = title
        updatedNote.description = description
        updatedNote.category = selectedCategory
        updatedNote.dateModified = Date()
        
        store.update(updatedNote)
    }
}

// MARK: - Add Note View

struct AddNoteView: View {
    let store: NotesStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: NoteCategory = .places
    
    var body: some View {
        NavigationStack {
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
                        }
                        
                        // Категория
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Категория")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
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
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
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
            .navigationTitle("Новая заметка")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        addNote()
                        dismiss()
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
            dateCreated: Date(),
            dateModified: Date()
        )
        
        store.add(note)
    }
}
