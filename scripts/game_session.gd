extends Node

const WORLD_LAYOUTS: Array[String] = ["Normal", "Major Continent", "Twin Continents", "Inland Sea", "Archipelago"]
const WORLD_AGES: Array[String] = ["Age of Myth", "Age of Heroes", "Age of Discovery", "Age of Discord", "Age of Ember"]
const DEFAULT_TERRAIN_SLIDERS := {"forest": 50, "mountain": 50, "river": 50}
const DEFAULT_SETTLEMENT_SLIDERS := {"humans": 50, "dwarves": 50, "wood_elves": 50, "lizardmen": 50}

var world_settings: Dictionary = {}

func set_world_settings(settings: Dictionary) -> void:
	world_settings = normalize_world_settings(settings)

func get_world_settings() -> Dictionary:
	return world_settings.duplicate(true)

func normalize_world_settings(settings: Dictionary) -> Dictionary:
	var normalized := _default_world_settings()
	var source := settings.duplicate(true)

	var map_size_key := str(source.get("map_size_key", "normal")).strip_edges().to_lower().replace(" ", "-")
	if source.has("map_size") and source.get("map_size_key", "").to_string().strip_edges().is_empty():
		map_size_key = str(source["map_size"]).strip_edges().to_lower().replace(" ", "-")
	var map_preset := DwarfholdLogic.get_map_preset(map_size_key)
	normalized["map_size_key"] = map_size_key
	normalized["map_size"] = map_preset["label"]
	normalized["map_dimensions"] = source.get("map_dimensions", map_preset["size"])

	normalized["world_layout"] = _valid_layout_or_default(str(source.get("world_layout", normalized["world_layout"])))
	normalized["world_seed"] = str(source.get("world_seed", normalized["world_seed"])).strip_edges()
	normalized["world_name"] = str(source.get("world_name", normalized["world_name"])).strip_edges()

	var chronology: Dictionary = source.get("chronology", {}) as Dictionary
	normalized["chronology"] = {
		"year": int(chronology.get("year", normalized["chronology"]["year"])),
		"age": _valid_age_or_default(str(chronology.get("age", normalized["chronology"]["age"])))
	}

	normalized["terrain"] = _normalize_slider_values(source.get("terrain", {}), DEFAULT_TERRAIN_SLIDERS)
	normalized["settlements"] = _normalize_slider_values(source.get("settlements", {}), DEFAULT_SETTLEMENT_SLIDERS)
	normalized["terrain_ratios"] = _build_slider_ratios(normalized["terrain"])
	normalized["settlement_ratios"] = _build_slider_ratios(normalized["settlements"])
	return normalized

func _default_world_settings() -> Dictionary:
	var map_preset := DwarfholdLogic.get_map_preset("normal")
	return {
		"map_size": map_preset["label"],
		"map_size_key": "normal",
		"map_dimensions": map_preset["size"],
		"world_layout": WORLD_LAYOUTS[0],
		"world_seed": "",
		"world_name": "",
		"chronology": {
			"year": 250,
			"age": WORLD_AGES[2]
		},
		"terrain": DEFAULT_TERRAIN_SLIDERS.duplicate(true),
		"terrain_ratios": _build_slider_ratios(DEFAULT_TERRAIN_SLIDERS),
		"settlements": DEFAULT_SETTLEMENT_SLIDERS.duplicate(true),
		"settlement_ratios": _build_slider_ratios(DEFAULT_SETTLEMENT_SLIDERS)
	}

func _normalize_slider_values(values: Variant, defaults: Dictionary) -> Dictionary:
	var source := values as Dictionary
	if source == null:
		source = {}
	var normalized := defaults.duplicate(true)
	for slider_key: String in defaults.keys():
		normalized[slider_key] = int(clampi(int(source.get(slider_key, defaults[slider_key])), 0, 100))
	return normalized

func _build_slider_ratios(values: Dictionary) -> Dictionary:
	var ratios := {}
	for slider_key: String in values.keys():
		ratios[slider_key] = DwarfholdLogic.to_frequency_ratio(values[slider_key])
	return ratios

func _valid_layout_or_default(layout: String) -> String:
	if WORLD_LAYOUTS.has(layout):
		return layout
	return WORLD_LAYOUTS[0]

func _valid_age_or_default(age: String) -> String:
	if WORLD_AGES.has(age):
		return age
	return WORLD_AGES[2]
