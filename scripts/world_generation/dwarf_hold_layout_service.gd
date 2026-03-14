extends RefCounted
class_name DwarfHoldLayoutService

static func pick_civic_building_type(rng: RandomNumberGenerator, civic_building_types: Dictionary) -> String:
	var total_weight := 0.0
	for type_name: String in civic_building_types.keys():
		var definition := civic_building_types[type_name] as Dictionary
		total_weight += float(definition.get("placement_weight", 1.0))
	if total_weight <= 0.0:
		return "workshop"

	var cursor := rng.randf() * total_weight
	for type_name: String in civic_building_types.keys():
		var definition := civic_building_types[type_name] as Dictionary
		cursor -= float(definition.get("placement_weight", 1.0))
		if cursor <= 0.0:
			return type_name
	return String(civic_building_types.keys()[0])

static func roll_civic_footprint(rng: RandomNumberGenerator, civic_definition: Dictionary) -> Vector2i:
	var minimum := civic_definition.get("preferred_footprint_min", Vector2i(2, 2)) as Vector2i
	var maximum := civic_definition.get("preferred_footprint_max", Vector2i(4, 3)) as Vector2i
	return Vector2i(
		rng.randi_range(mini(minimum.x, maximum.x), maxi(minimum.x, maximum.x)),
		rng.randi_range(mini(minimum.y, maximum.y), maxi(minimum.y, maximum.y))
	)

static func civic_prefers_hall_arteries(civic_definition: Dictionary) -> bool:
	var adjacency := civic_definition.get("adjacency_preferences", {}) as Dictionary
	return bool(adjacency.get("prefers_hall_arteries", false))

static func collect_walkable_cells(grid: Dictionary, walkable_zone_ids: Array[int]) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for key: Variant in grid.keys():
		var cell := key as Vector2i
		var zone := int(grid[key])
		if walkable_zone_ids.has(zone):
			cells.append(cell)
	return cells
