import SwiftUI
import PhotosUI

extension Notification.Name {
    static let saveCharacterChanges = Notification.Name("saveCharacterChanges")
}

struct CompactCharacterSheetView: View {
    let character: Character
    @ObservedObject var store: CharacterStore
    @ObservedObject var compendiumStore: CompendiumStore
    @State private var showingDetailSection: CharacterDetailSection?
    @Binding var isEditingMode: Bool
    let onSaveChanges: ((Character) -> Void)?
    
    init(character: Character, store: CharacterStore, compendiumStore: CompendiumStore, isEditingMode: Binding<Bool>, onSaveChanges: ((Character) -> Void)? = nil) {
        self.character = character
        self.store = store
        self.compendiumStore = compendiumStore
        self._isEditingMode = isEditingMode
        self.onSaveChanges = onSaveChanges
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let current = store.selectedCharacter {
                // Заголовок персонажа
                    CharacterHeaderCompactView(
                        character: current, 
                        store: store, 
                        compendiumStore: compendiumStore, 
                        isEditingMode: isEditingMode,
                        onSaveChanges: onSaveChanges
                    )
                
                // Хиты (отдельно)
                    HitPointsView(store: store, isEditingMode: isEditingMode)
                
                // Основные характеристики (компактно)
                    CompactStatsView(character: current, store: store, isEditingMode: isEditingMode)
                
                // Ссылки на детальные разделы
                DetailSectionsView(showingDetailSection: $showingDetailSection)
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
        .sheet(item: $showingDetailSection) { section in
            let current = store.selectedCharacter ?? character
            DetailSectionView(character: current, section: section, store: store, compendiumStore: compendiumStore)
        }
    }
}

struct CharacterHeaderCompactView: View {
    let character: Character
    @ObservedObject var store: CharacterStore
    @ObservedObject var compendiumStore: CompendiumStore
    let isEditingMode: Bool
    let onSaveChanges: ((Character) -> Void)?
    @State private var editingName = false
    @State private var newName = ""
    @State private var editingRace = false
    @State private var newRace = ""
    @State private var editingClass = false
    @State private var newClass = ""
    @State private var editingLevel = false
    @State private var newLevel = ""
    
    // Временные значения для редактирования
    @State private var tempCharacter: Character
    @State private var selectedClass = ""
    @State private var selectedBackground = ""
    @State private var selectedAlignment = ""
    @State private var showingImagePicker = false
    @State private var avatarImage: UIImage?
    @State private var availableClasses: [String] = []
    
    init(character: Character, store: CharacterStore, compendiumStore: CompendiumStore, isEditingMode: Bool, onSaveChanges: ((Character) -> Void)? = nil) {
        self.character = character
        self.store = store
        self.compendiumStore = compendiumStore
        self.isEditingMode = isEditingMode
        self.onSaveChanges = onSaveChanges
        self._tempCharacter = State(initialValue: character)
        self._availableClasses = State(initialValue: [])
    }
    
    private func loadClasses() {
        guard let url = Bundle.main.url(forResource: "classes", withExtension: "json") else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let classes = try JSONDecoder().decode([GameClass].self, from: data)
            availableClasses = classes.compactMap { $0.name != "Class" ? $0.name : nil }
        } catch {
            print("Error loading classes: \(error)")
            // Fallback to default classes
            availableClasses = [
                "Варвар", "Бард", "Волшебник", "Друид", "Жрец", 
                "Колдун", "Монах", "Паладин", "Плут", "Следопыт", "Чародей"
            ]
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Главная секция с аватаром и именем
            HStack(spacing: 20) {
                // Современный аватар с градиентом
                Button(action: {
                    if isEditingMode {
                        showingImagePicker = true
                    }
                }) {
                    ZStack {
                        // Градиентный фон
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.8),
                                        Color.orange.opacity(0.6),
                                        Color.yellow.opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        // Иконка персонажа или загруженное изображение
                        if let avatarImage = avatarImage {
                            Image(uiImage: avatarImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 76, height: 76)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        // Индикатор редактирования
                        if isEditingMode {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Image(systemName: "camera.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                }
                            }
                            .frame(width: 80, height: 80)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Информация о персонаже
                VStack(alignment: .leading, spacing: 8) {
                    // Имя персонажа
                    if isEditingMode {
                        TextField("Имя персонажа", text: $tempCharacter.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(character.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .onLongPressGesture(minimumDuration: 0.5) {
                                newName = character.name
                                editingName = true
                            }
                    }
                    
                    // Раса и класс с иконками
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "figure.walk")
                                .font(.caption)
                                .foregroundColor(.blue)
                            if isEditingMode {
                                TextField("Раса", text: Binding(
                                    get: { character.race },
                                    set: { newValue in
                                        var updatedCharacter = character
                                        updatedCharacter.race = newValue
                                        store.update(updatedCharacter)
                                    }
                                ))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            } else {
                                Text(character.race)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .onLongPressGesture(minimumDuration: 0.5) {
                                        newRace = character.race
                                        editingRace = true
                                    }
                            }
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "shield.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            if isEditingMode {
                                Picker("Класс", selection: $selectedClass) {
                                    Text("Выберите класс").tag("")
                                    ForEach(availableClasses, id: \.self) { className in
                                        Text(className).tag(className)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .accentColor(.primary)
                                .onAppear {
                                    selectedClass = character.displayClassName
                                    if availableClasses.isEmpty {
                                        loadClasses()
                                    }
                                }
                            } else {
                                Text(character.displayClassName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                                    .onLongPressGesture(minimumDuration: 0.5) {
                                        newClass = character.characterClass
                                        editingClass = true
                                    }
                            }
                        }
                    }
                    
                    // Уровень в красивом badge
                    HStack {
                        if isEditingMode {
                            HStack(spacing: 8) {
                                Button(action: {
                                    var updatedCharacter = character
                                    updatedCharacter.level = max(1, character.level - 1)
                                    store.update(updatedCharacter)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.orange)
                                        .font(.title3)
                                }
                                
                                Text("Уровень \(character.totalLevel > 0 ? character.totalLevel : character.level)")
                        .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.orange, .orange.opacity(0.8)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                                
                                Button(action: {
                                    var updatedCharacter = character
                                    updatedCharacter.level = min(20, character.level + 1)
                                    store.update(updatedCharacter)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.orange)
                                        .font(.title3)
                                }
                            }
                        } else {
                            Text("Уровень \(character.totalLevel > 0 ? character.totalLevel : character.level)")
                                .font(.caption)
                        .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            LinearGradient(
                                                colors: [.orange, .orange.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    newLevel = "\(character.level)"
                                    editingLevel = true
                                }
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Разделитель
            Divider()
                .padding(.horizontal, 20)
            
            // Дополнительная информация в современном стиле
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    EditableModernInfoItem(
                        icon: "person.circle", 
                        title: "Игрок", 
                        value: character.playerName, 
                        color: .blue,
                        isEditing: isEditingMode,
                        onValueChange: { newValue in
                            var updatedCharacter = character
                            updatedCharacter.playerName = newValue
                            store.update(updatedCharacter)
                        }
                    )
                    PickerModernInfoItem(
                        icon: "book.closed", 
                        title: "Предыстория", 
                        value: character.background, 
                        color: .purple,
                        isEditing: isEditingMode,
                        selectedValue: $selectedBackground,
                        options: [
                            ("", "Выберите предысторию"),
                            ("Аколит", "Аколит"),
                            ("Благородный", "Благородный"),
                            ("Гильдейский ремесленник", "Гильдейский ремесленник"),
                            ("Отшельник", "Отшельник"),
                            ("Пират", "Пират"),
                            ("Преступник", "Преступник"),
                            ("Солдат", "Солдат"),
                            ("Чужеземец", "Чужеземец"),
                            ("Шарлатан", "Шарлатан"),
                            ("Мудрец", "Мудрец")
                        ]
                    )
                }
                
                HStack(spacing: 16) {
                    PickerModernInfoItem(
                        icon: "balance.scale", 
                        title: "Мировоззрение", 
                        value: character.alignment, 
                        color: .indigo,
                        isEditing: isEditingMode,
                        selectedValue: $selectedAlignment,
                        options: [
                            ("", "Выберите мировоззрение"),
                            ("Законно-добрый", "Законно-добрый"),
                            ("Нейтрально-добрый", "Нейтрально-добрый"),
                            ("Хаотично-добрый", "Хаотично-добрый"),
                            ("Законно-нейтральный", "Законно-нейтральный"),
                            ("Нейтральный", "Нейтральный"),
                            ("Хаотично-нейтральный", "Хаотично-нейтральный"),
                            ("Законно-злой", "Законно-злой"),
                            ("Нейтрально-злой", "Нейтрально-злой"),
                            ("Хаотично-злой", "Хаотично-злой")
                        ]
                    )
                    EditableModernInfoItem(
                        icon: "star.circle", 
                        title: "Опыт", 
                        value: "\(character.experience)", 
                        color: .yellow,
                        isEditing: isEditingMode,
                        onValueChange: { newValue in
                            if let exp = Int(newValue) {
                                var updatedCharacter = character
                                updatedCharacter.experience = exp
                                store.update(updatedCharacter)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemBackground).opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .stroke(
                    LinearGradient(
                        colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .alert("Редактировать имя", isPresented: $editingName) {
            TextField("Имя персонажа", text: $newName)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    var updatedCharacter = character
                    updatedCharacter.name = newName
                    store.update(updatedCharacter)
                }
            }
        }
        .alert("Редактировать расу", isPresented: $editingRace) {
            TextField("Раса", text: $newRace)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if !newRace.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    var updatedCharacter = character
                    updatedCharacter.race = newRace
                    store.update(updatedCharacter)
                }
            }
        }
        .alert("Редактировать класс", isPresented: $editingClass) {
            TextField("Класс", text: $newClass)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if !newClass.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    var updatedCharacter = character
                    updatedCharacter.characterClass = newClass
                    store.update(updatedCharacter)
                }
            }
        }
        .alert("Редактировать уровень", isPresented: $editingLevel) {
            TextField("Уровень", text: $newLevel)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if let level = Int(newLevel), level > 0, level <= 20 {
                    var updatedCharacter = character
                    updatedCharacter.level = level
                    store.update(updatedCharacter)
                }
            }
        }
        .onChange(of: character) { newCharacter in
            tempCharacter = newCharacter
            selectedClass = newCharacter.displayClassName
            selectedBackground = newCharacter.background
            selectedAlignment = newCharacter.alignment
        }
        .onChange(of: selectedClass) { newClass in
            if !newClass.isEmpty {
                tempCharacter.characterClass = newClass
            }
        }
        .onChange(of: selectedBackground) { newBackground in
            tempCharacter.background = newBackground
        }
        .onChange(of: selectedAlignment) { newAlignment in
            tempCharacter.alignment = newAlignment
        }
        .onReceive(NotificationCenter.default.publisher(for: .saveCharacterChanges)) { _ in
            onSaveChanges?(tempCharacter)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $avatarImage)
        }
    }
}

struct ModernInfoItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // Иконка в цветном круге
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
            }
            
            // Текст
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                
                Text(value.isEmpty ? "—" : value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

struct EditableModernInfoItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let isEditing: Bool
    let onValueChange: (String) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Иконка в цветном круге
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
            }
            
            // Текст
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                
                if isEditing {
                    TextField("Введите значение", text: Binding(
                        get: { value },
                        set: { onValueChange($0) }
                    ))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                } else {
                    Text(value.isEmpty ? "—" : value)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

struct PickerModernInfoItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let isEditing: Bool
    @Binding var selectedValue: String
    let options: [(String, String)]
    
    var body: some View {
        VStack(spacing: 8) {
            // Иконка в цветном круге
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
            }
            
            // Текст
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                
                if isEditing {
                    Picker(title, selection: $selectedValue) {
                        ForEach(options, id: \.0) { option in
                            Text(option.1).tag(option.0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.primary)
                    .onAppear {
                        selectedValue = value
                    }
                } else {
                    Text(value.isEmpty ? "—" : value)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

struct InfoItemCompact: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value.isEmpty ? "—" : value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

struct HitPointsView: View {
    @ObservedObject var store: CharacterStore
    let isEditingMode: Bool
    @State private var showingHPEditor = false
    @State private var newHP = ""
    
    private var character: Character? { store.selectedCharacter }
    
    private var hpPercentage: Double {
        guard let c = character, c.maxHitPoints > 0 else { return 0 }
        return min(1.0, max(0.0, Double(c.currentHitPoints) / Double(c.maxHitPoints)))
    }
    
    private var hpColor: Color {
        switch hpPercentage {
        case 0.7...1.0: return .green
        case 0.3..<0.7: return .yellow
        default: return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Заголовок с иконкой
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.headline)
                        .foregroundColor(hpColor)
                Text("Хиты")
                    .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // Кликабельное значение HP
                if isEditingMode {
                    HStack(spacing: 8) {
                        Button(action: {
                            if let c = character {
                                var updatedCharacter = c
                                updatedCharacter.currentHitPoints = max(0, c.currentHitPoints - 1)
                                store.updateCharacterHitPoints(updatedCharacter, newCurrentHP: updatedCharacter.currentHitPoints)
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                        
                        HStack(spacing: 4) {
                            Text("\(character?.currentHitPoints ?? 0)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(hpColor)
                            
                            Text("/")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Text("\(character?.maxHitPoints ?? 0)")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(hpColor.opacity(0.1))
                                .stroke(hpColor.opacity(0.3), lineWidth: 2)
                        )
                        
                        Button(action: {
                            if let c = character {
                                var updatedCharacter = c
                                updatedCharacter.currentHitPoints = min(c.maxHitPoints, c.currentHitPoints + 1)
                                store.updateCharacterHitPoints(updatedCharacter, newCurrentHP: updatedCharacter.currentHitPoints)
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                    .font(.title2)
                        }
                    }
                } else {
                    Button(action: {
                        newHP = "\(character?.currentHitPoints ?? 0)"
                        showingHPEditor = true
                    }) {
                        HStack(spacing: 4) {
                            Text("\(character?.currentHitPoints ?? 0)")
                                .font(.title)
                    .fontWeight(.bold)
                                .foregroundColor(hpColor)
                            
                            Text("/")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Text("\(character?.maxHitPoints ?? 0)")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(hpColor.opacity(0.1))
                                .stroke(hpColor.opacity(0.3), lineWidth: 2)
                        )
                    }
                }
            }
            
            // Современный прогресс-бар
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Фон прогресс-бара
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(height: 12)
                        
                        // Заполненная часть с градиентом
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [hpColor, hpColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(4, CGFloat(hpPercentage) * geometry.size.width), height: 12)
                            .animation(.easeInOut(duration: 0.3), value: hpPercentage)
                    }
                }
                .frame(height: 12)
                
                // Процент здоровья
                HStack {
                    Text("\(Int(hpPercentage * 100))% здоровья")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let c = character, c.temporaryHitPoints > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("\(c.temporaryHitPoints) врем.")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemBackground).opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .stroke(
                    LinearGradient(
                        colors: [hpColor.opacity(0.3), hpColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .alert("Изменить хиты", isPresented: $showingHPEditor) {
            TextField("Текущие хиты", text: $newHP)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if let c = character, let hp = Int(newHP), hp >= 0, hp <= c.maxHitPoints {
                    store.updateCharacterHitPoints(c, newCurrentHP: hp)
                }
            }
        } message: {
            Text("Введите новое значение хитов (0-\(character?.maxHitPoints ?? 0))")
        }
    }
}

struct CompactStatsView: View {
    let character: Character
    let store: CharacterStore
    let isEditingMode: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Заголовок с иконкой
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.headline)
                        .foregroundColor(.purple)
            Text("Основные характеристики")
                .font(.headline)
                        .fontWeight(.bold)
                }
                Spacer()
            }
            
            // Современная сетка характеристик
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                EditableModernStatItem(
                    name: "СИЛ", 
                    score: character.strength, 
                    modifier: character.strengthModifier, 
                    icon: "figure.strengthtraining.traditional", 
                    color: .red,
                    isEditing: isEditingMode,
                    onScoreChange: { newScore in
                        var updatedCharacter = character
                        updatedCharacter.strength = newScore
                        store.update(updatedCharacter)
                    }
                )
                EditableModernStatItem(
                    name: "ЛОВ", 
                    score: character.dexterity, 
                    modifier: character.dexterityModifier, 
                    icon: "figure.run", 
                    color: .green,
                    isEditing: isEditingMode,
                    onScoreChange: { newScore in
                        var updatedCharacter = character
                        updatedCharacter.dexterity = newScore
                        store.update(updatedCharacter)
                    }
                )
                EditableModernStatItem(
                    name: "ТЕЛ", 
                    score: character.constitution, 
                    modifier: character.constitutionModifier, 
                    icon: "heart.fill", 
                    color: .orange,
                    isEditing: isEditingMode,
                    onScoreChange: { newScore in
                        var updatedCharacter = character
                        updatedCharacter.constitution = newScore
                        store.update(updatedCharacter)
                    }
                )
                EditableModernStatItem(
                    name: "ИНТ", 
                    score: character.intelligence, 
                    modifier: character.intelligenceModifier, 
                    icon: "brain.head.profile", 
                    color: .blue,
                    isEditing: isEditingMode,
                    onScoreChange: { newScore in
                        var updatedCharacter = character
                        updatedCharacter.intelligence = newScore
                        store.update(updatedCharacter)
                    }
                )
                EditableModernStatItem(
                    name: "МДР", 
                    score: character.wisdom, 
                    modifier: character.wisdomModifier, 
                    icon: "eye.fill", 
                    color: .purple,
                    isEditing: isEditingMode,
                    onScoreChange: { newScore in
                        var updatedCharacter = character
                        updatedCharacter.wisdom = newScore
                        store.update(updatedCharacter)
                    }
                )
                EditableModernStatItem(
                    name: "ХАР", 
                    score: character.charisma, 
                    modifier: character.charismaModifier, 
                    icon: "person.2.fill", 
                    color: .pink,
                    isEditing: isEditingMode,
                    onScoreChange: { newScore in
                        var updatedCharacter = character
                        updatedCharacter.charisma = newScore
                        store.update(updatedCharacter)
                    }
                )
            }
            
            // Боевые характеристики
            VStack(spacing: 12) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "shield.fill")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Text("Боевые характеристики")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    ModernCombatStat(title: "КЗ", value: "\(character.armorClass)", icon: "shield.fill", color: .blue)
                    ModernCombatStat(title: "Инициатива", value: character.initiative >= 0 ? "+\(character.initiative)" : "\(character.initiative)", icon: "bolt.fill", color: .yellow)
                    ModernCombatStat(title: "Скорость", value: "\(character.effectiveSpeed) фт.", icon: "figure.walk", color: .green)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemBackground).opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .stroke(
                    LinearGradient(
                        colors: [.purple.opacity(0.3), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}

struct CompactStatItem: View {
    let name: String
    let score: Int
    let modifier: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(modifier >= 0 ? .green : .red)
            
            Text("\(score)")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ModernStatItem: View {
    let name: String
    let score: Int
    let modifier: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // Иконка характеристики
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Название характеристики
            Text(name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            // Модификатор (главное значение)
            Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(modifier >= 0 ? .green : .red)
            
            // Базовое значение
            Text("\(score)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray6))
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.06))
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct EditableModernStatItem: View {
    let name: String
    let score: Int
    let modifier: Int
    let icon: String
    let color: Color
    let isEditing: Bool
    let onScoreChange: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Иконка характеристики
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Название характеристики
            Text(name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            // Модификатор (главное значение)
            Text(modifier >= 0 ? "+\(modifier)" : "\(modifier)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(modifier >= 0 ? .green : .red)
            
            // Базовое значение с кнопками редактирования
            if isEditing {
                HStack(spacing: 4) {
                    Button(action: {
                        onScoreChange(max(1, score - 1))
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(color)
                            .font(.caption)
                    }
                    
                    Text("\(score)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.systemGray6))
                        )
                    
                    Button(action: {
                        onScoreChange(min(30, score + 1))
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(color)
                            .font(.caption)
                    }
                }
            } else {
                Text("\(score)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.systemGray6))
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.06))
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ModernCombatStat: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            // Иконка
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            // Значение
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Название
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.08))
        )
    }
}

struct CombatStatCompact: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct DetailSectionsView: View {
    @Binding var showingDetailSection: CharacterDetailSection?
    @State private var collapsedSections: Set<CharacterDetailSection> = []
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Детальная информация")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 8) {
                ForEach(CharacterDetailSection.allCases, id: \.self) { section in
                    CollapsibleSectionCard(
                        section: section,
                        isCollapsed: collapsedSections.contains(section),
                        onToggle: {
                            if collapsedSections.contains(section) {
                                collapsedSections.remove(section)
                            } else {
                                collapsedSections.insert(section)
                            }
                        },
                        onTap: {
                        showingDetailSection = section
                    }
                    )
                }
            }
        }
        .padding()
        .background(ThemeManager.adaptiveCardBackground(for: nil))
        .cornerRadius(12)
    }
}

struct CollapsibleSectionCard: View {
    let section: CharacterDetailSection
    let isCollapsed: Bool
    let onToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: section.icon)
                    .font(.title2)
                    .foregroundColor(section.color)
                
                Text(section.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(section.color.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(section.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            onToggle()
        }
    }
}


