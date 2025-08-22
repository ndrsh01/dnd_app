import SwiftUI
import UniformTypeIdentifiers

struct CharacterSelectionView: View {
    @ObservedObject var characterStore: CharacterStore
    @Binding var isPresented: Bool
    @State private var showCharacterCreation = false
    @State private var isImporting = false
    @State private var isExporting = false
    @State private var showImportSuccess = false
    @State private var showImportError = false
    @State private var importMessage = ""
    @State private var searchText = ""
    @State private var editingCharacter: Character?

    private var filteredCharacters: [Character] {
        characterStore.filteredCharacters(searchText: searchText)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Заголовок
                VStack(spacing: 8) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Выберите персонажа")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("или создайте нового")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                
                // Список персонажей
                if characterStore.characters.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("У вас пока нет персонажей")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Создайте первого персонажа, чтобы начать")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredCharacters) { character in
                            CharacterCardView(
                                character: character,
                                isSelected: characterStore.selectedCharacter?.id == character.id
                            ) {
                                characterStore.selectedCharacter = character
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    editingCharacter = character
                                } label: {
                                    Label("Изменить", systemImage: "pencil")
                                }

                                Button {
                                    characterStore.duplicate(character)
                                } label: {
                                    Label("Дублировать", systemImage: "doc.on.doc")
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    characterStore.remove(character: character)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .searchable(text: $searchText, prompt: "Поиск персонажей")
                }
                
                Spacer()
                
                // Кнопки действий
                VStack(spacing: 12) {
                    if let selected = characterStore.selectedCharacter {
                        Button(action: {
                            isPresented = false
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Играть за \(selected.name)")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        showCharacterCreation = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Создать нового персонажа")
                        }
                        .font(.headline)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
                    .background(
            LinearGradient(
                colors: [
                    Color("BackgroundColor"),
                    Color("BackgroundColor").opacity(0.8),
                    Color("BackgroundColor")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .navigationTitle("Персонажи")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Закрыть") {
                    isPresented = false
                }
                .foregroundColor(.orange)
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { isImporting = true }) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                
                Button(action: { isExporting = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
        }
        .sheet(isPresented: $showCharacterCreation) {
            CharacterCreationView(characterStore: characterStore)
        }
        .sheet(item: $editingCharacter) { character in
            CharacterEditorView(store: characterStore, character: character)
        }
        .fileExporter(
            isPresented: $isExporting,
            document: CharacterExportDocument(characters: characterStore.characters),
            contentType: .json,
            defaultFilename: "characters"
        ) { result in
            switch result {
            case .success(let url):
                print("Персонажи экспортированы в: \(url)")
            case .failure(let error):
                print("Ошибка экспорта: \(error)")
            }
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
            do {
                let url = try result.get()
                
                // Начинаем доступ к безопасности
                guard url.startAccessingSecurityScopedResource() else {
                    print("❌ Не удалось получить доступ к файлу")
                    showImportError = true
                    importMessage = "Не удалось получить доступ к файлу"
                    return
                }
                
                defer {
                    url.stopAccessingSecurityScopedResource()
                }
                
                let data = try Data(contentsOf: url)
                let jsonString = String(data: data, encoding: .utf8) ?? ""
                
                var importedCount = 0
                
                // Попробуем импортировать как массив персонажей
                if let importedCharacters = try? JSONDecoder().decode([Character].self, from: data) {
                    for character in importedCharacters {
                        characterStore.add(character)
                        importedCount += 1
                    }
                    print("✅ Импортировано персонажей из массива: \(importedCount)")
                }
                // Попробуем импортировать как одного персонажа
                else if let importedCharacter = try? JSONDecoder().decode(Character.self, from: data) {
                    characterStore.add(importedCharacter)
                    importedCount = 1
                    print("✅ Импортирован персонаж: \(importedCharacter.name)")
                }
                // Попробуем импортировать как JSON из внешнего источника
                else if let externalCharacter = characterStore.importCharacterFromJSON(jsonString) {
                    characterStore.add(externalCharacter)
                    importedCount = 1
                    print("✅ Импортирован персонаж из внешнего JSON: \(externalCharacter.name)")
                }
                else {
                    print("❌ Ошибка: Неверный формат файла. Файл должен содержать персонажа или массив персонажей в JSON формате.")
                    showImportError = true
                }
                
                if importedCount > 0 {
                    showImportSuccess = true
                    importMessage = "Успешно импортировано персонажей: \(importedCount)"
                }
                
            } catch {
                print("❌ Ошибка импорта: \(error)")
                showImportError = true
                
                // Более подробное сообщение об ошибке
                if let nsError = error as NSError? {
                    switch nsError.code {
                    case NSFileReadNoPermissionError:
                        importMessage = "Нет прав доступа к файлу. Попробуйте выбрать файл из другого места."
                    case NSFileReadNoSuchFileError:
                        importMessage = "Файл не найден."
                    case NSFileReadCorruptFileError:
                        importMessage = "Файл поврежден или имеет неверный формат."
                    default:
                        importMessage = "Ошибка чтения файла: \(error.localizedDescription)"
                    }
                } else {
                    importMessage = "Ошибка чтения файла: \(error.localizedDescription)"
                }
            }
        }
        .alert("Импорт успешен", isPresented: $showImportSuccess) {
            Button("OK") { }
        } message: {
            Text(importMessage)
        }
        .alert("Ошибка импорта", isPresented: $showImportError) {
            Button("OK") { }
        } message: {
            Text(importMessage)
        }
        }
    }
    
}

struct CharacterCardView: View {
    let character: Character
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Аватар персонажа
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.orange)
                }
                
                // Информация о персонаже
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("\(character.race) • \(character.characterClass)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text("Уровень \(character.level)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Статистика
                VStack(alignment: .trailing, spacing: 4) {
                    Text("HP: \(character.currentHitPoints)/\(character.maxHitPoints)")
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Text("КЗ: \(character.armorClass)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Индикатор выбора
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Character Export Document

struct CharacterExportDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.json]
    
    let characters: [Character]
    
    init(characters: [Character]) {
        self.characters = characters
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        characters = try JSONDecoder().decode([Character].self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(characters)
        return FileWrapper(regularFileWithContents: data)
    }
}



