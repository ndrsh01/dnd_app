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
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: store.remove)
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
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
                            .foregroundColor(.orange)
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

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: isEditing ? 24 : 16) {

        VStack(alignment: .leading, spacing: isEditing ? 20 : 16) {
                    if isEditing {
                    // Поле имени
                        TextField("Имя", text: $editedName)
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .stroke(Color.orange, lineWidth: 2)
                                    .shadow(color: Color.orange.opacity(0.2), radius: 8, x: 0, y: 2)
                            )
                        
                    // Поле описания
                    TextField("Описание", text: $editedDetails, axis: .vertical)
                            .font(.system(.body, design: .rounded))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .lineLimit(4...15)
                            .frame(minHeight: 120)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .stroke(Color.orange, lineWidth: 2)
                                    .shadow(color: Color.orange.opacity(0.2), radius: 8, x: 0, y: 2)
                            )
                    } else {
                        Text(person.name)
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    
                        Text(person.details)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Система отношений
                VStack(spacing: 8) {
                    // Индикатор отношений (только не в режиме редактирования)
                    if !isEditing {
                        HStack(spacing: 4) {
                            if person.isPositive {
                                // Положительные отношения - сердечки
                                ForEach(0..<Person.maxHearts, id: \.self) { index in
                                                                            Image(systemName: index < person.displayValue ? "heart.fill" : "heart")
                                            .foregroundColor(index < person.displayValue ? .red : .gray)
                                            .font(.title3)
                                            .scaleEffect(index < person.displayValue ? 1.1 : 1.0)
                                            .animation(.easeInOut(duration: 0.2), value: person.displayValue)
                                        .onTapGesture {
                                            // Haptic feedback
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                            impactFeedback.impactOccurred()
                                            
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
                                            // Haptic feedback
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                            impactFeedback.impactOccurred()
                                            
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
                            } else if person.isNegative {
                                // Отрицательные отношения - черепки
                                ForEach(0..<Person.maxHearts, id: \.self) { index in
                                    Image(systemName: index < person.displayValue ? "xmark.circle.fill" : "xmark.circle")
                                        .foregroundColor(index < person.displayValue ? .black : .gray)
                                        .font(.title3)
                                        .scaleEffect(index < person.displayValue ? 1.1 : 1.0)
                                        .animation(.easeInOut(duration: 0.2), value: person.displayValue)
                                        .onTapGesture {
                                            // Haptic feedback
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                            impactFeedback.impactOccurred()
                                            
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
                                            // Haptic feedback
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                            impactFeedback.impactOccurred()
                                            
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
                            } else {
                                // Нейтральные отношения - пустые круги
                                ForEach(0..<Person.maxHearts, id: \.self) { index in
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                        .font(.title3)
                                        .onTapGesture {
                                            // Haptic feedback
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                            impactFeedback.impactOccurred()
                                            
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
                                            // Haptic feedback
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                            impactFeedback.impactOccurred()
                                            
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
                    }
                    
                    // Кнопки переключения типа отношений (всегда видны)
                    VStack(spacing: 4) {
                        Text(statusText)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(statusColor)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 8) {
                            // Кнопка "Друг"
                            Button(action: {
                                // Haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                let updated = Person(
                                    id: person.id,
                                    name: person.name,
                                    details: person.details,
                                    hearts: 4  // Устанавливаем 4 сердечка
                                )
                                onUpdate(updated)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                    Text("Друг")
                                        .foregroundColor(.red)
                                }
                                .font(.system(.caption2, design: .rounded))
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(person.isPositive ? Color.red.opacity(0.2) : Color.clear)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                            }
                            .scaleEffect(person.isPositive ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: person.isPositive)
                            
                            // Кнопка "Враг"
                            Button(action: {
                                // Haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                let updated = Person(
                                    id: person.id,
                                    name: person.name,
                                    details: person.details,
                                    hearts: -4  // Устанавливаем 4 крестика
                                )
                                onUpdate(updated)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.black)
                                    Text("Враг")
                                        .foregroundColor(.black)
                                }
                                .font(.system(.caption2, design: .rounded))
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(person.isNegative ? Color.black.opacity(0.2) : Color.clear)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                            }
                            .scaleEffect(person.isNegative ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: person.isNegative)
                            
                            // Кнопка "Сброс"
                            Button(action: {
                                // Haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                let updated = Person(
                                    id: person.id,
                                    name: person.name,
                                    details: person.details,
                                    hearts: 0
                                )
                                onUpdate(updated)
                            }) {
                                Text("Сброс")
                                    .font(.system(.caption2, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(person.isNeutral ? Color.gray.opacity(0.2) : Color.clear)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                            }
                            .scaleEffect(person.isNeutral ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: person.isNeutral)
                        }
                    }
                }
            }
            
            if isEditing {
                HStack(spacing: 16) {
                    Button("Отмена") {
                        isEditing = false
                        editedName = person.name
                        editedDetails = person.details
                        editedHearts = person.hearts
                    }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                    
                    Spacer()
                    
                    Button("Сохранить") {
                        let updated = Person(
                            id: person.id,
                            name: editedName,
                            details: editedDetails,
                            hearts: editedHearts
                        )
                        onUpdate(updated)
                        isEditing = false
                    }
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.orange.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color.orange.opacity(0.3), radius: 5, x: 0, y: 2)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .padding(isEditing ? 16 : 20)
        .background(
            RoundedRectangle(cornerRadius: isEditing ? 25 : 20)
                .fill(
                    isEditing ? 
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color.orange.opacity(0.02),
                            Color(.systemBackground)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [Color(.systemBackground)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .stroke(
                    isEditing ? 
                    LinearGradient(
                        colors: [Color.orange.opacity(0.8), Color.orange, Color.orange.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(colors: [Color.clear], startPoint: .top, endPoint: .bottom),
                    lineWidth: isEditing ? 3 : 0
                )
                .shadow(
                    color: isEditing ? Color.orange.opacity(0.25) : Color.black.opacity(0.05),
                    radius: isEditing ? 20 : 10,
                    x: 0,
                    y: isEditing ? 10 : 5
                )
        )
        .animation(.easeInOut(duration: 0.3), value: isEditing)
        .frame(maxWidth: isEditing ? .infinity : nil)
        .padding(.horizontal, isEditing ? 0 : 0)
            }
        
            // Кнопка редактирования в правом верхнем углу (единственный способ войти в режим редактирования)
            if !isEditing {
                Button(action: {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    isEditing = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                        .background(
                            Circle()
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        )
                }
                .padding(12)
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.2), value: isEditing)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Пустой gesture для предотвращения случайного открытия редактирования
            // Только кнопка карандаша должна открывать редактирование
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
                // Современный светлый градиентный фон
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
