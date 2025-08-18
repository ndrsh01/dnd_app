import SwiftUI

struct CharacterEditorView: View {
	let store: CharacterStore
	let character: Character?

	@Environment(\.dismiss) private var dismiss
	@State private var editedCharacter: Character
	@State private var showingImport = false

	init(store: CharacterStore, character: Character? = nil) {
		self.store = store
		self.character = character
		self._editedCharacter = State(initialValue: character ?? Character())
	}

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 20) {
					BasicInfoSection(character: $editedCharacter)
					CharacterClassesSection(character: $editedCharacter)
					ClassAbilitiesSection(character: $editedCharacter)
					CombatStatsSection(character: $editedCharacter)
					AbilityScoresSection(character: $editedCharacter)
					SkillsSection(character: $editedCharacter)
					PersonalitySection(character: $editedCharacter)
					EquipmentSection(character: $editedCharacter)
					AttacksSection(character: $editedCharacter)
				}
				.padding()
			}
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
					Button("Сохранить") { saveCharacter() }
						.fontWeight(.semibold)
						.foregroundColor(.orange)
				}
			}
		}
		.sheet(isPresented: $showingImport) {
			CharacterImportView(store: store) { importedCharacter in
				editedCharacter = importedCharacter
				showingImport = false
			}
		}
		.onChange(of: editedCharacter) { newValue in
			// Auto-save changes when editing existing character
			if character != nil {
				autoSaveCharacter()
			}
		}
	}

	@MainActor
	private func saveCharacter() {
		var characterToSave = editedCharacter
		characterToSave.dateModified = Date()
		if character == nil {
			characterToSave.dateCreated = Date()
			store.add(characterToSave)
		} else {
			store.update(characterToSave)
		}
		dismiss()
	}
	
	@MainActor
	private func autoSaveCharacter() {
		var characterToSave = editedCharacter
		characterToSave.dateModified = Date()
		store.update(characterToSave)
	}
}
