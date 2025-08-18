import SwiftUI

struct SpellRow: View {
    let spell: Spell
    @ObservedObject var favorites: FavoriteSpellsManager
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(spell.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()

                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            favorites.toggleSpell(spell.name)
                        }
                    }) {
                        Image(systemName: favorites.isSpellFavorite(spell.name) ? "heart.fill" : "heart")
                            .foregroundColor(favorites.isSpellFavorite(spell.name) ? .red : .gray)
                            .font(.title2)
                            .scaleEffect(favorites.isSpellFavorite(spell.name) ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: favorites.isSpellFavorite(spell.name))
                    }

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.orange)
                            .font(.title3)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            HStack(spacing: 8) {
                Text(spell.level == 0 ? "Заговор" : "\(spell.level) уровень")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.15))
                    .foregroundColor(.blue)
                    .cornerRadius(12)

                Text(getSchoolName(spell.school))
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.15))
                    .foregroundColor(.purple)
                    .cornerRadius(12)

                if spell.concentration {
                    Text("Концентрация")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.15))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }

                if spell.ritual {
                    Text("Ритуал")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            if !spell.classes.isEmpty {
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(spell.classes.map { getClassName($0) }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.primary)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }

            if isExpanded {
                SpellDetailView(spell: spell)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 20)
    }

    private func getSchoolName(_ school: String) -> String {
        let schoolNames = [
            "evocation": "Воплощение",
            "conjuration": "Вызов",
            "illusion": "Иллюзия",
            "necromancy": "Некромантия",
            "abjuration": "Ограждение",
            "enchantment": "Очарование",
            "transmutation": "Преобразование",
            "divination": "Прорицание"
        ]
        return schoolNames[school] ?? school
    }

    private func getClassName(_ className: String) -> String {
        let classNames = [
            "bard": "Бард",
            "sorcerer": "Волшебник",
            "druid": "Друид",
            "cleric": "Жрец",
            "warlock": "Колдун",
            "paladin": "Паладин",
            "ranger": "Следопыт",
            "wizard": "Чародей"
        ]
        return classNames[className] ?? className
    }
}

