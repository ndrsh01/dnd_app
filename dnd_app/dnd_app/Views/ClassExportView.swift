import SwiftUI

struct ClassExportView: View {
    let character: Character
    let classSlug: String
    @State private var showingExportSheet = false
    @State private var exportText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок секции
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.green)
                }
                
                Text("Экспорт умений")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    generateExportText()
                    showingExportSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text")
                            .font(.caption)
                        Text("Экспорт")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green)
                    )
                }
            }
            
            // Информация об экспорте
            VStack(alignment: .leading, spacing: 8) {
                Text("Экспортируйте все классовые умения в текстовом формате для использования в других приложениях или для печати.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
                
                if let featuresForClass = character.classFeatures[classSlug] {
                    let totalFeatures = featuresForClass.values.flatMap { $0 }.count
                    Text("Доступно для экспорта: \(totalFeatures) умений")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(24)
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
                        colors: [.green.opacity(0.3), .green.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .sheet(isPresented: $showingExportSheet) {
            ExportSheetView(exportText: exportText, characterName: character.name, className: character.characterClass)
        }
    }
    
    private func generateExportText() {
        guard let featuresForClass = character.classFeatures[classSlug] else {
            exportText = "Нет данных для экспорта"
            return
        }
        
        var text = "КЛАССОВЫЕ УМЕНИЯ\n"
        text += "Персонаж: \(character.name)\n"
        text += "Класс: \(character.characterClass)\n"
        text += "Уровень: \(character.level)\n"
        text += "Дата экспорта: \(Date().formatted(date: .abbreviated, time: .shortened))\n"
        text += "=" * 50 + "\n\n"
        
        let sortedLevels = featuresForClass.keys.sorted { Int($0) ?? 0 < Int($1) ?? 0 }
        
        for level in sortedLevels {
            if let features = featuresForClass[level] {
                text += "УРОВЕНЬ \(level)\n"
                text += "-" * 30 + "\n"
                
                for feature in features {
                    text += "\(feature.name)\n"
                    text += "\(feature.text)\n\n"
                }
            }
        }
        
        text += "\n" + "=" * 50 + "\n"
        text += "Экспорт завершен. Всего умений: \(featuresForClass.values.flatMap { $0 }.count)\n"
        
        exportText = text
    }
}

struct ExportSheetView: View {
    let exportText: String
    let characterName: String
    let className: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Заголовок
                VStack(spacing: 8) {
                    Text("Экспорт умений")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(characterName) - \(className)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Текст для экспорта
                ScrollView {
                    Text(exportText)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .textSelection(.enabled)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(
                        item: exportText,
                        subject: Text("Классовые умения \(characterName)"),
                        message: Text("Экспорт классовых умений для \(characterName)")
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

// Вспомогательная функция для повторения строки
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
