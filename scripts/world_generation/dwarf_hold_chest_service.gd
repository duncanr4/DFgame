extends RefCounted
class_name DwarfHoldChestService

static func ensure_chest_inventory(chest_inventories: Dictionary, cell: Vector2i, rng: RandomNumberGenerator, chest_loot_table: Array) -> void:
	if chest_inventories.has(cell):
		return
	var loot_entries: Array[Dictionary] = []
	var loot_count := rng.randi_range(2, 4)
	for _roll in loot_count:
		var loot_def := chest_loot_table[rng.randi_range(0, chest_loot_table.size() - 1)] as Dictionary
		loot_entries.append({
			"name": String(loot_def.get("name", "Supplies")),
			"quantity": rng.randi_range(int(loot_def.get("min", 1)), int(loot_def.get("max", 1)))
		})
	chest_inventories[cell] = loot_entries

static func item_abbreviation(item_name: String) -> String:
	var words := item_name.split(" ", false)
	if words.is_empty():
		return "?"
	if words.size() == 1:
		return String(words[0]).substr(0, mini(3, String(words[0]).length())).to_upper()
	var abbreviation := ""
	for i in range(mini(words.size(), 2)):
		var word := String(words[i])
		if not word.is_empty():
			abbreviation += word.substr(0, 1).to_upper()
	return abbreviation
