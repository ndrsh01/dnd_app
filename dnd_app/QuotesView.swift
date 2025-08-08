import SwiftUI

struct QuotesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedCategory: QuoteCategory?
    @State private var showingAddQuote = false
    @State private var currentQuote: Quote?
    
    var body: some View {
        NavigationView {
            VStack {
                // Random Quote Card
                if let quote = currentQuote {
                    QuoteCard(quote: quote) {
                        currentQuote = dataManager.getRandomQuote(for: selectedCategory)
                    }
                    .padding()
                }
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryButton(title: "Все", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                            currentQuote = dataManager.getRandomQuote()
                        }
                        
                        ForEach(QuoteCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                title: category.rawValue,
                                icon: category.icon,
                                color: category.color,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                                currentQuote = dataManager.getRandomQuote(for: category)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Favorites Section
                if !dataManager.quotes.filter({ $0.isFavorite }).isEmpty {
                    VStack(alignment: .leading) {
                        Text("Избранное")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(dataManager.quotes.filter { $0.isFavorite }) { quote in
                                    FavoriteQuoteCard(quote: quote) {
                                        dataManager.toggleFavorite(quote)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Цитаты D&D")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddQuote = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                if currentQuote == nil {
                    currentQuote = dataManager.getRandomQuote()
                }
            }
            .sheet(isPresented: $showingAddQuote) {
                AddQuoteView()
                    .environmentObject(dataManager)
            }
        }
    }
}

struct QuoteCard: View {
    let quote: Quote
    let onRefresh: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: quote.category.icon)
                .font(.system(size: 40))
                .foregroundColor(quote.category.color)
            
            Text(quote.text)
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            Text("— \(quote.author)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text(quote.category.rawValue)
                    .font(.caption)
                    .foregroundColor(quote.category.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(quote.category.color.opacity(0.2))
                    .cornerRadius(12)
                
                Spacer()
                
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct CategoryButton: View {
    let title: String
    var icon: String?
    var color: Color = .orange
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? color : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FavoriteQuoteCard: View {
    let quote: Quote
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: quote.category.icon)
                    .foregroundColor(quote.category.color)
                    .font(.caption)
                
                Spacer()
                
                Button(action: onToggleFavorite) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Text(quote.text)
                .font(.caption)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            Text("— \(quote.author)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(width: 200)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct AddQuoteView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var text = ""
    @State private var author = ""
    @State private var selectedCategory: QuoteCategory = .wisdom
    
    var body: some View {
        NavigationView {
            Form {
                Section("Текст цитаты") {
                    TextEditor(text: $text)
                        .frame(minHeight: 100)
                }
                
                Section("Автор") {
                    TextField("Автор", text: $author)
                }
                
                Section("Категория") {
                    Picker("Категория", selection: $selectedCategory) {
                        ForEach(QuoteCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Добавить цитату")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        let quote = Quote(text: text, author: author, category: selectedCategory)
                        dataManager.addQuote(quote)
                        dismiss()
                    }
                    .disabled(text.isEmpty || author.isEmpty)
                }
            }
        }
    }
}

#Preview {
    QuotesView()
        .environmentObject(DataManager())
}
