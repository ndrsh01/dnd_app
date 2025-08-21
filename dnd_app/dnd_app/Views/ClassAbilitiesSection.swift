import SwiftUI

struct ClassAbilitiesSection: View {
    @Binding var character: Character
    @StateObject private var classesStore = ClassesStore()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(Color.purple.opacity(0.2)).frame(width: 28, height: 28)
                    Image(systemName: "sparkles").foregroundColor(.purple).font(.caption)
                }
                Text("Классовые умения").font(.headline).fontWeight(.semibold)
            }
            
            if character.characterClasses.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(.purple.opacity(0.6))
                    
                    Text("Добавьте классы персонажа")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("Классовые умения будут отображаться здесь")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .stroke(Color.purple.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
            } else {
                if classesStore.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Загрузка классовых умений...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    ForEach(character.characterClasses, id: \.id) { characterClass in
                        ClassAbilitiesCard(
                            characterClass: characterClass,
                            classFeatures: character.classFeatures[characterClass.slug] ?? [:],
                            classTable: character.classProgression[characterClass.slug],
                            classesStore: classesStore
                        )
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .stroke(LinearGradient(colors: [.purple.opacity(0.3), .purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
}

struct ClassAbilitiesCard: View {
    let characterClass: CharacterClass
    let classFeatures: [String: [ClassFeature]]
    let classTable: ClassTable?
    @ObservedObject var classesStore: ClassesStore
    @State private var showingProgressionTable = false
    @State private var showingFeatures = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Class header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(characterClass.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    if let subclass = characterClass.subclass, !subclass.isEmpty {
                        Text(subclass)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Уровень \(characterClass.level)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(colors: [.purple, .purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                    
                    if classTable != nil {
                        Text("Таблица прогрессии")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Quick stats from progression table
            let table = classesStore.classTablesBySlug[characterClass.slug]
            let currentLevelRow = table?.rows.first(where: { $0["Уровень"] == "\(characterClass.level)" })
            
            if let table = table, let currentLevelRow = currentLevelRow {
                VStack(spacing: 8) {
                    Text("Характеристики уровня \(characterClass.level)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                        ForEach(table.columns.dropFirst(), id: \.self) { column in
                            if let value = currentLevelRow[column] {
                                VStack(spacing: 2) {
                                    Text(column)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    
                                    Text(value)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(.systemGray6))
                                )
                            }
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                )
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: { showingProgressionTable.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "tablecells")
                            .font(.caption)
                        Text("Таблица прогрессии")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.purple.opacity(0.1))
                    )
                }
                
                Button(action: { showingFeatures.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "list.bullet")
                            .font(.caption)
                        Text("Классовые умения")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.purple.opacity(0.1))
                    )
                }
                
                Spacer()
            }
            
            // Expanded content
            if showingProgressionTable, let table = classesStore.classTablesBySlug[characterClass.slug] {
                ProgressionTableView(classTable: table, currentLevel: characterClass.level)
            }
            
            if showingFeatures {
                ClassFeaturesView(classFeatures: classFeatures, characterClass: characterClass, classesStore: classesStore)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ProgressionTableView: View {
    let classTable: ClassTable
    let currentLevel: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Таблица прогрессии")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header row
                    HStack(spacing: 0) {
                        ForEach(classTable.columns, id: \.self) { column in
                            Text(column)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(minWidth: 60, maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                                .background(Color.purple)
                        }
                    }
                    
                    // Data rows
                    ForEach(Array(classTable.rows.enumerated()), id: \.offset) { index, row in
                        HStack(spacing: 0) {
                            ForEach(classTable.columns, id: \.self) { column in
                                Text(row[column] ?? "")
                                    .font(.caption2)
                                    .foregroundColor(index == currentLevel - 1 ? .white : .primary)
                                    .frame(minWidth: 60, maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 4)
                                    .background(
                                        index == currentLevel - 1 ? Color.purple : Color.clear
                                    )
                            }
                        }
                        .background(
                            index % 2 == 0 ? Color(.systemGray6) : Color.clear
                        )
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ClassFeaturesView: View {
    let classFeatures: [String: [ClassFeature]]
    let characterClass: CharacterClass
    @ObservedObject var classesStore: ClassesStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Классовые умения")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Main class features
            let allFeatures = classesStore.features(for: characterClass.slug, upTo: characterClass.level)
            
            ForEach(1...characterClass.level, id: \.self) { level in
                let features = allFeatures.first(where: { $0.0 == level })?.1 ?? []
                if !features.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Уровень \(level)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.purple)
                                )
                            
                            Spacer()
                        }
                        
                        ForEach(features, id: \.name) { feature in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(feature.name)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                if !feature.text.isEmpty {
                                    Text(feature.text)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(6)
                                        .padding(.leading, 8)
                                }
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }
                }
            }
            

        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
}




