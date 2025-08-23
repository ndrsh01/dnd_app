import SwiftUI
import PhotosUI

struct CompactCharacterSheetView: View {
    let character: Character
    @ObservedObject var store: CharacterStore
    @ObservedObject var compendiumStore: CompendiumStore
    @ObservedObject var classesStore: ClassesStore
    @State private var showingDetailSection: CharacterDetailSection?
    @Binding var isEditingMode: Bool
    let onSaveChanges: ((Character) -> Void)?
    
    init(character: Character, store: CharacterStore, compendiumStore: CompendiumStore, classesStore: ClassesStore, isEditingMode: Binding<Bool>, onSaveChanges: ((Character) -> Void)? = nil) {
        self.character = character
        self.store = store
        self.compendiumStore = compendiumStore
        self.classesStore = classesStore
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
                        classesStore: classesStore,
                        isEditingMode: isEditingMode,
                        onSaveChanges: onSaveChanges
                    )
                
                // Хиты (отдельно)
                    HitPointsView(store: store, isEditingMode: isEditingMode)
                
                // Основные характеристики (компактно)
                    CompactStatsView(character: current, store: store, isEditingMode: isEditingMode, onSaveChanges: onSaveChanges)
                
                // Ссылки на детальные разделы
                DetailSectionsView(showingDetailSection: $showingDetailSection)
                
                // Классовые умения с таблицей прогрессии
                ClassAbilitiesSection(
                    character: Binding(
                        get: { current },
                        set: { newCharacter in
                            store.update(newCharacter)
                            store.selectedCharacter = newCharacter
                            onSaveChanges?(newCharacter)
                        }
                    ),
                    onSaveChanges: onSaveChanges
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
        .sheet(item: $showingDetailSection) { section in
            let current = store.selectedCharacter ?? character
            DetailSectionView(character: current, section: section, store: store, compendiumStore: compendiumStore, classesStore: classesStore, onSaveChanges: onSaveChanges)
        }
    }
}

struct CharacterHeaderCompactView: View {
    let character: Character
    @ObservedObject var store: CharacterStore
    @ObservedObject var compendiumStore: CompendiumStore
    @ObservedObject var classesStore: ClassesStore
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
    @State private var selectedSubclass = ""
    @State private var selectedBackground = ""
    @State private var selectedAlignment = ""
    @State private var showingImagePicker = false
    @State private var avatarImage: UIImage?
    @State private var availableClasses: [String] = []
    @State private var isLoadingClassFeatures = false
    @State private var showClassFeaturesNotification = false
    @State private var classFeaturesNotificationText = ""
    
    init(character: Character, store: CharacterStore, compendiumStore: CompendiumStore, classesStore: ClassesStore, isEditingMode: Bool, onSaveChanges: ((Character) -> Void)? = nil) {
        self.character = character
        self.store = store
        self.compendiumStore = compendiumStore
        self.classesStore = classesStore
        self.isEditingMode = isEditingMode
        self.onSaveChanges = onSaveChanges
        self._tempCharacter = State(initialValue: character)
        self._availableClasses = State(initialValue: [])
    }
    
    private func loadClasses() {
        // Фиксированный список классов
        availableClasses = [
            "Варвар", "Бард", "Волшебник", "Друид", "Жрец", 
            "Колдун", "Монах", "Паладин", "Плут", "Следопыт", "Чародей"
        ]
    }
    
    private func loadClassFeatures(for className: String, character: inout Character) {
        // Получаем slug класса
        let classSlug = getClassSlug(for: className)
        
        // Загружаем данные классов если еще не загружены
        if classesStore.classesBySlug.isEmpty {
            classesStore.loadClasses()
        }
        
        // Загружаем таблицы классов если еще не загружены
        if classesStore.classTablesBySlug.isEmpty {
            classesStore.loadClassTables()
        }
        
        // Проверяем, есть ли уже загруженные умения для этого класса
        if let existingFeatures = character.classFeatures[classSlug] {
            // Если умения уже загружены, просто обновляем особенности
            updateFeaturesAndTraits(character: &character, features: existingFeatures, className: className)
            return
        }
        
        // Получаем умения для всех уровней до текущего
        if let gameClass = classesStore.classesBySlug[classSlug] {
            let currentLevel = character.level
            var allFeatures: [String: [ClassFeature]] = [:]
            var totalFeaturesCount = 0
            
            // Загружаем умения для всех уровней от 1 до 20
            for level in 1...20 {
                let levelString = String(level)
                if let featuresForLevel = gameClass.featuresByLevel[levelString] {
                    allFeatures[levelString] = featuresForLevel
                    totalFeaturesCount += featuresForLevel.count
                }
            }
            
            if !allFeatures.isEmpty {
                // Обновляем классовые умения персонажа
                character.classFeatures[classSlug] = allFeatures
                
                // Обновляем особенности и черты персонажа
                updateFeaturesAndTraits(character: &character, features: allFeatures, className: className)
                
                // Показываем уведомление об успешной загрузке
                classFeaturesNotificationText = "✅ Загружено \(totalFeaturesCount) умений для \(className) (все уровни)"
                showClassFeaturesNotification = true
                
                // Скрываем уведомление через 3 секунды
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showClassFeaturesNotification = false
                }
            } else {
                // Показываем уведомление если умения не найдены
                classFeaturesNotificationText = "⚠️ Умения для \(className) не найдены"
                showClassFeaturesNotification = true
                
                // Скрываем уведомление через 3 секунды
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showClassFeaturesNotification = false
                }
            }
        } else {
            // Показываем уведомление если класс не найден
            classFeaturesNotificationText = "❌ Класс \(className) не найден в базе данных"
            showClassFeaturesNotification = true
            
            // Скрываем уведомление через 3 секунды
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showClassFeaturesNotification = false
            }
        }
        
        // Получаем таблицу прогрессии класса
        if let classTable = classesStore.classTablesBySlug[classSlug] {
            character.classProgression[classSlug] = classTable
        }
    }
    
    private func updateFeaturesAndTraits(character: inout Character, features: [String: [ClassFeature]], className: String) {
        var featuresText = ""
        let currentLevel = character.level
        
        for level in 1...currentLevel {
            let levelString = String(level)
            if let featuresForLevel = features[levelString] {
                if !featuresText.isEmpty {
                    featuresText += "\n\n"
                }
                featuresText += "**Уровень \(level):**\n"
                for feature in featuresForLevel {
                    featuresText += "\n**\(feature.name)**\n\(feature.text)\n"
                }
            }
        }
        
        // Добавляем к существующим особенностям
        if !character.featuresAndTraits.isEmpty {
            character.featuresAndTraits += "\n\n" + featuresText
        } else {
            character.featuresAndTraits = featuresText
        }
    }
    
    private func getClassSlug(for className: String) -> String {
        switch className.lowercased() {
        case "варвар": return "barbarian"
        case "бард": return "bard"
        case "волшебник": return "wizard"
        case "друид": return "druid"
        case "жрец": return "cleric"
        case "колдун": return "warlock"
        case "монах": return "monk"
        case "паладин": return "paladin"
        case "плут": return "rogue"
        case "следопыт": return "ranger"
        case "чародей": return "sorcerer"
        default: return "fighter"
        }
    }
    
    private func getSubclassOptions() -> [(String, String)] {
        var options = [("", "Выберите подкласс")]
        
        // Загружаем данные классов если нужно
        if classesStore.classesBySlug.isEmpty {
            classesStore.loadClasses()
        }
        
        let classSlug = getClassSlug(for: character.characterClass)
        if let gameClass = classesStore.classesBySlug[classSlug] {
            for subclass in gameClass.subclasses {
                options.append((subclass.name, subclass.name))
            }
        }
        
        return options
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
                    }
                    
                    // Уровень в красивом badge
                    HStack {
                        if isEditingMode {
                            HStack(spacing: 8) {
                                Button(action: {
                                    isLoadingClassFeatures = true
                                    
                                    var updatedCharacter = character
                                    updatedCharacter.level = max(1, character.level - 1)
                                    updatedCharacter.proficiencyBonus = (updatedCharacter.level - 1) / 4 + 2
                                    
                                    // Обновляем классовые умения при изменении уровня
                                    if !updatedCharacter.characterClass.isEmpty {
                                        loadClassFeatures(for: updatedCharacter.characterClass, character: &updatedCharacter)
                                    }
                                    
                                    store.update(updatedCharacter)
                                    
                                    // Скрываем индикатор загрузки через небольшую задержку
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        isLoadingClassFeatures = false
                                    }
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
                                    isLoadingClassFeatures = true
                                    
                                    var updatedCharacter = character
                                    updatedCharacter.level = min(20, character.level + 1)
                                    updatedCharacter.proficiencyBonus = (updatedCharacter.level - 1) / 4 + 2
                                    
                                    // Обновляем классовые умения при изменении уровня
                                    if !updatedCharacter.characterClass.isEmpty {
                                        loadClassFeatures(for: updatedCharacter.characterClass, character: &updatedCharacter)
                                    }
                                    
                                    store.update(updatedCharacter)
                                    
                                    // Скрываем индикатор загрузки через небольшую задержку
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        isLoadingClassFeatures = false
                                    }
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
                    PickerModernInfoItem(
                        icon: "shield.fill", 
                        title: "Класс", 
                        value: character.displayClassName, 
                        color: .green,
                        isEditing: isEditingMode,
                        selectedValue: $selectedClass,
                        options: [
                            ("", "Выберите класс"),
                            ("Варвар", "Варвар"),
                            ("Бард", "Бард"),
                            ("Волшебник", "Волшебник"),
                            ("Друид", "Друид"),
                            ("Жрец", "Жрец"),
                            ("Колдун", "Колдун"),
                            ("Монах", "Монах"),
                            ("Паладин", "Паладин"),
                            ("Плут", "Плут"),
                            ("Следопыт", "Следопыт"),
                            ("Чародей", "Чародей")
                        ]
                    )
                    
                    // Выбор подкласса (если есть класс)
                    if !character.characterClass.isEmpty {
                        PickerModernInfoItem(
                            icon: "star.fill", 
                            title: "Подкласс", 
                            value: character.subclass.isEmpty ? "Нет подкласса" : character.subclass, 
                            color: .orange,
                            isEditing: isEditingMode,
                            selectedValue: $selectedSubclass,
                            options: getSubclassOptions()
                        )
                    }
                }
                
                if isLoadingClassFeatures {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        Text("Загрузка умений...")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    .padding(.top, 4)
                }
                
                HStack(spacing: 16) {
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
                    PickerModernInfoItem(
                        icon: "scalemass.fill", 
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

        .alert("Редактировать уровень", isPresented: $editingLevel) {
            TextField("Уровень", text: $newLevel)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if let level = Int(newLevel), level > 0, level <= 20 {
                    isLoadingClassFeatures = true
                    
                    var updatedCharacter = character
                    updatedCharacter.level = level
                    updatedCharacter.proficiencyBonus = (updatedCharacter.level - 1) / 4 + 2
                    
                    // Обновляем классовые умения при изменении уровня
                    if !updatedCharacter.characterClass.isEmpty {
                        loadClassFeatures(for: updatedCharacter.characterClass, character: &updatedCharacter)
                    }
                    
                    store.update(updatedCharacter)
                    
                    // Скрываем индикатор загрузки через небольшую задержку
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isLoadingClassFeatures = false
                    }
                }
            }
        }
        .onChange(of: character) { newCharacter in
            tempCharacter = newCharacter
            selectedClass = newCharacter.displayClassName
            selectedSubclass = newCharacter.subclass
            selectedBackground = newCharacter.background
            selectedAlignment = newCharacter.alignment
            
            // Автоматически загружаем классовые умения при первом открытии персонажа
            if !newCharacter.characterClass.isEmpty && newCharacter.classFeatures.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    var updatedCharacter = newCharacter
                    loadClassFeatures(for: newCharacter.characterClass, character: &updatedCharacter)
                    store.update(updatedCharacter)
                    store.selectedCharacter = updatedCharacter
                }
            }
        }
        .onChange(of: selectedClass) { newClass in
            if !newClass.isEmpty {
                isLoadingClassFeatures = true
                
                var updatedCharacter = character
                updatedCharacter.characterClass = newClass
                
                // Загружаем классовые умения для нового класса
                loadClassFeatures(for: newClass, character: &updatedCharacter)
                
                store.update(updatedCharacter)
                // Немедленно обновляем выбранного персонажа
                store.selectedCharacter = updatedCharacter
                
                // Скрываем индикатор загрузки через небольшую задержку
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isLoadingClassFeatures = false
                }
            }
        }
        .onChange(of: selectedSubclass) { newSubclass in
            if !newSubclass.isEmpty {
                var updatedCharacter = character
                updatedCharacter.subclass = newSubclass
                
                // Обновляем классовые умения при изменении подкласса
                if !updatedCharacter.characterClass.isEmpty {
                    loadClassFeatures(for: updatedCharacter.characterClass, character: &updatedCharacter)
                }
                
                store.update(updatedCharacter)
                // Немедленно обновляем выбранного персонажа
                store.selectedCharacter = updatedCharacter
                onSaveChanges?(updatedCharacter)
            }
        }
        .onChange(of: selectedBackground) { newBackground in
            tempCharacter.background = newBackground
        }
        .onChange(of: selectedAlignment) { newAlignment in
            tempCharacter.alignment = newAlignment
        }
        .onChange(of: tempCharacter) { updatedCharacter in
            store.update(updatedCharacter)
            store.selectedCharacter = updatedCharacter
            onSaveChanges?(updatedCharacter)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $avatarImage)
        }
        .overlay(
            // Toast уведомление о загрузке классовых умений
            VStack {
                Spacer()
                
                if showClassFeaturesNotification {
                    HStack(spacing: 12) {
                        Text(classFeaturesNotificationText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Button(action: {
                            showClassFeaturesNotification = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [.green.opacity(0.9), .green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: showClassFeaturesNotification)
                }
            }
        )
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
    @State private var showingEditAlert = false
    @State private var editingValue = ""
    
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
                        .onLongPressGesture(minimumDuration: 0.5) {
                            editingValue = value
                            showingEditAlert = true
                        }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
        .alert("Редактировать \(title)", isPresented: $showingEditAlert) {
            TextField(title, text: $editingValue)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if !editingValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    onValueChange(editingValue)
                }
            }
        }
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
    @State private var showingPickerAlert = false
    
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
                        .onLongPressGesture(minimumDuration: 0.5) {
                            showingPickerAlert = true
                        }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
        .alert("Выбрать \(title)", isPresented: $showingPickerAlert) {
            ForEach(options, id: \.0) { option in
                Button(option.1) {
                    selectedValue = option.0
                }
            }
            Button("Отмена", role: .cancel) { }
        }
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
    @State private var showingMaxHPEditor = false
    @State private var newMaxHP = ""
    
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
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    newMaxHP = "\(character?.maxHitPoints ?? 0)"
                                    showingMaxHPEditor = true
                                }
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
        .alert("Изменить максимальные хиты", isPresented: $showingMaxHPEditor) {
            TextField("Максимальные хиты", text: $newMaxHP)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if let c = character, let maxHP = Int(newMaxHP), maxHP > 0 {
                    var updatedCharacter = c
                    updatedCharacter.maxHitPoints = maxHP
                    // Убеждаемся, что текущие хиты не превышают максимальные
                    if updatedCharacter.currentHitPoints > maxHP {
                        updatedCharacter.currentHitPoints = maxHP
                    }
                    store.update(updatedCharacter)
                }
            }
        } message: {
            Text("Введите новое значение максимальных хитов")
        }
    }
}

struct CompactStatsView: View {
    let character: Character
    let store: CharacterStore
    let isEditingMode: Bool
    let onSaveChanges: ((Character) -> Void)?
    
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
                        store.selectedCharacter = updatedCharacter
                        onSaveChanges?(updatedCharacter)
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
                        store.selectedCharacter = updatedCharacter
                        onSaveChanges?(updatedCharacter)
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
                        store.selectedCharacter = updatedCharacter
                        onSaveChanges?(updatedCharacter)
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
                        store.selectedCharacter = updatedCharacter
                        onSaveChanges?(updatedCharacter)
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
                        store.selectedCharacter = updatedCharacter
                        onSaveChanges?(updatedCharacter)
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
                        store.selectedCharacter = updatedCharacter
                        onSaveChanges?(updatedCharacter)
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
                    ModernCombatStat(
                        title: "КЗ", 
                        value: "\(character.armorClass)", 
                        icon: "shield.fill", 
                        color: .blue,
                        onValueChange: { newValue in
                            if let newAC = Int(newValue) {
                                var updatedCharacter = character
                                updatedCharacter.armorClass = newAC
                                store.update(updatedCharacter)
                                store.selectedCharacter = updatedCharacter
                                onSaveChanges?(updatedCharacter)
                            }
                        }
                    )
                    ModernCombatStat(
                        title: "Инициатива", 
                        value: character.initiative >= 0 ? "+\(character.initiative)" : "\(character.initiative)", 
                        icon: "bolt.fill", 
                        color: .yellow,
                        onValueChange: { newValue in
                            if let newInitiative = Int(newValue) {
                                var updatedCharacter = character
                                updatedCharacter.initiative = newInitiative
                                store.update(updatedCharacter)
                                store.selectedCharacter = updatedCharacter
                                onSaveChanges?(updatedCharacter)
                            }
                        }
                    )
                    ModernCombatStat(
                        title: "Скорость", 
                        value: "\(character.effectiveSpeed) фт.", 
                        icon: "figure.walk", 
                        color: .green,
                        onValueChange: { newValue in
                            if let newSpeed = Int(newValue) {
                                var updatedCharacter = character
                                updatedCharacter.speed = newSpeed
                                store.update(updatedCharacter)
                                store.selectedCharacter = updatedCharacter
                                onSaveChanges?(updatedCharacter)
                            }
                        }
                    )
                    SpellSaveDCStat(
                        character: character,
                        store: store,
                        onSaveChanges: onSaveChanges
                    )
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
    @State private var showingEditAlert = false
    @State private var editingValue = ""
    
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
                    .onLongPressGesture(minimumDuration: 0.5) {
                        editingValue = "\(score)"
                        showingEditAlert = true
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.06))
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .alert("Редактировать \(name)", isPresented: $showingEditAlert) {
            TextField("Значение", text: $editingValue)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                if let newScore = Int(editingValue), newScore >= 1, newScore <= 30 {
                    onScoreChange(newScore)
                }
            }
        }
    }
}

struct ModernCombatStat: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let onValueChange: ((String) -> Void)?
    
    @State private var showingEditAlert = false
    @State private var editingValue = ""
    
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
                .onLongPressGesture(minimumDuration: 0.5) {
                    editingValue = value
                    showingEditAlert = true
                }
            
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
        .alert("Редактировать \(title)", isPresented: $showingEditAlert) {
            TextField("Значение", text: $editingValue)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Сохранить") {
                onValueChange?(editingValue)
            }
        }
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

struct SpellSaveDCStat: View {
    let character: Character
    let store: CharacterStore
    let onSaveChanges: ((Character) -> Void)?
    
    @State private var showingEditAlert = false
    @State private var editingValue = ""
    
    private var displayValue: String {
        // Если есть ручное значение, используем его, иначе автоматически рассчитанное
        if character.spellSaveDC != 8 { // 8 - значение по умолчанию
            return "\(character.spellSaveDC)"
        } else {
            return "\(character.calculatedSpellSaveDC)"
        }
    }
    
    private var isAutoCalculated: Bool {
        return character.spellSaveDC == 8 // 8 - значение по умолчанию
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // Иконка
            Image(systemName: "sparkles")
                .font(.caption)
                .foregroundColor(.purple)
            
            // Значение
            Text(displayValue)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            .onLongPressGesture(minimumDuration: 0.5) {
                editingValue = displayValue
                showingEditAlert = true
            }
            
            // Название
            Text("Спасбросок")
                .font(.caption2)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.purple.opacity(0.08))
        )
        .alert("Редактировать сложность спасброска", isPresented: $showingEditAlert) {
            TextField("Значение", text: $editingValue)
                .keyboardType(.numberPad)
            Button("Отмена", role: .cancel) { }
            Button("Авто") {
                var updatedCharacter = character
                updatedCharacter.spellSaveDC = 8 // Сброс к автоматическому расчету
                store.update(updatedCharacter)
                store.selectedCharacter = updatedCharacter
                onSaveChanges?(updatedCharacter)
            }
            Button("Сохранить") {
                if let newDC = Int(editingValue), newDC > 0 {
                    var updatedCharacter = character
                    updatedCharacter.spellSaveDC = newDC
                    store.update(updatedCharacter)
                    store.selectedCharacter = updatedCharacter
                    onSaveChanges?(updatedCharacter)
                }
            }
        } message: {
            Text("Введите новое значение сложности спасброска или нажмите 'Авто' для автоматического расчета")
        }
    }
}


