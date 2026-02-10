class_name DwarfholdLogic
extends RefCounted

const MAP_PRESETS := {
	"mini": {"label": "Mini", "size": Vector2i(228, 128)},
	"small": {"label": "Small", "size": Vector2i(341, 192)},
	"normal": {"label": "Normal", "size": Vector2i(455, 256)},
	"large": {"label": "Large", "size": Vector2i(683, 384)},
	"extra-large": {"label": "Extra Large", "size": Vector2i(910, 512)}
}

const SETTLEMENT_TYPES := {
	"humans": "town",
	"dwarves": "dwarfhold",
	"wood_elves": "woodElfGrove",
	"lizardmen": "lizardmenCity"
}

static func get_map_preset(map_size_label: String) -> Dictionary:
	var normalized := map_size_label.strip_edges().to_lower().replace(" ", "-")
	if MAP_PRESETS.has(normalized):
		return MAP_PRESETS[normalized]
	return MAP_PRESETS["normal"]

static func to_frequency_ratio(percent: Variant, fallback: float = 0.5) -> float:
	var value_type := typeof(percent)
	if value_type != TYPE_INT && value_type != TYPE_FLOAT:
		return fallback
	return clampf(float(percent) / 100.0, 0.0, 1.0)

static func choose_tile_for_capital(
	faction_type: String,
	candidates: Array,
	rng: RandomNumberGenerator
) -> Vector2i:
	var weighted: Array[Dictionary] = []
	for candidate: Dictionary in candidates:
		var suitability := evaluate_tile_suitability(faction_type, candidate)
		if suitability <= 0.0:
			continue
		weighted.append({"coord": candidate["coord"], "weight": suitability})

	if weighted.is_empty():
		return Vector2i(-1, -1)

	var total_weight := 0.0
	for item: Dictionary in weighted:
		total_weight += float(item["weight"])

	var roll := rng.randf_range(0.0, total_weight)
	for item: Dictionary in weighted:
		roll -= float(item["weight"])
		if roll <= 0.0:
			return item["coord"]

	return weighted.back()["coord"]

static func evaluate_tile_suitability(faction_type: String, tile: Dictionary) -> float:
	if tile.is_empty():
		return 0.0

	var biome: String = str(tile.get("biome", ""))
	var is_mountain := biome == "mountain"
	var is_forest := biome == "forest"
	var is_marsh := biome == "marsh"
	var is_water := biome == "water"
	var has_forest_tree_overlay := bool(tile.get("has_forest_tree_overlay", false))
	var has_jungle_tree_overlay := bool(tile.get("has_jungle_tree_overlay", false))

	match faction_type:
		"dwarfhold":
			if is_mountain:
				return 1.0
			return 0.0
		"town":
			if biome in ["snow", "grass", "sand", "badlands"]:
				return 1.0
			return 0.0
		"woodElfGrove":
			if not has_forest_tree_overlay:
				return 0.0
			if is_forest:
				return 1.0
			if biome == "grass":
				return 0.35
			return 0.0
		"lizardmenCity":
			if not has_jungle_tree_overlay:
				return 0.0
			if is_water:
				return 0.0
			if is_marsh:
				return 1.0
			if is_forest:
				return 0.3
			return 0.15
		_:
			if is_water:
				return 0.0
			if is_mountain:
				return 0.2
			return 1.0
