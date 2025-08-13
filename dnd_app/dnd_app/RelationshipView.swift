import SwiftUI

// MARK: - Model

struct Person: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var details: String
    var hearts: Int // -7 до +7, где 0 = нейтрально

    static let maxHearts = 7
    static let minHearts = -7
    
    var isPositive: Bool {
        return hearts > 0
    }
    
    var isNegative: Bool {
        return hearts < 0
    }
    
    var isNeutral: Bool {
        return hearts == 0
    }
    
    var displayValue: Int {
        return abs(hearts)
    }
}

// MARK: - Store

final class RelationshipStore: ObservableObject {
    @Published var people: [Person] = [] {
        didSet { save() }
    }

    private let key = "relationships_v3"

    init() {
        load()
        if people.isEmpty {
            people = [
                Person(name: "Луна", details: "норм чел, респектую ему", hearts: 3),
                Person(name: "Чатуру", details: "подозрительный тип", hearts: -2),
                Person(name: "Люме", details: "говорит здравые вещи", hearts: 5),
                Person(name: "Гарри", details: "шуты и хаос", hearts: 1)
            ]
        }
    }

    func add(_ p: Person) { people.append(p) }
    func remove(at offsets: IndexSet) { people.remove(atOffsets: offsets) }
    func update(_ p: Person) {
        DispatchQueue.main.async {
            if let idx = self.people.firstIndex(where: { $0.id == p.id }) {
                self.people[idx] = p
            }
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(people)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("❌ Failed to encode relationships: \(error)")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            people = try JSONDecoder().decode([Person].self, from: data)
        } catch {
            print("❌ Failed to decode relationships: \(error)")
        }
    }
}

// MARK: - View

struct RelationshipView: View {
    @StateObject private var store = RelationshipStore()
    @State private var showingAdd = false
    @State private var editing: Person? = nil
    @Namespace private var ns

    var body: some View {
        NavigationStack {
            ZStack {
                // Современный светлый градиентный фон
                Color(hex: "#fceeda")
                .ignoresSafeArea()

                Group {
                    if store.people.isEmpty {
                        VStack(spacing: 30) {
                            Spacer()
                            
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 80))
                                .foregroundColor(.orange)
                                .shadow(color: .orange.opacity(0.3), radius: 10)
                            
                            VStack(spacing: 16) {
                                Text("Нет персонажей")
                                    .font(.system(.largeTitle, design: .rounded))
                                    .fontWeight(.bold)
                                
                                Text("Добавь своих друзей и врагов, чтобы следить за уровнем симпатии")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            
                            Button(action: { showingAdd = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                    Text("Добавить персонажа")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.orange, Color.orange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(store.people) { person in
                                PersonCard(person: person) { updated in
                                        store.update(updated)
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .padding(.vertical, 8)
                            }
                            .onDelete(perform: store.remove)
                        }
                        .listStyle(PlainListStyle())
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(.systemBackground),
                                    Color(.systemGray6).opacity(0.3),
                                    Color(.systemBackground)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
            }
            .navigationTitle("💖 Отношения")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddPersonView { person in
                    store.add(person)
                    showingAdd = false
                }
            }
        }
    }
}

// MARK: - Person Card Component
struct PersonCard: View {
    let person: Person
    let onUpdate: (Person) -> Void
    
    @State private var isEditing = false
    @State private var editedName: String
    @State private var editedDetails: String
    @State private var editedHearts: Int
    
    init(person: Person, onUpdate: @escaping (Person) -> Void) {
        self.person = person
        self.onUpdate = onUpdate
        self._editedName = State(initialValue: person.name)
        self._editedDetails = State(initialValue: person.details)
        self._editedHearts = State(initialValue: person.hearts)
    }
    
    // Цвета градиента карточки в зависимости от отношений
    private var cardGradientColors: [Color] {
        if person.isPositive {
            return [Color.purple, Color.pink, Color.orange]
        } else if person.isNegative {
            return [Color.red, Color.orange, Color.yellow]
        } else {
            return [Color.blue, Color.cyan, Color.teal]
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Фон карточки в стиле Apple Music
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: cardGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                .overlay(
                    // Дополнительный градиентный слой для глубины
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.1), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            // Основная карточка в стиле Apple Music
            VStack(alignment: .leading, spacing: 0) {
                if isEditing {
                    // Режим редактирования
                    VStack(spacing: 20) {
                        // Поле имени
                        TextField("Имя персонажа", text: $editedName)
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .stroke(LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ), lineWidth: 2)
                                    .shadow(color: .orange.opacity(0.3), radius: 12, x: 0, y: 4)
                            )
                        
                        // Поле описания
                        TextField("Описание персонажа", text: $editedDetails, axis: .vertical)
                            .font(.system(.body, design: .rounded))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .lineLimit(4...15)
                            .frame(minHeight: 120)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .stroke(LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ), lineWidth: 2)
                                    .shadow(color: .orange.opacity(0.3), radius: 12, x: 0, y: 4)
                            )
                    }
                    .padding(24)
                } else {
                    // Обычный режим просмотра
                    VStack(alignment: .leading, spacing: 16) {
                        // Имя персонажа
                        Text(person.name)
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        
                        // Описание персонажа
                        Text(person.details)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(24)
                }
                
                // Система отношений (только не в режиме редактирования)
                if !isEditing {
                VStack(spacing: 8) {
                    // Индикатор отношений
                    HStack(spacing: 4) {
                        if person.isPositive {
                            // Положительные отношения - сердечки
                            ForEach(0..<Person.maxHearts, id: \.self) { index in
                                Image(systemName: index < person.displayValue ? "heart.fill" : "heart")
                                    .foregroundColor(index < person.displayValue ? .red : .gray)
                                    .font(.title3)
                                    .onTapGesture {
                                            // Прямое редактирование
                                            let newValue = index + 1
                                            let updated = Person(
                                                id: person.id,
                                                name: person.name,
                                                details: person.details,
                                                hearts: newValue
                                            )
                                            onUpdate(updated)
                                    }
                                    .onLongPressGesture {
                                        if !isEditing {
                                            // Переключение на отрицательные отношения
                                            let updated = Person(
                                                id: person.id,
                                                name: person.name,
                                                details: person.details,
                                                hearts: -(index + 1)
                                            )
                                            onUpdate(updated)
                                        }
                                    }
                            }
                        } else if person.isNegative {
                            // Отрицательные отношения - черепки
                            ForEach(0..<Person.maxHearts, id: \.self) { index in
                                Image(systemName: index < person.displayValue ? "xmark.circle.fill" : "xmark.circle")
                                    .foregroundColor(index < person.displayValue ? .black : .gray)
                                    .font(.title3)
                                    .onTapGesture {
                                            // Прямое редактирование
                                            let newValue = -(index + 1)
                                            let updated = Person(
                                                id: person.id,
                                                name: person.name,
                                                details: person.details,
                                                hearts: newValue
                                            )
                                            onUpdate(updated)
                                    }
                                    .onLongPressGesture {
                                        if !isEditing {
                                            // Переключение на положительные отношения
                                            let updated = Person(
                                                id: person.id,
                                                name: person.name,
                                                details: person.details,
                                                hearts: index + 1
                                            )
                                            onUpdate(updated)
                                        }
                                    }
                            }
                        } else {
                            // Нейтральные отношения - пустые круги
                            ForEach(0..<Person.maxHearts, id: \.self) { index in
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                    .font(.title3)
                                    .onTapGesture {
                                            let newValue = index + 1
                                            let updated = Person(
                                                id: person.id,
                                                name: person.name,
                                                details: person.details,
                                                hearts: newValue
                                            )
                                            onUpdate(updated)
                                        }
                                    .onLongPressGesture {
                                        // Переключение на отрицательные отношения
                                        let newValue = -(index + 1)
                                        let updated = Person(
                                            id: person.id,
                                            name: person.name,
                                            details: person.details,
                                            hearts: newValue
                                        )
                                        onUpdate(updated)
                                    }
                            }
                        }
                    }
                    
                    // Кнопки управления отношениями в стиле Apple Music
                    if !isEditing {
                        VStack(spacing: 12) {
                            // Статус отношений
                            Text(statusText)
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(.white.opacity(0.2))
                                        .blur(radius: 0.5)
                                )
                            
                            // Кнопки действий
                            HStack(spacing: 12) {
                                // Кнопка "Друг"
                                Button(action: {
                                    print("🔥 Кнопка Друг нажата!")
                                    let updated = Person(
                                        id: person.id,
                                        name: person.name,
                                        details: person.details,
                                        hearts: 4
                                    )
                                    onUpdate(updated)
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "heart.fill")
                                            .font(.system(.caption, design: .rounded))
                                        Text("Друг")
                                            .font(.system(.caption, design: .rounded))
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: person.isPositive ? [.red, .pink] : [.red.opacity(0.7), .pink.opacity(0.7)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .scaleEffect(person.isPositive ? 1.05 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: person.isPositive)
                                
                                // Кнопка "Враг"
                                Button(action: {
                                    print("💀 Кнопка Враг нажата!")
                                    let updated = Person(
                                        id: person.id,
                                        name: person.name,
                                        details: person.details,
                                        hearts: -4
                                    )
                                    onUpdate(updated)
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(.caption, design: .rounded))
                                        Text("Враг")
                                            .font(.system(.caption, design: .rounded))
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: person.isNegative ? [.black, .gray] : [.black.opacity(0.7), .gray.opacity(0.7)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .scaleEffect(person.isNegative ? 1.05 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: person.isNegative)
                                
                                // Кнопка "Сброс"
                                Button(action: {
                                    let updated = Person(
                                        id: person.id,
                                        name: person.name,
                                        details: person.details,
                                        hearts: 0
                                    )
                                    onUpdate(updated)
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "circle")
                                            .font(.system(.caption, design: .rounded))
                                        Text("Сброс")
                                            .font(.system(.caption, design: .rounded))
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: person.isNeutral ? [.blue, .cyan] : [.blue.opacity(0.7), .cyan.opacity(0.7)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .scaleEffect(person.isNeutral ? 1.05 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: person.isNeutral)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            
            if isEditing {
                HStack(spacing: 20) {
                    // Кнопка "Отмена"
                    Button(action: {
                        isEditing = false
                        editedName = person.name
                        editedDetails = person.details
                        editedHearts = person.hearts
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(.body, design: .rounded))
                            Text("Отмена")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.gray.opacity(0.8), .gray.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // Кнопка "Сохранить"
                    Button(action: {
                        let updated = Person(
                            id: person.id,
                            name: editedName,
                            details: editedDetails,
                            hearts: editedHearts
                        )
                        onUpdate(updated)
                        isEditing = false
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(.body, design: .rounded))
                            Text("Сохранить")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.green, .green.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isEditing)
        .frame(maxWidth: .infinity)
            }
        
            // Кнопка редактирования в стиле Apple Music
            if !isEditing {
                Button(action: {
                    print("✏️ Кнопка редактирования нажата!")
                    isEditing = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.5), lineWidth: 1)
                        )
                }
                .padding(16)
                .scaleEffect(1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isEditing)
            }
        }
    }
    
    private var statusText: String {
        if person.isPositive {
            return "Друг (\(person.hearts))"
        } else if person.isNegative {
            return "Враг (\(abs(person.hearts)))"
        } else {
            return "Нейтрально"
        }
    }


    
    private var statusColor: Color {
        if person.isPositive {
            return .red
        } else if person.isNegative {
            return .black
        } else {
            return .gray
        }
    }


// MARK: - Add Person View
struct AddPersonView: View {
    let onAdd: (Person) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var details = ""
    @State private var hearts = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#fceeda")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 20) {
                            // Поле имени
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Имя")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                
                                TextField("Введите имя", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.system(.body, design: .rounded))
                            }
                            
                            // Поле описания
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Описание")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                
                                TextField("Введите описание", text: $details, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.system(.body, design: .rounded))
                        .lineLimit(3...6)
                            }
                            
                            // Слайдер отношений
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Уровень отношений")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.semibold)
                                
                                VStack(spacing: 16) {
                                    // Индикатор
                                    HStack(spacing: 4) {
                                        if hearts > 0 {
                                            // Положительные отношения
                                            ForEach(0..<Person.maxHearts, id: \.self) { index in
                                                Image(systemName: index < hearts ? "heart.fill" : "heart")
                                                    .foregroundColor(index < hearts ? .red : .gray)
                                                    .font(.title2)
                                                    .onTapGesture {
                                                        hearts = index + 1
                                                    }
                                            }
                                        } else if hearts < 0 {
                                            // Отрицательные отношения
                                            ForEach(0..<Person.maxHearts, id: \.self) { index in
                                                Image(systemName: index < abs(hearts) ? "xmark.circle.fill" : "xmark.circle")
                                                    .foregroundColor(index < abs(hearts) ? .black : .gray)
                                                    .font(.title2)
                                                    .onTapGesture {
                                                        hearts = -(index + 1)
                                                    }
                                            }
                                        } else {
                                            // Нейтральные отношения
                                            ForEach(0..<Person.maxHearts, id: \.self) { index in
                                                Image(systemName: "circle")
                                                    .foregroundColor(.gray)
                                                    .font(.title2)
                                                    .onTapGesture {
                                                        hearts = 0
                                                    }
                                            }
                                        }
                                    }
                                    
                                    // Слайдер
                                    Slider(value: Binding(
                                        get: { Double(hearts) },
                                        set: { hearts = Int($0) }
                                    ), in: Double(Person.minHearts)...Double(Person.maxHearts), step: 1)
                                    .accentColor(.orange)
                                    
                                    // Текст статуса
                                    Text(statusText)
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundColor(statusColor)
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationTitle("Добавить персонажа")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        let person = Person(name: name, details: details, hearts: hearts)
                        onAdd(person)
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private var statusText: String {
        if hearts > 0 {
            return "Друг (\(hearts))"
        } else if hearts < 0 {
            return "Враг (\(abs(hearts)))"
        } else {
            return "Нейтрально"
        }
    }
    
    private var statusColor: Color {
        if hearts > 0 {
            return .red
        } else if hearts < 0 {
            return .black
        } else {
            return .gray
        }
    }
}

// MARK: - Preview

struct RelationshipView_Previews: PreviewProvider {
    static var previews: some View {
    RelationshipView()
    }
}

