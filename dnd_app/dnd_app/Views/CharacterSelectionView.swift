import SwiftUI

struct CharacterSelectionView: View {
    @ObservedObject var characterStore: CharacterStore
    @Binding var isPresented: Bool
    @State private var showCharacterCreation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Заголовок
                VStack(spacing: 8) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Выберите персонажа")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("или создайте нового")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Список персонажей
                if characterStore.characters.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("У вас пока нет персонажей")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Создайте первого персонажа, чтобы начать")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(characterStore.characters) { character in
                                CharacterCardView(
                                    character: character,
                                    isSelected: characterStore.selectedCharacter?.id == character.id
                                ) {
                                    characterStore.selectedCharacter = character
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Кнопки действий
                VStack(spacing: 12) {
                    if let selected = characterStore.selectedCharacter {
                        Button(action: {
                            isPresented = false
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Играть за \(selected.name)")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        showCharacterCreation = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Создать нового персонажа")
                        }
                        .font(.headline)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
                    .background(
            LinearGradient(
                colors: [
                    Color("BackgroundColor"),
                    Color("BackgroundColor").opacity(0.8),
                    Color("BackgroundColor")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .navigationBarHidden(true)
        .sheet(isPresented: $showCharacterCreation) {
            CharacterCreationView(characterStore: characterStore)
        }
        }
    }
}

struct CharacterCardView: View {
    let character: Character
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Аватар персонажа
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.orange)
                }
                
                // Информация о персонаже
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("\(character.race) • \(character.characterClass)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text("Уровень \(character.level)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Статистика
                VStack(alignment: .trailing, spacing: 4) {
                    Text("HP: \(character.currentHitPoints)/\(character.maxHitPoints)")
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Text("КЗ: \(character.armorClass)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Индикатор выбора
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}



