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
                Text("Добавьте классы персонажа для отображения способностей")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(character.characterClasses, id: \.id) { characterClass in
                    ClassAbilitiesCard(
                        characterClass: characterClass,
                        gameClass: classesStore.classesBySlug[characterClass.slug]
                    )
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
    let gameClass: GameClass?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Class header
            HStack {
                Text(characterClass.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                
                Spacer()
                
                Text("Уровень \(characterClass.level)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Subclass
            if let subclass = characterClass.subclass, !subclass.isEmpty {
                Text("Подкласс: \(subclass)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            // Class features by level
            if let gameClass = gameClass {
                ClassFeaturesView(gameClass: gameClass, characterClass: characterClass)
            } else {
                Text("Информация о классе недоступна")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ClassFeaturesView: View {
    let gameClass: GameClass
    let characterClass: CharacterClass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Классовые умения:")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            ForEach(1...characterClass.level, id: \.self) { level in
                if let features = gameClass.featuresByLevel["\(level)"], !features.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Уровень \(level):")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                        
                        ForEach(features, id: \.name) { feature in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(feature.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                if !feature.text.isEmpty {
                                    Text(feature.text)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(3)
                                }
                            }
                            .padding(.leading, 8)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            
            // Subclass features
            if let subclassName = characterClass.subclass,
               let subclass = gameClass.subclasses.first(where: { $0.name == subclassName }) {
                
                Text("Умения подкласса (\(subclassName)):")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.top, 8)
                
                ForEach(3...characterClass.level, id: \.self) { level in
                    if let features = subclass.featuresByLevel["\(level)"], !features.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Уровень \(level):")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                            
                            ForEach(features, id: \.name) { feature in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(feature.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    if !feature.text.isEmpty {
                                        Text(feature.text)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .lineLimit(3)
                                    }
                                }
                                .padding(.leading, 8)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
    }
}
