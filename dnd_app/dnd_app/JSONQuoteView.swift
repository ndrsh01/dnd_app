import SwiftUI

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct JSONQuoteView: View {
    @StateObject private var jsonQuoteManager = JSONQuoteManager()
    @State private var animateCat = false
    @State private var currentTabaxiPose = "tabaxi_pose3"
    @State private var showManagement = false
    
    private let tabaxiPoses = ["tabaxi_pose1", "tabaxi_pose2", "tabaxi_pose3", "tabaxi_pose4", "tabaxi_pose5", "tabaxi_pose6", "tabaxi_pose7", "tabaxi_pose8", "tabaxi_pose9", "tabaxi_pose10", "tabaxi_pose11", "tabaxi_pose12", "tabaxi_pose13", "tabaxi_pose14", "tabaxi_pose15", "tabaxi_pose16", "tabaxi_pose17"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Категории
                if !jsonQuoteManager.categories.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: CommonSpacing.small) {
                            ForEach(jsonQuoteManager.categories) { category in
                                JSONCategoryButton(
                                    title: category.name,
                                    isSelected: jsonQuoteManager.selectedCategory?.name == category.name
                                ) {
                                    jsonQuoteManager.selectCategory(category)
                                    animateCat.toggle()
                                }
                            }
                        }
                        .padding(.horizontal, CommonSpacing.medium)
                    }
                    .padding(.vertical, CommonSpacing.small)
                }
                
                // Основной контент
                ScrollView {
                    VStack(spacing: CommonSpacing.small) {
                        // Цитата
                        VStack(spacing: 0) {
                            ZStack(alignment: .bottomTrailing) {
                                VStack(spacing: 0) {
                                    // Пузырь с цитатой
                                    VStack(spacing: CommonSpacing.medium) {
                                        Text(jsonQuoteManager.currentQuote.isEmpty ? "Нажми «Случайная цитата» — и мудрость табакси снизойдёт." : jsonQuoteManager.currentQuote)
                                            .multilineTextAlignment(.leading)
                                            .font(CommonFonts.title3)
                                            .foregroundColor(CommonColors.textPrimary)
                                            .padding(.horizontal, CommonSpacing.extraLarge)
                                            .padding(.top, CommonSpacing.extraLarge)
                                            .padding(.bottom, CommonSpacing.extraLarge)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .lineSpacing(4)
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(CommonColors.cardBackground)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [CommonColors.primary.opacity(0.2), CommonColors.primary.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                                    )
                                    
                                    // Треугольник снизу
                                    // Triangle()
                                    //     .fill(CommonColors.cardBackground)
                                    //     .frame(width: 20, height: 10)
                                    //     .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                }
                            }
                            .padding(.horizontal, CommonSpacing.large)
                            .padding(.top, CommonSpacing.medium)
                            
                            // Изображение табакси
                            Group {
                                if UIImage(named: currentTabaxiPose) != nil {
                                    Image(currentTabaxiPose)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } else {
                                    // Fallback на изображение по умолчанию
                                    Image("tabaxi_pose3")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                            }
                            .frame(height: 350)
                            .scaleEffect(animateCat ? 1.05 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: animateCat)
                            .padding(.top, -10)
                        }
                        
                        // Кнопка случайной цитаты
                        Button {
                            // Рандомизируем цитату
                            if let selectedCategory = jsonQuoteManager.selectedCategory {
                                jsonQuoteManager.getRandomQuote(from: selectedCategory)
                            } else {
                                jsonQuoteManager.getRandomQuoteFromAllCategories()
                            }
                            
                            // Рандомизируем позу табакси
                            let availablePoses = tabaxiPoses.filter { UIImage(named: $0) != nil }
                            if !availablePoses.isEmpty {
                                let randomIndex = Int.random(in: 0..<availablePoses.count)
                                currentTabaxiPose = availablePoses[randomIndex]
                            } else {
                                currentTabaxiPose = "tabaxi_pose3"
                            }
                            
                            animateCat.toggle()
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "shuffle")
                                    .font(.title2)
                                Text("Случайная цитата")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 24)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.orange, Color.orange.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: Color.orange.opacity(0.4), radius: 16, x: 0, y: 8)
                            )
                        }
                        .padding(.horizontal, CommonSpacing.medium)
                        .padding(.bottom, 5)
                    }
                    .padding(.bottom, CommonSpacing.medium)
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        CommonColors.background,
                        CommonColors.background.opacity(0.9),
                        CommonColors.background
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Цитаты табакси")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showManagement = true
                    }) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showManagement) {
                JSONQuoteManagementView(jsonQuoteManager: jsonQuoteManager)
            }
            .alert("Ошибка", isPresented: .constant(jsonQuoteManager.errorMessage != nil)) {
                Button("OK") {
                    jsonQuoteManager.errorMessage = nil
                }
            } message: {
                Text(jsonQuoteManager.errorMessage ?? "")
            }
        }
    }
}

// MARK: - JSON All Quotes View

struct JSONAllQuotesView: View {
    @ObservedObject var jsonQuoteManager: JSONQuoteManager
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredQuotes: [String] {
        if searchText.isEmpty {
            return jsonQuoteManager.categories.flatMap { $0.quotes }
        } else {
            return jsonQuoteManager.searchQuotes(query: searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Поиск
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Поиск цитат...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .commonSearchField()
                .padding(.horizontal, CommonSpacing.medium)
                .padding(.top, CommonSpacing.medium)
                
                // Список цитат
                List(filteredQuotes, id: \.self) { quote in
                    Text(quote)
                        .font(CommonFonts.body)
                        .padding(.vertical, CommonSpacing.small)
                }
                .listStyle(PlainListStyle())
            }
            .background(CommonColors.background)
            .navigationTitle("Все цитаты")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CommonSecondaryButton("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - JSON Quote Management View
struct JSONQuoteManagementView: View {
    @ObservedObject var jsonQuoteManager: JSONQuoteManager
    @Environment(\.dismiss) private var dismiss
    @State private var newCategoryName = ""
    @State private var showAddCategory = false
    
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
                    // Список категорий
                    List {
                        ForEach(jsonQuoteManager.categories) { category in
                            NavigationLink(destination: JSONCategoryQuotesView(jsonQuoteManager: jsonQuoteManager, category: category)) {
                                JSONCategoryCard(category: category)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    jsonQuoteManager.removeCategory(category)
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
            .navigationTitle("Категории цитат")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddCategory = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .alert("Добавить категорию", isPresented: $showAddCategory) {
                TextField("Название категории", text: $newCategoryName)
                Button("Отмена", role: .cancel) { }
                Button("Добавить") {
                    if !newCategoryName.isEmpty {
                        jsonQuoteManager.addCategory(name: newCategoryName)
                        newCategoryName = ""
                    }
                }
            }
        }
    }
}

// MARK: - JSON Category Card
struct JSONCategoryCard: View {
    let category: QuoteCategory
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка категории
            Image(systemName: "quote.bubble.fill")
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                )
            
            // Информация о категории
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("\(category.quotes.count) цитат")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - JSON Category Quotes View
struct JSONCategoryQuotesView: View {
    @ObservedObject var jsonQuoteManager: JSONQuoteManager
    let category: QuoteCategory
    @State private var showAddQuote = false
    @State private var newQuoteText = ""
    
    var body: some View {
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
                if category.quotes.isEmpty {
                    // Пустое состояние
                    VStack(spacing: 20) {
                        Image(systemName: "quote.bubble")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Нет цитат в категории")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Добавьте первую цитату")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Список цитат
                    List {
                        ForEach(category.quotes, id: \.self) { quote in
                            JSONQuoteCard(quote: quote, category: category, jsonQuoteManager: jsonQuoteManager)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        jsonQuoteManager.removeQuote(quote, from: category)
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
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddQuote = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
        }
        .alert("Добавить цитату", isPresented: $showAddQuote) {
            TextField("Текст цитаты", text: $newQuoteText)
            Button("Отмена", role: .cancel) { }
            Button("Добавить") {
                if !newQuoteText.isEmpty {
                    jsonQuoteManager.addQuote(newQuoteText, to: category.name)
                    newQuoteText = ""
                }
            }
        }
    }
}

// MARK: - JSON Quote Card
struct JSONQuoteCard: View {
    let quote: String
    let category: QuoteCategory
    @ObservedObject var jsonQuoteManager: JSONQuoteManager
    @State private var isEditing = false
    @State private var editedText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isEditing {
                // Режим редактирования
                VStack(alignment: .leading, spacing: 12) {
                    Text("Редактировать цитату")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $editedText)
                        .font(.body)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                        .frame(minHeight: 80)
                        .submitLabel(.done)
                        .onSubmit {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    
                    // Кнопки
                    HStack(spacing: 12) {
                        Button("Отмена") {
                            isEditing = false
                            editedText = quote
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                        )
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Сохранить") {
                            if !editedText.isEmpty {
                                jsonQuoteManager.updateQuote(quote, newText: editedText, in: category)
                                isEditing = false
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    }
                }
            } else {
                // Режим просмотра
                Text(quote)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        isEditing = true
                        editedText = quote
                    }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
        .frame(maxWidth: .infinity)
    }
}



// MARK: - JSON Category Button
struct JSONCategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? 
                    AnyShapeStyle(
                        LinearGradient(
                            colors: [.orange, .orange.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    ) : 
                    AnyShapeStyle(Color(.systemGray6))
                )
                .cornerRadius(20)
                .shadow(color: isSelected ? .orange.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        }
    }
}
