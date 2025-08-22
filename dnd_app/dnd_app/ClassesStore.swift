import Foundation
import SwiftUI

// MARK: - New Models for Updated classes.json

struct ClassFeature: Codable, Equatable {
	let name: String
	let description: String
	
	private enum CodingKeys: String, CodingKey {
		case name
		case description
	}
	
	var text: String { description }
}

struct LevelProgression: Codable, Equatable {
	let level: Int
	let proficiency_bonus: String
	let features: [ClassFeature]
	
	// Dynamic properties based on class
	let rages: Int?
	let rage_damage: String?
	let weapon_mastery: Int?
	let spell_slots_1st: Int?
	let spell_slots_2nd: Int?
	let spell_slots_3rd: Int?
	let spell_slots_4th: Int?
	let spell_slots_5th: Int?
	let spell_slots_6th: Int?
	let spell_slots_7th: Int?
	let spell_slots_8th: Int?
	let spell_slots_9th: Int?
	
	private enum CodingKeys: String, CodingKey {
		case level, proficiency_bonus, features
		case rages, rage_damage, weapon_mastery
		case spell_slots_1st, spell_slots_2nd, spell_slots_3rd, spell_slots_4th, spell_slots_5th
		case spell_slots_6th, spell_slots_7th, spell_slots_8th, spell_slots_9th
	}
}

struct GameClass: Codable, Equatable {
	let name_ru: String
	let name_en: String
	let hit_dice: String
	let proficiencies: ClassProficiencies
	let equipment: ClassEquipment
	let level_progression: [LevelProgression]
	let subclasses: [GameSubclass]
	
	// Computed properties for backward compatibility
	var name: String { name_ru }
	var slug: String { name_en.lowercased() }
	
	var featuresByLevel: [String: [ClassFeature]] {
		var result: [String: [ClassFeature]] = [:]
		for progression in level_progression {
			result[String(progression.level)] = progression.features
		}
		return result
	}
	
	// Convert to ClassTable format
	func toClassTable() -> ClassTable {
		let columns = ["Уровень", "Бонус владения"]
		var rows: [[String: String]] = []
		
		for progression in level_progression {
			var row: [String: String] = [
				"Уровень": String(progression.level),
				"Бонус владения": progression.proficiency_bonus
			]
			
			// Add class-specific columns
			if let rages = progression.rages {
				row["Ярость"] = String(rages)
			}
			if let rageDamage = progression.rage_damage {
				row["Урон ярости"] = rageDamage
			}
			if let weaponMastery = progression.weapon_mastery {
				row["Оружейное мастерство"] = String(weaponMastery)
			}
			
			// Add spell slots
			for i in 1...9 {
				let key = "spell_slots_\(i)st"
				if let value = Mirror(reflecting: progression).children.first(where: { $0.label == key })?.value as? Int {
					row["\(i) уровень"] = String(value)
				}
			}
			
			rows.append(row)
		}
		
		return ClassTable(slug: slug, columns: Array(Set(rows.flatMap { $0.keys })).sorted(), rows: rows)
	}
}

struct ClassProficiencies: Codable, Equatable {
	let saving_throws: [String]
	let skills: String
	let weapons: [String]
	let armor: [String]
}

struct ClassEquipment: Codable, Equatable {
	let option_a: [String]
	let option_b: [String]
}

struct SubclassFeature: Codable, Equatable {
	let name: String
	let level: Int
	let description: String
	
	var text: String { description }
}

struct GameSubclass: Codable, Equatable {
	let name_ru: String
	let name_en: String
	let features: [SubclassFeature]
	
	// Computed properties for backward compatibility
	var name: String { name_ru }
	
	var featuresByLevel: [String: [ClassFeature]] {
		var result: [String: [ClassFeature]] = [:]
		for feature in features {
			let levelString = String(feature.level)
			if result[levelString] == nil {
				result[levelString] = []
			}
			// Convert SubclassFeature to ClassFeature
			let classFeature = ClassFeature(name: feature.name, description: feature.description)
			result[levelString]?.append(classFeature)
		}
		return result
	}
}

struct ClassTable: Codable, Equatable {
	let slug: String
	let columns: [String]
	let rows: [[String: String]]

	private enum CodingKeys: String, CodingKey {
		case slug
		case columns
		case rows
	}
}

final class ClassesStore: ObservableObject {
	@Published var classesBySlug: [String: GameClass] = [:]
	@Published var classTablesBySlug: [String: ClassTable] = [:]
	@Published var isLoading: Bool = true

	init() {
		print("🔍 [ClassesStore] Инициализация ClassesStore")
		loadClasses()
	}

	func loadClasses() {
		print("🔍 [ClassesStore] Начинаем загрузку классов...")
		print("🔍 [ClassesStore] Bundle path: \(Bundle.main.bundlePath)")
		print("🔍 [ClassesStore] Available resources: \(Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil)?.map { $0.lastPathComponent } ?? [])")
		
		guard let url = Bundle.main.url(forResource: "classes", withExtension: "json") else {
			print("❌ [ClassesStore] classes.json not found in bundle")
			return
		}
		
		print("✅ [ClassesStore] Найден файл classes.json: \(url)")
		
		guard let data = try? Data(contentsOf: url) else {
			print("❌ [ClassesStore] Failed to read classes.json data")
			return
		}
		
		print("✅ [ClassesStore] Прочитано \(data.count) байт данных")
		
		do {
			// New structure: { "classes": [GameClass] }
			struct ClassesResponse: Codable {
				let classes: [GameClass]
			}
			
			let decoded = try JSONDecoder().decode(ClassesResponse.self, from: data)
			print("✅ [ClassesStore] Декодировано \(decoded.classes.count) классов")
			
			var map: [String: GameClass] = [:]
			for gameClass in decoded.classes {
				map[gameClass.slug] = gameClass
				print("🔍 [ClassesStore] Класс: \(gameClass.name) (slug: \(gameClass.slug)) - \(gameClass.level_progression.count) уровней прогрессии")
			}
			
			DispatchQueue.main.async { 
				self.classesBySlug = map
				print("✅ [ClassesStore] Классы загружены в память: \(map.keys.sorted())")
				
				// Load tables after classes are loaded
				self.loadClassTables()
				self.isLoading = false
			}
		} catch {
			print("❌ [ClassesStore] Failed to decode classes.json: \(error)")
		}
	}

	func loadClassTables() {
		print("🔍 [ClassesStore] Начинаем загрузку таблиц классов из classes.json...")
		
		// Generate tables from classes data
		var map: [String: ClassTable] = [:]
		
		for (slug, gameClass) in classesBySlug {
			let table = gameClass.toClassTable()
			map[slug] = table
			print("🔍 [ClassesStore] Создана таблица для \(gameClass.name): \(table.rows.count) строк, \(table.columns.count) колонок")
		}
		
		DispatchQueue.main.async { 
			self.classTablesBySlug = map
			print("✅ [ClassesStore] Таблицы созданы из classes.json: \(map.keys.sorted())")
		}
	}

	func slug(for characterClass: String) -> String? {
		// Use the first part before '/' in multiclass cases
		let base = characterClass.components(separatedBy: "/").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? characterClass
		let mapping: [String: String] = [
			"Варвар": "barbarian",
			"Бард": "bard",
			"Жрец": "cleric",
			"Друид": "druid",
			"Воин": "fighter",
			"Монах": "monk",
			"Паладин": "paladin",
			"Следопыт": "ranger",
			"Плут": "rogue",
			"Чародей": "sorcerer",
			"Колдун": "warlock",
			"Волшебник": "wizard"
		]
		if let slug = mapping[base] { return slug }
		// Try english direct
		let lower = base.lowercased()
		let known = ["barbarian","bard","cleric","druid","fighter","monk","paladin","ranger","rogue","sorcerer","warlock","wizard"]
		if known.contains(lower) { return lower }
		return nil
	}

	func isSpellcaster(slug: String) -> Bool {
		["bard","cleric","druid","paladin","ranger","sorcerer","warlock","wizard"].contains(slug)
	}

	func classResources(for slug: String, level: Int) -> [(String, String)] {
		guard let table = classTablesBySlug[slug] else { return [] }
		guard let row = table.rows.first(where: { $0["Уровень"] == String(level) }) else { return [] }
		let ignored = Set(["Уровень","Бонус владения","Классовые умения"])
		return table.columns
			.filter { !ignored.contains($0) }
			.compactMap { key in
				if let val = row[key], !val.isEmpty { return (key, val) }
				return nil
			}
	}

	func features(for slug: String, upTo level: Int) -> [(Int, [ClassFeature])] {
		guard let gameClass = classesBySlug[slug] else { return [] }
		let pairs: [(Int,[ClassFeature])] = gameClass.featuresByLevel.compactMap { (k, v) in
			if let lvl = Int(k), lvl <= level { return (lvl, v) }
			return nil
		}.sorted { $0.0 < $1.0 }
		return pairs
	}

	func subclassFeatures(for slug: String, subclassName: String, upTo level: Int) -> [(Int, [ClassFeature])] {
		guard let gameClass = classesBySlug[slug] else { return [] }
		guard let subclass = gameClass.subclasses.first(where: { $0.name.lowercased().contains(subclassName.lowercased()) }) else { return [] }
		let pairs: [(Int,[ClassFeature])] = subclass.featuresByLevel.compactMap { (k, v) in
			if let lvl = Int(k), lvl <= level { return (lvl, v) }
			return nil
		}.sorted { $0.0 < $1.0 }
		return pairs
	}
}





