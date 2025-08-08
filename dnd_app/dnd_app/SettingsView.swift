import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    @StateObject private var quoteManager = QuoteManager()
    @State private var showingQuoteManager = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeManager.adaptiveBackground(for: themeManager.isDarkMode)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Заголовок
                    VStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Настройки")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(ThemeManager.adaptiveTextColor(for: themeManager.isDarkMode))
                    }
                    
                    // Настройки
                    VStack(spacing: 16) {
                        // Переключение темы
                        HStack {
                            Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Тема приложения")
                                    .font(.headline)
                                    .foregroundColor(ThemeManager.adaptiveTextColor(for: themeManager.isDarkMode))
                                
                                Text(themeManager.isDarkMode ? "Темная тема" : "Светлая тема")
                                    .font(.caption)
                                    .foregroundColor(ThemeManager.adaptiveSecondaryTextColor(for: themeManager.isDarkMode))
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $themeManager.isDarkMode)
                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                        }
                        .padding()
                        .background(ThemeManager.adaptiveCardBackground(for: themeManager.isDarkMode))
                        .cornerRadius(12)
                        
                        // Информация о приложении
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                
                                Text("О приложении")
                                    .font(.headline)
                                    .foregroundColor(ThemeManager.adaptiveTextColor(for: themeManager.isDarkMode))
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "Версия", value: "1.0.0")
                                InfoRow(title: "Разработчик", value: "ndrsh01")
                                InfoRow(title: "Платформа", value: "iOS 15.0+")
                            }
                        }
                        .padding()
                        .background(ThemeManager.adaptiveCardBackground(for: themeManager.isDarkMode))
                        .cornerRadius(12)
                        
                        // Статистика
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.green)
                                
                                Text("Статистика")
                                    .font(.headline)
                                    .foregroundColor(ThemeManager.adaptiveTextColor(for: themeManager.isDarkMode))
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "Заклинаний", value: "500+")
                                InfoRow(title: "Заметок", value: "Безлимитно")
                                InfoRow(title: "Персонажей", value: "10+")
                            }
                        }
                        .padding()
                        .background(ThemeManager.adaptiveCardBackground(for: themeManager.isDarkMode))
                        .cornerRadius(12)
                        
                        // Управление цитатами
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "quote.bubble.fill")
                                    .foregroundColor(.purple)
                                
                                Text("Цитаты")
                                    .font(.headline)
                                    .foregroundColor(ThemeManager.adaptiveTextColor(for: themeManager.isDarkMode))
                                
                                Spacer()
                                
                                Button(action: {
                                    showingQuoteManager = true
                                }) {
                                    HStack(spacing: 4) {
                                        Text("Управление")
                                        Image(systemName: "chevron.right")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.purple)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "Всего цитат", value: "\(quoteManager.quotes.values.flatMap { $0 }.count)")
                                InfoRow(title: "Категорий", value: "\(quoteManager.categories.count)")
                                InfoRow(title: "Избранных", value: "\(quoteManager.favorites.count)")
                            }
                        }
                        .padding()
                        .background(ThemeManager.adaptiveCardBackground(for: themeManager.isDarkMode))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 30)
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingQuoteManager) {
                QuoteManagerView(quoteManager: quoteManager)
            }
        }
        .onAppear {
            // Обновляем данные при появлении
            quoteManager.categories = quoteManager.quotes.keys.sorted()
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Quote Manager View
struct QuoteManagerView: View {
    @ObservedObject var quoteManager: QuoteManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: String = ""
    @State private var editingQuote: String? = nil
    @State private var editedText: String = ""
    @State private var showingAddQuote = false
    @State private var newQuoteText = ""
    @State private var newQuoteCategory = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#fceeda")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Выбор категории
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Button("Все") {
                                selectedCategory = ""
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory.isEmpty ? Color.orange : Color(.systemGray6))
                            )
                            .foregroundColor(selectedCategory.isEmpty ? .white : .primary)
                            
                            ForEach(quoteManager.categories, id: \.self) { category in
                                Button(category) {
                                    selectedCategory = category
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selectedCategory == category ? Color.orange : Color(.systemGray6))
                                )
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                    
                    // Список цитат
                    List {
                        ForEach(filteredQuotes, id: \.self) { quote in
                            QuoteRowView(
                                quote: quote,
                                category: categoryForQuote(quote),
                                isEditing: editingQuote == quote,
                                editedText: $editedText,
                                onEdit: { startEditing(quote) },
                                onSave: { saveEdit() },
                                onCancel: { cancelEdit() },
                                onDelete: { deleteQuote(quote) }
                            )
                        }
                    }
                    .listStyle(PlainListStyle())
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
                    Button(action: {
                        showingAddQuote = true
                        newQuoteText = ""
                        newQuoteCategory = selectedCategory.isEmpty ? (quoteManager.categories.first ?? "Общее") : selectedCategory
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showingAddQuote) {
                QuoteEditorAddView(
                    text: $newQuoteText,
                    category: $newQuoteCategory,
                    categories: quoteManager.categories,
                    onSave: { addNewQuote() }
                )
            }
        }
        .onAppear {
            // Принудительная инициализация
            _ = quoteManager.quotes
            _ = quoteManager.categories
        }
    }
    
    private var filteredQuotes: [String] {
        if selectedCategory.isEmpty {
            return quoteManager.quotes.values.flatMap { $0 }
        } else {
            return quoteManager.quotes[selectedCategory] ?? []
        }
    }
    
    private func categoryForQuote(_ quote: String) -> String {
        for (category, quotes) in quoteManager.quotes {
            if quotes.contains(quote) {
                return category
            }
        }
        return "Неизвестно"
    }
    
    private func startEditing(_ quote: String) {
        editingQuote = quote
        editedText = quote
    }
    
    private func saveEdit() {
        guard let originalQuote = editingQuote,
              !editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        quoteManager.editQuote(oldQuote: originalQuote, newQuote: editedText)
        cancelEdit()
    }
    
    private func cancelEdit() {
        editingQuote = nil
        editedText = ""
    }
    
    private func deleteQuote(_ quote: String) {
        quoteManager.removeQuoteByText(quote)
    }
    
    private func addNewQuote() {
        guard !newQuoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !newQuoteCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        quoteManager.addQuote(category: newQuoteCategory, text: newQuoteText)
        showingAddQuote = false
    }
}

// MARK: - Quote Row View
struct QuoteRowView: View {
    let quote: String
    let category: String
    let isEditing: Bool
    @Binding var editedText: String
    let onEdit: () -> Void
    let onSave: () -> Void
    let onCancel: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.1))
                    )
                
                Spacer()
                
                if !isEditing {
                    Button("Редактировать") {
                        onEdit()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            if isEditing {
                VStack(spacing: 12) {
                    TextField("Текст цитаты", text: $editedText, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...10)
                    
                    HStack {
                        Button("Отмена") {
                            onCancel()
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Сохранить") {
                            onSave()
                        }
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    }
                }
            } else {
                Text(quote)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Удалить", role: .destructive) {
                onDelete()
            }
        }
    }
}

// MARK: - Quote Editor Add View
struct QuoteEditorAddView: View {
    @Binding var text: String
    @Binding var category: String
    let categories: [String]
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isCreatingNewCategory = false
    @State private var newCategoryName = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#fceeda")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Поле текста цитаты
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Текст цитаты")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        TextField("Введите цитату...", text: $text, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...10)
                            .frame(minHeight: 100)
                    }
                    
                    // Выбор категории
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Категория")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if isCreatingNewCategory {
                            HStack {
                                TextField("Новая категория", text: $newCategoryName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button("Отмена") {
                                    isCreatingNewCategory = false
                                    newCategoryName = ""
                                }
                                .foregroundColor(.secondary)
                            }
                        } else {
                            HStack {
                                Picker("Категория", selection: $category) {
                                    ForEach(categories, id: \.self) { cat in
                                        Text(cat).tag(cat)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                
                                Button("Новая") {
                                    isCreatingNewCategory = true
                                }
                                .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Добавить цитату")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if isCreatingNewCategory && !newCategoryName.isEmpty {
                            category = newCategoryName
                        }
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                             (isCreatingNewCategory && newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
                }
            }
        }
    }
}
