import SwiftUI

struct SpellSearchSection: View {
    @ObservedObject var store: CompendiumStore
    let favorites: FavoriteSpellsManager
    let themeManager: ThemeManager
    let currentTab: Int
    @State private var showingFilters = false

    private func getActiveFiltersCount() -> Int {
        return store.spellFilters.selectedLevels.count +
               store.spellFilters.selectedSchools.count +
               store.spellFilters.selectedClasses.count +
               (store.spellFilters.concentrationOnly ? 1 : 0) +
               (store.spellFilters.ritualOnly ? 1 : 0)
    }

    var body: some View {
        Group {
            VStack(spacing: 12) {
                Button(action: { showingFilters = true }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        Text("Поиск заклинаний...")
                            .foregroundColor(.secondary)
                        Spacer()
                        if getActiveFiltersCount() > 0 {
                            Text("\(getActiveFiltersCount())")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .orange.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .stroke(
                                LinearGradient(
                                    colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .sheet(isPresented: $showingFilters) {
                SpellSearchView(store: store, favorites: favorites, themeManager: themeManager)
            }
        }
    }
}

