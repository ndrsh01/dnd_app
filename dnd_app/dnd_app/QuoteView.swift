import SwiftUI
import AVFoundation

struct QuoteView: View {
    @EnvironmentObject var manager: QuoteManager
    @State private var selectedCategory: String? = nil
    @State private var showAdd = false
    @State private var animateCat = false
    @State private var currentTabaxiPose = "tabaxi_pose3"
    
    // Все доступные позы табакси
    private let tabaxiPoses = ["tabaxi_pose1", "tabaxi_pose2", "tabaxi_pose3", "tabaxi_pose4", "tabaxi_pose5", "tabaxi_pose6", "tabaxi_pose7"]

    var body: some View {
        NavigationStack {
                VStack(spacing: 0) {
                // Категория
                if !manager.categories.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryButton(
                                title: "Все",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(manager.categories, id: \.self) { category in
                                CategoryButton(
                                    title: category,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                }

                                // Цитата с треугольником сверху
                VStack(spacing: 20) {
                    ZStack(alignment: .bottomTrailing) {
                        VStack(spacing: 0) {
                            // Пузырь с цитатой
                            VStack(spacing: 16) {
                                Text(manager.currentQuote.isEmpty ? "Нажми «Случайная цитата» — и мудрость табакси снизойдёт." : manager.currentQuote)
                                    .multilineTextAlignment(.leading)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 20)
                                    .padding(.bottom, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                            
                            // Треугольник внизу
                            Triangle()
                                .fill(Color(.systemBackground))
                                .frame(width: 20, height: 10)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Изображение табакси ниже цитаты
                    Image(currentTabaxiPose)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .scaleEffect(animateCat ? 1.05 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: animateCat)
                }

                    Spacer()

                // Кнопка "Случайно" внизу отдельно
                VStack(spacing: 16) {
                    Button {
                        manager.randomQuote(in: selectedCategory)
                        // Меняем позу табакси случайно
                        currentTabaxiPose = tabaxiPoses.randomElement() ?? "tabaxi_pose3"
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            animateCat.toggle()
                        }
                    } label: {
                        Text("Случайная цитата")
                            .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(hex: "#fceeda"))
            .navigationTitle("💭 Цитаты")
                .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddQuoteView(manager: manager)
            }
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
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
                .background(isSelected ? Color.orange : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - 10, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + 10, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Add Quote View
struct AddQuoteView: View {
    @ObservedObject var manager: QuoteManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var quoteText = ""
    @State private var selectedCategory = "Общие"
    @State private var showCategoryPicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Добавить новую цитату")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Текст цитаты:")
                        .font(.headline)
                    
                    TextEditor(text: $quoteText)
                        .frame(minHeight: 100)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Категория:")
                        .font(.headline)
                    
                    Button(action: { showCategoryPicker = true }) {
                        HStack {
                            Text(selectedCategory)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Новая цитата")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        if !quoteText.isEmpty {
                            manager.addQuote(category: selectedCategory, text: quoteText)
                            dismiss()
                        }
                    }
                    .disabled(quoteText.isEmpty)
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(selectedCategory: $selectedCategory, categories: manager.categories)
            }
        }
    }
}

// MARK: - Category Picker View
struct CategoryPickerView: View {
    @Binding var selectedCategory: String
    let categories: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        dismiss()
                    }) {
                        HStack {
                            Text(category)
                            Spacer()
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Выберите категорию")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}
