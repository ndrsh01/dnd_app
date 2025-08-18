import SwiftUI

// MARK: - Interactive Components for Character Editor

struct InteractiveAbilityCard: View {
    let name: String
    @Binding var score: Int
    let modifier: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                Button(action: {
                    if score > 1 {
                        score -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                
                Text("\(score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(minWidth: 40)
                
                Button(action: {
                    if score < 30 {
                        score += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                }
            }
            
            VStack(spacing: 2) {
                Text("\(modifier >= 0 ? "+" : "")\(modifier)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(modifier >= 0 ? .green : .red)
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct InteractiveStatField: View {
    let title: String
    @Binding var value: Int
    let minValue: Int
    let maxValue: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                Button(action: {
                    if value > minValue {
                        value -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                
                Text("\(value)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(minWidth: 60)
                
                Button(action: {
                    if value < maxValue {
                        value += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                }
            }
        }
    }
}



