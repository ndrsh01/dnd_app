import Foundation
import SwiftUI

struct ClassFeature: Codable, Equatable {
	let name: String
	let text: String
}

struct GameSubclass: Codable, Equatable {
	let name: String
	let featuresByLevel: [String: [ClassFeature]]

	private enum CodingKeys: String, CodingKey {
		case name
		case featuresByLevel = "features_by_level"
	}
}

struct GameClass: Codable, Equatable {
	let name: String
	let slug: String
	let featuresByLevel: [String: [ClassFeature]]
	let subclasses: [GameSubclass]

	private enum CodingKeys: String, CodingKey {
		case name = "class"
		case slug
		case featuresByLevel = "features_by_level"
		case subclasses
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

	init() {
		loadClasses()
		loadClassTables()
	}

	func loadClasses() {
		guard let url = Bundle.main.url(forResource: "classes", withExtension: "json") else {
			print("❌ [ClassesStore] classes.json not found in bundle")
			return
		}
		
		guard let data = try? Data(contentsOf: url) else {
			print("❌ [ClassesStore] Failed to read classes.json data")
			return
		}
		
		do {
			let decoded = try JSONDecoder().decode([GameClass].self, from: data)
			var map: [String: GameClass] = [:]
			for gameClass in decoded {
				map[gameClass.slug] = gameClass
			}
			
			DispatchQueue.main.async { 
				self.classesBySlug = map
			}
		} catch {
			print("❌ [ClassesStore] Failed to decode classes.json: \(error)")
		}
	}

	func loadClassTables() {
		guard let url = Bundle.main.url(forResource: "class_tables", withExtension: "json") else {
			print("❌ [ClassesStore] class_tables.json not found in bundle")
			return
		}
		
		guard let data = try? Data(contentsOf: url) else {
			print("❌ [ClassesStore] Failed to read class_tables.json data")
			return
		}
		
		do {
			let decoded = try JSONDecoder().decode([ClassTable].self, from: data)
			var map: [String: ClassTable] = [:]
			for table in decoded {
				map[table.slug] = table
			}
			
			DispatchQueue.main.async { 
				self.classTablesBySlug = map
				print("✅ [ClassesStore] Class tables loaded successfully. Total: \(self.classTablesBySlug.count)")
			}
		} catch {
			print("❌ [ClassesStore] Failed to decode class_tables.json: \(error)")
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





