import SwiftUI

struct HeartRatingView: View {
    let rating: Int
    let maxRating: Int
    let size: CGFloat
    let color: Color
    
    init(rating: Int, maxRating: Int = 5, size: CGFloat = 20, color: Color = .red) {
        self.rating = rating
        self.maxRating = maxRating
        self.size = size
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "heart.fill" : "heart")
                    .foregroundColor(index <= rating ? color : .gray)
                    .font(.system(size: size))
                    .scaleEffect(index <= rating ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 0.2), value: rating)
            }
        }
    }
}

struct HeartRatingPicker: View {
    @Binding var rating: Int
    let maxRating: Int
    let size: CGFloat
    let color: Color
    
    init(rating: Binding<Int>, maxRating: Int = 5, size: CGFloat = 25, color: Color = .red) {
        self._rating = rating
        self.maxRating = maxRating
        self.size = size
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        rating = index
                    }
                }) {
                    Image(systemName: index <= rating ? "heart.fill" : "heart")
                        .foregroundColor(index <= rating ? color : .gray)
                        .font(.system(size: size))
                        .scaleEffect(index <= rating ? 1.0 : 0.8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct RelationshipStrengthView: View {
    let relationship: Relationship
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(relationship.characterName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HeartRatingView(
                    rating: relationship.strength,
                    color: relationship.relationshipType.color
                )
            }
            
            HStack {
                Text(relationship.relationshipType.rawValue)
                    .font(.caption)
                    .foregroundColor(relationship.relationshipType.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(relationship.relationshipType.color.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
            }
            
            if !relationship.description.isEmpty {
                Text(relationship.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    VStack(spacing: 20) {
        HeartRatingView(rating: 3, color: .red)
        HeartRatingView(rating: 5, color: .pink)
        HeartRatingView(rating: 2, color: .blue)
        
        @State var rating = 3
        HeartRatingPicker(rating: $rating, color: .red)
        
        RelationshipStrengthView(
            relationship: Relationship(
                characterName: "Гэндальф",
                relationshipType: .mentor,
                strength: 4,
                description: "Мудрый наставник, который всегда готов помочь советом"
            )
        )
    }
    .padding()
}
