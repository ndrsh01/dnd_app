import SwiftUI

struct ClassProgressionView: View {
    let character: Character
    let classSlug: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок секции
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "tablecells")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.purple)
                }
                
                Text("Таблица прогрессии")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Таблица прогрессии
            if let classTable = character.classProgression[classSlug] {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Заголовки таблицы
                        HStack(spacing: 0) {
                            ForEach(classTable.columns, id: \.self) { column in
                                Text(column)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(minWidth: 80, maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 8)
                                    .background(Color.purple)
                                    .border(Color.purple.opacity(0.3), width: 1)
                            }
                        }
                        
                        // Строки таблицы
                        ForEach(0..<classTable.rows.count, id: \.self) { index in
                            let row = classTable.rows[index]
                            TableRowView(
                                row: row,
                                columns: classTable.columns,
                                index: index,
                                characterLevel: character.level
                            )
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
            } else {
                Text("Таблица прогрессии не загружена")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
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
                        colors: [.purple.opacity(0.3), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
}

struct TableRowView: View {
    let row: [String: String]
    let columns: [String]
    let index: Int
    let characterLevel: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(columns, id: \.self) { column in
                TableCellView(
                    value: row[column] ?? "",
                    isCurrentLevel: (row[column] ?? "") == String(characterLevel),
                    isUnlocked: Int(row[column] ?? "") ?? 0 <= characterLevel,
                    index: index
                )
            }
        }
    }
}

struct TableCellView: View {
    let value: String
    let isCurrentLevel: Bool
    let isUnlocked: Bool
    let index: Int
    
    var body: some View {
        let backgroundColor: Color
        if isCurrentLevel {
            backgroundColor = .orange
        } else if isUnlocked {
            backgroundColor = index % 2 == 0 ? Color(.systemGray6) : Color(.systemBackground)
        } else {
            backgroundColor = Color(.systemGray5)
        }
        
        let textColor: Color
        if isCurrentLevel {
            textColor = .white
        } else if isUnlocked {
            textColor = .primary
        } else {
            textColor = .secondary
        }
        
        return Text(value)
            .font(.caption2)
            .fontWeight(isCurrentLevel ? .bold : .regular)
            .foregroundColor(textColor)
            .frame(minWidth: 80, maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
            )
    }
}
