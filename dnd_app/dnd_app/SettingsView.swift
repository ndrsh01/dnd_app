import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    @StateObject private var quoteManager = QuoteManager()
    @StateObject private var cacheManager = CacheManager.shared
    @State private var showingQuoteManager = false
    
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
                
                ScrollView {
                    VStack(spacing: 20) {
                    // Заголовок
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange.opacity(0.2), .orange.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .blur(radius: 20)
                            
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                                .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Настройки")
                                .font(.system(.largeTitle, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Управление приложением")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.secondary)
                        }
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
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(.systemBackground),
                                            Color(.systemBackground).opacity(0.8)
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
                        .cornerRadius(20)
                        
                        // Информация о приложении
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                
                                Text("О приложении")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "Версия", value: "1.0.0")
                                InfoRow(title: "Разработчик", value: "ndrsh01")
                                InfoRow(title: "Платформа", value: "iOS 15.0+")
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(.systemBackground),
                                            Color(.systemBackground).opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        )
                        .cornerRadius(20)
                        
                        // Статистика
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.green)
                                
                                Text("Статистика")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "Заклинаний", value: "500+")
                                InfoRow(title: "Заметок", value: "Безлимитно")
                                InfoRow(title: "Персонажей", value: "10+")
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(.systemBackground),
                                            Color(.systemBackground).opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .stroke(
                                    LinearGradient(
                                        colors: [.green.opacity(0.3), .green.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        )
                        .cornerRadius(20)
                        
                        // Управление цитатами
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "quote.bubble.fill")
                                    .foregroundColor(.purple)
                                
                                Text("Цитаты")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
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
                                InfoRow(title: "Пользовательских", value: "\(quoteManager.categories.filter { $0.isCustom }.count)")
                                InfoRow(title: "Избранных", value: "\(quoteManager.favorites.count)")
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(.systemBackground),
                                            Color(.systemBackground).opacity(0.8)
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
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        )
                        .cornerRadius(20)
                        
                        // Управление кэшем
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "memorychip.fill")
                                    .foregroundColor(.blue)
                                
                                Text("Кэш приложения")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button(action: {
                                    cacheManager.clearAllCaches()
                                }) {
                                    HStack(spacing: 4) {
                                        Text("Очистить")
                                        Image(systemName: "trash")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.red)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(title: "Изображений", value: "\(cacheManager.cacheStats.imageCacheCount)")
                                InfoRow(title: "Данных", value: "\(cacheManager.cacheStats.dataCacheCount)")
                                InfoRow(title: "Объектов", value: "\(cacheManager.cacheStats.objectCacheCount)")
                                InfoRow(title: "Использование памяти", value: "\(cacheManager.cacheStats.totalMemoryUsage / 1024 / 1024) MB")
                                InfoRow(title: "Процент попаданий", value: "\(String(format: "%.1f", cacheManager.getCacheHitRate() * 100))%")
                                InfoRow(title: "Всего обращений", value: "\(cacheManager.cacheStats.cacheHits + cacheManager.cacheStats.cacheMisses)")
                                InfoRow(title: "Успешных обращений", value: "\(cacheManager.cacheStats.cacheHits)")
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(.systemBackground),
                                            Color(.systemBackground).opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                        )
                        .cornerRadius(20)
                    }
                    .padding(.horizontal)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 100) // Добавляем отступ снизу для нижнего меню
                }
            }
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingQuoteManager) {
                QuoteManagerView(quoteManager: quoteManager)
            }
        }
        .onAppear {
            // Обновляем данные при появлении
            // Категории теперь управляются внутри QuoteManager
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
    @State private var selectedTab = 0
    @State private var selectedCategory: String = ""
    @State private var editingQuote: String? = nil
    @State private var editedText: String = ""
    @State private var showingAddQuote = false
    @State private var newQuoteText = ""
    @State private var newQuoteCategory = ""
    @State private var searchText = ""
    
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
                    // Заголовок
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange.opacity(0.2), .orange.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .blur(radius: 15)
                            
                            Image(systemName: "quote.bubble.fill")
                                .font(.system(size: 35))
                                .foregroundColor(.orange)
                                .shadow(color: .orange.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Управление цитатами")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Редактируйте и управляйте цитатами")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
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
                    .padding(.bottom, 20)
                    
                    if selectedTab == 0 {
                        // Вкладка цитат
                        VStack(spacing: 16) {
                            // Поиск
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
                            
                            // Фильтр категорий
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    Button(action: { selectedCategory = "" }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "list.bullet")
                                            Text("Все")
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedCategory.isEmpty ? 
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
                                        .foregroundColor(selectedCategory.isEmpty ? .white : .primary)
                                        .cornerRadius(20)
                                        .shadow(color: selectedCategory.isEmpty ? .orange.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                                    }
                                    
                                    ForEach(quoteManager.categories, id: \.id) { category in
                                        Button(action: { selectedCategory = category.name }) {
                                            HStack(spacing: 6) {
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
                            
                            // Список цитат
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(filteredQuotes, id: \.id) { quote in
                                        ModernQuoteRowView(
                                            quote: quote,
                                            isEditing: editingQuote == quote.text,
                                            editedText: $editedText,
                                            onEdit: { startEditing(quote) },
                                            onSave: { saveEdit() },
                                            onCancel: { cancelEdit() },
                                            onDelete: { deleteQuote(quote) }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 100)
                            }
                        }
                    } else {
                        // Вкладка категорий
                        ModernCategoriesView(quoteManager: quoteManager)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTab == 0 {
                        Button(action: {
                            showingAddQuote = true
                            newQuoteText = ""
                            newQuoteCategory = selectedCategory.isEmpty ? (quoteManager.categories.first?.name ?? "Общие") : selectedCategory
                        }) {
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
            }
            .sheet(isPresented: $showingAddQuote) {
                ModernAddQuoteView(
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
    
    private var filteredQuotes: [Quote] {
        var quotes: [Quote] = []
        
        if selectedCategory.isEmpty {
            quotes = quoteManager.quotes.values.flatMap { $0 }
        } else {
            quotes = quoteManager.quotes[selectedCategory] ?? []
        }
        
        // Фильтр по поиску
        if !searchText.isEmpty {
            quotes = quotes.filter { quote in
                quote.text.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return quotes
    }
    
    private func categoryForQuote(_ quote: Quote) -> String {
        return quote.category
    }
    
    private func startEditing(_ quote: Quote) {
        editingQuote = quote.text
        editedText = quote.text
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
    
    private func deleteQuote(_ quote: Quote) {
        quoteManager.removeQuoteByText(quote.text)
    }
    
    private func addNewQuote() {
        guard !newQuoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !newQuoteCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        quoteManager.addQuote(category: newQuoteCategory, text: newQuoteText)
        showingAddQuote = false
    }
}

// MARK: - Modern Quote Row View
struct ModernQuoteRowView: View {
    let quote: Quote
    let isEditing: Bool
    @Binding var editedText: String
    let onEdit: () -> Void
    let onSave: () -> Void
    let onCancel: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок с категорией и действиями
            HStack {
                HStack(spacing: 8) {
                    Text(quote.category)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    
                    if quote.isCustom {
                        Text("Пользовательская")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.orange.opacity(0.1))
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
                
                Spacer()
                
                if !isEditing {
                    HStack(spacing: 12) {
                        if quote.isCustom {
                            Button(action: onEdit) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Button(action: onDelete) {
                            Image(systemName: "trash.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            // Контент
            if isEditing {
                VStack(spacing: 16) {
                    TextEditor(text: $editedText)
                        .frame(minHeight: 100)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .stroke(
                                    LinearGradient(
                                        colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .cornerRadius(12)
                    
                    HStack(spacing: 16) {
                        Button("Отмена") {
                            onCancel()
                        }
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .cornerRadius(12)
                        
                        Spacer()
                        
                        Button("Сохранить") {
                            onSave()
                        }
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .orange.opacity(0.3), radius: 6, x: 0, y: 3)
                        )
                    }
                }
            } else {
                Text(quote.text)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Дата создания
                HStack {
                    Text(quote.dateCreated, style: .date)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding(20)
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
                        colors: [.orange.opacity(0.2), .orange.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .cornerRadius(20)
    }
}

// MARK: - Modern Categories View
struct ModernCategoriesView: View {
    @ObservedObject var quoteManager: QuoteManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(quoteManager.categories, id: \.id) { category in
                    ModernCategoryRowView(category: category, quoteManager: quoteManager)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Modern Category Row View
struct ModernCategoryRowView: View {
    let category: Category
    @ObservedObject var quoteManager: QuoteManager
    @State private var showingEditCategory = false
    @State private var editedCategoryName = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(category.name)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if category.isCustom {
                            Text("Пользовательская")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.orange.opacity(0.1))
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    
                    Text("Цитат: \(quoteManager.quotes[category.name]?.count ?? 0)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if category.isCustom {
                    HStack(spacing: 12) {
                        Button(action: {
                            editedCategoryName = category.name
                            showingEditCategory = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            quoteManager.removeCategory(category)
                        }) {
                            Image(systemName: "trash.circle.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(20)
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
                        colors: [.orange.opacity(0.2), .orange.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .cornerRadius(20)
        .sheet(isPresented: $showingEditCategory) {
            ModernEditCategoryView(
                categoryName: $editedCategoryName,
                onSave: {
                    if !editedCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        quoteManager.editCategory(category, newName: editedCategoryName)
                    }
                }
            )
        }
    }
}

// MARK: - Modern Add Quote View
struct ModernAddQuoteView: View {
    @Binding var text: String
    @Binding var category: String
    let categories: [Category]
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
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
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $text)
                            .frame(minHeight: 120)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
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
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Категория")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Picker("Категория", selection: $category) {
                            ForEach(categories, id: \.id) { cat in
                                Text(cat.name).tag(cat.name)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
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
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Новая цитата")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onSave()
                        }
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Modern Edit Category View
struct ModernEditCategoryView: View {
    @Binding var categoryName: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
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
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        TextField("Введите название", text: $categoryName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(.body, design: .rounded))
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Редактировать категорию")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if !categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onSave()
                            dismiss()
                        }
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
                    .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Quote Row View
struct QuoteRowView: View {
    let quote: Quote
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
                Text(quote.text)
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
    let categories: [Category]
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
                                    ForEach(categories, id: \.id) { cat in
                                        Text(cat.name).tag(cat.name)
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
