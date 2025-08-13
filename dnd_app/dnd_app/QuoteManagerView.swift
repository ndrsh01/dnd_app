import SwiftUI

struct QuoteManagerView: View {
    @ObservedObject var quoteManager: QuoteManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var editingCategory: Category?
    @State private var editingCategoryName = ""
    
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
                    // Segmented Control
                    Picker("", selection: $selectedTab) {
                        HStack {
                            Image(systemName: "quote.bubble")
                            Text("Цитаты")
                        }.tag(0)
                        HStack {
                            Image(systemName: "folder")
                            Text("Категории")
                        }.tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if selectedTab == 0 {
                        QuotesListView(quoteManager: quoteManager)
                    } else {
                        CategoriesListView(
                            quoteManager: quoteManager,
                            showingAddCategory: $showingAddCategory,
                            editingCategory: $editingCategory,
                            editingCategoryName: $editingCategoryName
                        )
                    }
                }
            }
            .navigationTitle("Управление цитатами")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTab == 1 {
                        Button("Добавить") {
                            showingAddCategory = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView(quoteManager: quoteManager, isPresented: $showingAddCategory)
            }
            .sheet(item: $editingCategory) { category in
                EditCategoryView(
                    quoteManager: quoteManager,
                    category: category,
                    isPresented: Binding(
                        get: { editingCategory != nil },
                        set: { if !$0 { editingCategory = nil } }
                    )
                )
            }
        }
    }
}

// MARK: - Quotes List View
struct QuotesListView: View {
    @ObservedObject var quoteManager: QuoteManager
    @State private var searchText = ""
    @State private var selectedCategory: String?
    
    var filteredQuotes: [(String, [Quote])] {
        var result: [(String, [Quote])] = []
        
        for (categoryName, quotesArray) in quoteManager.quotes {
            if let selectedCategory = selectedCategory, selectedCategory != categoryName {
                continue
            }
            
            let filteredQuotes = quotesArray.filter { quote in
                searchText.isEmpty || quote.text.localizedCaseInsensitiveContains(searchText)
            }
            
            if !filteredQuotes.isEmpty {
                result.append((categoryName, filteredQuotes))
            }
        }
        
        return result.sorted { $0.0 < $1.0 }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Поиск цитат...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(.systemGray6),
                                    Color(.systemGray6).opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .stroke(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button(action: { selectedCategory = nil }) {
                            HStack {
                                Image(systemName: "list.bullet")
                                Text("Все")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                selectedCategory == nil ? 
                                AnyShapeStyle(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                ) : 
                                AnyShapeStyle(
                                    LinearGradient(
                                        colors: [Color(.systemGray5), Color(.systemGray5).opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            )
                            .foregroundColor(selectedCategory == nil ? .white : .primary)
                            .cornerRadius(20)
                            .shadow(color: selectedCategory == nil ? .orange.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                        }
                        
                        ForEach(quoteManager.categories, id: \.id) { category in
                            Button(action: { selectedCategory = category.name }) {
                                HStack {
                                    Image(systemName: category.isCustom ? "person.crop.circle" : "gear")
                                    Text(category.name)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    selectedCategory == category.name ? 
                                    AnyShapeStyle(
                                        LinearGradient(
                                            colors: [.orange, .orange.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    ) : 
                                    AnyShapeStyle(
                                        LinearGradient(
                                            colors: [Color(.systemGray5), Color(.systemGray5).opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                )
                                .foregroundColor(selectedCategory == category.name ? .white : .primary)
                                .cornerRadius(20)
                                .shadow(color: selectedCategory == category.name ? .orange.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            
            // Quotes List
            List {
                ForEach(filteredQuotes, id: \.0) { categoryName, quotes in
                    Section(header: Text(categoryName).font(.headline).foregroundColor(.primary)) {
                        ForEach(quotes, id: \.id) { quote in
                            QuoteRowView(quote: quote, quoteManager: quoteManager)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

// MARK: - Quote Row View
struct QuoteRowView: View {
    let quote: Quote
    @ObservedObject var quoteManager: QuoteManager
    @State private var showingEdit = false
    @State private var editedText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(quote.text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                
                Spacer()
                
                if quote.isCustom {
                    Button(action: { 
                        editedText = quote.text
                        showingEdit = true 
                    }) {
                        Image(systemName: "pencil.circle")
                            .foregroundColor(.orange)
                    }
                }
            }
            
            HStack {
                Text(quote.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray6))
                    )
                
                if quote.isCustom {
                    Text("Пользовательская")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.1))
                        )
                }
                
                Spacer()
                
                Text(quote.dateCreated, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEdit) {
            EditQuoteView(
                quoteManager: quoteManager,
                oldQuote: quote.text,
                newQuote: $editedText,
                isPresented: $showingEdit
            )
        }
    }
}

// MARK: - Categories List View
struct CategoriesListView: View {
    @ObservedObject var quoteManager: QuoteManager
    @Binding var showingAddCategory: Bool
    @Binding var editingCategory: Category?
    @Binding var editingCategoryName: String
    
    var body: some View {
        List {
            ForEach(quoteManager.categories, id: \.id) { category in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(category.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if category.isCustom {
                                Text("Пользовательская")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color.orange.opacity(0.1))
                                    )
                            }
                        }
                        
                        Text("Цитат: \(quoteManager.quotes[category.name]?.count ?? 0)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if category.isCustom {
                        HStack(spacing: 12) {
                            Button(action: {
                                editingCategoryName = category.name
                                editingCategory = category
                            }) {
                                Image(systemName: "pencil.circle")
                                    .foregroundColor(.blue)
                            }
                            
                            Button(action: {
                                quoteManager.removeCategory(category)
                            }) {
                                Image(systemName: "trash.circle")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Add Category View
struct AddCategoryView: View {
    @ObservedObject var quoteManager: QuoteManager
    @Binding var isPresented: Bool
    @State private var categoryName = ""
    
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
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Название категории")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Введите название", text: $categoryName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .stroke(
                                LinearGradient(
                                    colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 30)
            }
            .navigationTitle("Новая категория")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        if !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            quoteManager.addCategory(name: categoryName)
                            isPresented = false
                        }
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Category View
struct EditCategoryView: View {
    @ObservedObject var quoteManager: QuoteManager
    let category: Category
    @Binding var isPresented: Bool
    @State private var categoryName: String
    
    init(quoteManager: QuoteManager, category: Category, isPresented: Binding<Bool>) {
        self.quoteManager = quoteManager
        self.category = category
        self._isPresented = isPresented
        self._categoryName = State(initialValue: category.name)
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
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Название категории")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Введите название", text: $categoryName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .stroke(
                                LinearGradient(
                                    colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 30)
            }
            .navigationTitle("Редактировать категорию")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            quoteManager.editCategory(category, newName: categoryName)
                            isPresented = false
                        }
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Quote View
struct EditQuoteView: View {
    @ObservedObject var quoteManager: QuoteManager
    let oldQuote: String
    @Binding var newQuote: String
    @Binding var isPresented: Bool
    
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
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Текст цитаты")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $newQuote)
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .stroke(
                                LinearGradient(
                                    colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 30)
            }
            .navigationTitle("Редактировать цитату")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if !newQuote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            quoteManager.editQuote(oldQuote: oldQuote, newQuote: newQuote)
                            isPresented = false
                        }
                    }
                    .disabled(newQuote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
