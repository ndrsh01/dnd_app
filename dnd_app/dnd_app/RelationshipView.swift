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

    var body: some View {
        NavigationStack {
            ZStack {
                // Фон #fceeda
                Color(hex: "#fceeda")
                    .ignoresSafeArea()
                
                Group {
                    if store.people.isEmpty {
                        VStack(spacing: 30) {
                            Spacer()
                            
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.gray)
                            
                            Text("Нет персонажей")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            
                            Text("Добавьте первого персонажа, чтобы начать отслеживать отношения")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
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
        VStack(alignment: .leading, spacing: 16) {
            // Верхняя часть с именем и кнопкой редактирования
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if isEditing {
                        TextField("Имя", text: $editedName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(person.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    if !isEditing {
                        Text(person.details)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                                    // Кнопка редактирования
                    if !isEditing {
                        Button(action: {
                            isEditing = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .allowsHitTesting(true)
                        .contentShape(Rectangle())
                    }
            }
            
            // Поле описания в режиме редактирования
            if isEditing {
                TextField("Описание", text: $editedDetails, axis: .vertical)
                    .font(.body)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                    .frame(minHeight: 80)
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
                            // Отрицательные отношения - крестики
                            ForEach(0..<Person.maxHearts, id: \.self) { index in
                                Image(systemName: index < person.displayValue ? "xmark.circle.fill" : "xmark.circle")
                                    .foregroundColor(index < person.displayValue ? .black : .gray)
                                    .font(.title3)
                                    .onTapGesture {
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
                
                // Кнопки управления отношениями
                VStack(spacing: 4) {
                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(statusColor)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 8) {
                        // Кнопка "Друг"
                        Button(action: {
                            let updated = Person(
                                id: person.id,
                                name: person.name,
                                details: person.details,
                                hearts: 4
                            )
                            onUpdate(updated)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                Text("Друг")
                            }
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(person.isPositive ? .white : .red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(person.isPositive ? Color.red : Color.clear)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .allowsHitTesting(true)
                        .contentShape(Rectangle())
                        
                        // Кнопка "Враг"
                        Button(action: {
                            let updated = Person(
                                id: person.id,
                                name: person.name,
                                details: person.details,
                                hearts: -4
                            )
                            onUpdate(updated)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                Text("Враг")
                            }
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(person.isNegative ? .white : .black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(person.isNegative ? Color.black : Color.clear)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .allowsHitTesting(true)
                        .contentShape(Rectangle())
                        
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
                            Text("Сброс")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(person.isNeutral ? .white : .gray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(person.isNeutral ? Color.gray : Color.clear)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .allowsHitTesting(true)
                        .contentShape(Rectangle())
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
                    .font(.body)
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
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.orange)
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .animation(.easeInOut(duration: 0.3), value: isEditing)
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
                // Фон #fceeda
                Color(hex: "#fceeda")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 20) {
                            // Поле имени
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Имя")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                TextField("Введите имя", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        
                        // Поле описания
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Описание")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            TextField("Введите описание", text: $details, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                                .frame(minHeight: 80)
                        }
                        
                        // Слайдер отношений
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Уровень отношений")
                                .font(.headline)
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
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(statusColor)
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
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
