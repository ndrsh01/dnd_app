import SwiftUI

struct ClassStatsView: View {
    let character: Character
    let classSlug: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок секции
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.orange)
                }
                
                Text("Статистика класса")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Статистика
            if let featuresForClass = character.classFeatures[classSlug] {
                let totalFeatures = featuresForClass.values.flatMap { $0 }.count
                let levelsWithFeatures = featuresForClass.keys.count
                let currentLevel = character.level
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    StatCard(
                        title: "Всего умений",
                        value: "\(totalFeatures)",
                        icon: "star.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Уровней с умениями",
                        value: "\(levelsWithFeatures)",
                        icon: "number.circle.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Текущий уровень",
                        value: "\(currentLevel)",
                        icon: "arrow.up.circle.fill",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "Всего уровней",
                        value: "20",
                        icon: "crown.fill",
                        color: .purple
                    )
                }
                
                // Прогресс уровня
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Прогресс уровня")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(currentLevel)/20")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: Double(currentLevel), total: 20)
                        .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                        .scaleEffect(y: 1.5)
                }
                .padding(.top, 8)
            } else {
                Text("Статистика не доступна")
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
                        colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}
