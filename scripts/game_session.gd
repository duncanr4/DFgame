extends Node

var world_settings: Dictionary = {}

const DEFAULT_WORLD_SETTINGS := {
	"map_size": "Normal",
	"map_size_key": "normal",
	"map_dimensions": Vector2i(455, 256),
	"world_layout": "Normal",
	"world_seed": "",
	"world_name": "",
	"chronology": {
		"year": 250,
		"age": "Age of Discovery"
	},
	"terrain": {
		"forest": 50,
		"mountain": 50,
		"river": 50
	},
	"terrain_ratios": {
		"forest": 0.5,
		"mountain": 0.5,
		"river": 0.5
	},
	"settlements": {
		"humans": 50,
		"dwarves": 50,
		"wood_elves": 50,
		"lizardmen": 25
	},
	"settlement_ratios": {
		"humans": 0.5,
		"dwarves": 0.5,
		"wood_elves": 0.5,
		"lizardmen": 0.25
	}
}

func set_world_settings(settings: Dictionary) -> void:
	world_settings = get_world_settings_with_defaults(settings)

func get_world_settings() -> Dictionary:
	return get_world_settings_with_defaults(world_settings)

func get_world_settings_with_defaults(settings: Dictionary) -> Dictionary:
	var merged := DEFAULT_WORLD_SETTINGS.duplicate(true)
	for key: Variant in settings.keys():
		if merged.has(key) and merged[key] is Dictionary and settings[key] is Dictionary:
			var merged_subdict: Dictionary = merged[key]
			merged_subdict.merge(settings[key], true)
			merged[key] = merged_subdict
		else:
			merged[key] = settings[key]
	return merged
