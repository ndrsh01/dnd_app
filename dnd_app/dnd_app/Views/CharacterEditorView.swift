import SwiftUI

struct CharacterEditorView: View {
	let store: CharacterStore
	let character: Character?

	@Environment(\.dismiss) private var dismiss
	@State private var editedCharacter: Character
	@State private var showingImport = false
	@StateObject private var classesStore = ClassesStore()

	init(store: CharacterStore, character: Character? = nil) {
		self.store = store
		self.character = character
		self._editedCharacter = State(initialValue: character ?? Character())
	}

        var body: some View {
                NavigationStack {
                        Form {
                                Section { BasicInfoSection(character: $editedCharacter) }
                                Section { CharacterClassesSection(character: $editedCharacter, classesStore: classesStore) }
                                Section { ClassAbilitiesSection(character: $editedCharacter, onSaveChanges: { updatedCharacter in
                                                editedCharacter = updatedCharacter
                                        }) }
                                Section { CombatStatsSection(character: $editedCharacter) }
                                Section { AbilityScoresSection(character: $editedCharacter) }
                                Section { SkillsSection(character: $editedCharacter) }
                                Section { PersonalitySection(character: $editedCharacter) }
                                Section { EquipmentSection(character: $editedCharacter) }
                                Section { AttacksSection(character: $editedCharacter) }
                        }
                        .formStyle(.grouped)
                        .scrollContentBackground(.hidden)
                        .background(
                                LinearGradient(
                                        colors: [
                                                Color(red: 0.988, green: 0.933, blue: 0.855),
                                                Color(red: 0.988, green: 0.933, blue: 0.855).opacity(0.9),
                                                Color(red: 0.988, green: 0.933, blue: 0.855)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                )
                                .ignoresSafeArea()
                        )
                }
		.navigationTitle(character == nil ? "Новый персонаж" : "Редактирование")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				Button("Отмена") { dismiss() }
					.foregroundColor(.orange)
			}
			ToolbarItem(placement: .navigationBarTrailing) {
				HStack {
					if character == nil {
						Button(action: { showingImport = true }) {
							Image(systemName: "doc.badge.plus").foregroundColor(.orange)
						}
					}
					Button(action: { saveCharacter() }) {
						Image(systemName: "checkmark.circle.fill")
							.font(.title3)
							.foregroundColor(.orange)
					}
				}
			}
		}
		.sheet(isPresented: $showingImport) {
			CharacterImportView(store: store) { importedCharacter in
				editedCharacter = importedCharacter
				showingImport = false
			}
		}

	}

	@MainActor
	private func saveCharacter() {
		var characterToSave = editedCharacter
		characterToSave.dateModified = Date()
		
		// Update class data before saving
		for characterClass in characterToSave.characterClasses {
			if let gameClass = classesStore.classesBySlug[characterClass.slug] {
				characterToSave.classFeatures[characterClass.slug] = gameClass.featuresByLevel
			}
			
			if let classTable = classesStore.classTablesBySlug[characterClass.slug] {
				characterToSave.classProgression[characterClass.slug] = classTable
			}
		}
		
		if character == nil {
			characterToSave.dateCreated = Date()
			store.add(characterToSave)
		} else {
			store.update(characterToSave)
		}
		// Обновляем выбранного персонажа, чтобы лист мгновенно перерисовался
		store.selectedCharacter = characterToSave
		dismiss()
	}
}
