import SwiftUI

struct ModernClassFeaturesView: View {
    let character: Character
    let classSlug: String
    @ObservedObject var store: CharacterStore
    @State private var searchText = ""
    @State private var showingResetAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок секции
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                Text("Классовые умения")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showingResetAlert = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                        Text("Сброс")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            
            // Поиск по умениям
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                TextField("Поиск по умениям...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.caption)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
            
            // Классовые умения
            if let featuresForClass = character.classFeatures[classSlug] {
                let filteredFeatures = filterFeatures(featuresForClass)
                
                if filteredFeatures.isEmpty && !searchText.isEmpty {
                    Text("Умения не найдены")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .italic()
                        .padding()
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(filteredFeatures.keys.sorted()), id: \.self) { level in
                            if let features = filteredFeatures[level] {
                                VStack(alignment: .leading, spacing: 8) {
                                    // Уровень
                                    HStack {
                                        Text("Уровень \(level)")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.blue.opacity(0.1))
                                            )
                                        
                                        Spacer()
                                    }
                                    
                                    // Умения для этого уровня
                                    VStack(spacing: 8) {
                                        ForEach(features, id: \.name) { feature in
                                            ClassFeatureCard(feature: feature)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                Text("Классовые умения не загружены")
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
                        colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .alert("Сбросить классовые умения?", isPresented: $showingResetAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Сбросить", role: .destructive) {
                resetClassFeatures()
            }
        } message: {
            Text("Это действие удалит все загруженные классовые умения и особенности. Их можно будет загрузить заново.")
        }
    }
    
    private func resetClassFeatures() {
        if let selectedCharacter = store.selectedCharacter {
            var updatedCharacter = selectedCharacter
            updatedCharacter.classFeatures.removeValue(forKey: classSlug)
            updatedCharacter.classProgression.removeValue(forKey: classSlug)
            updatedCharacter.featuresAndTraits = ""
            store.update(updatedCharacter)
            store.selectedCharacter = updatedCharacter
        }
    }
    
    private func filterFeatures(_ featuresForClass: [String: [ClassFeature]]) -> [String: [ClassFeature]] {
        guard !searchText.isEmpty else {
            return featuresForClass
        }
        
        var filtered: [String: [ClassFeature]] = [:]
        
        for (level, features) in featuresForClass {
            let filteredFeatures = features.filter { feature in
                feature.name.localizedCaseInsensitiveContains(searchText) ||
                feature.text.localizedCaseInsensitiveContains(searchText)
            }
            
            if !filteredFeatures.isEmpty {
                filtered[level] = filteredFeatures
            }
        }
        
        return filtered
    }
}

struct ClassFeatureCard: View {
    let feature: ClassFeature
    @State private var isExpanded = false
    @State private var isVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Заголовок умения
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(feature.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                        .font(.caption)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Описание умения
            if isExpanded {
                Text(feature.text)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6).opacity(0.5))
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                isVisible = true
            }
        }
    }
}


