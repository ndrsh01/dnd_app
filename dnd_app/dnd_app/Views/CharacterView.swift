import SwiftUI

struct CharacterView: View {
    @StateObject private var characterStore = CharacterStore()
    @StateObject private var compendiumStore = CompendiumStore()
    @StateObject private var classesStore = ClassesStore()
    
    var body: some View {
        NavigationView {
            Group {
                if let selectedCharacter = characterStore.selectedCharacter {
                    CompactCharacterSheetView(
                        character: selectedCharacter,
                        store: characterStore,
                        compendiumStore: compendiumStore,
                        classesStore: classesStore,
                        isEditingMode: .constant(false),
                        onSaveChanges: { updatedCharacter in
                            characterStore.update(updatedCharacter)
                        }
                    )
                } else {
                    // Экран выбора персонажа
                    CharacterSelectionView(
                        characterStore: characterStore,
                        isPresented: .constant(true)
                    )
                }
            }
            .navigationTitle("Персонаж")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if characterStore.selectedCharacter != nil {
                        Button("Назад") {
                            characterStore.selectedCharacter = nil
                        }
                    }
                }
            }
        }
        .onAppear {
            // Загружаем данные при запуске
            print("🔍 [CharacterView] onAppear - начинаем загрузку данных классов")
            
            // Загружаем данные с небольшой задержкой между загрузками
            classesStore.loadClasses()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                classesStore.loadClassTables()
            }
            
            // Проверяем состояние через небольшую задержку
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("🔍 [CharacterView] Проверка состояния ClassesStore:")
                print("  - classesBySlug: \(classesStore.classesBySlug.keys.sorted())")
                print("  - classTablesBySlug: \(classesStore.classTablesBySlug.keys.sorted())")
                print("  - isLoading: \(classesStore.isLoading)")
                
                // Если данные не загрузились, попробуем еще раз
                if classesStore.classesBySlug.isEmpty || classesStore.classTablesBySlug.isEmpty {
                    print("⚠️ Данные не загрузились, пробуем еще раз...")
                    classesStore.loadClasses()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        classesStore.loadClassTables()
                    }
                }
            }
        }
    }
}

struct CharacterView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterView()
    }
}
