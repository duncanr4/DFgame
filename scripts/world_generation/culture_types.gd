class_name CultureTypes
extends RefCounted

const DEFAULT_CULTURE_COLORS: Dictionary[String, Color] = {
	"humans": Color("#A0C6E5"),
	"dwarves": Color("#C9A061"),
	"wood_elves": Color("#6EBF7A"),
	"high_elves": Color("#8FD8D2"),
	"halflings": Color("#EBC28A"),
	"lizardmen": Color("#6BBE88"),
	"demons": Color("#D46A6A"),
	"dragons": Color("#8A6BDA"),
	"beastmen": Color("#8D6E63"),
	"gnolls": Color("#A77B4E"),
	"orcish": Color("#719A54"),
	"marshfolk": Color("#6FA0A5"),
	"steppe_clans": Color("#C8B66E"),
	"badlander": Color("#B86F4B"),
	"wanderers": Color("#A5A5A5")
}

const SETTLEMENT_CLAIM_RADIUS_BY_TYPE: Dictionary[String, int] = {
	"town": 10,
	"dwarfhold": 12,
	"woodelfgrove": 13,
	"woodelfgroves": 13,
	"lizardmencity": 11,
	"capital": 16,
	"hamlet": 9,
	"castle": 11,
	"port": 11
}

const SETTLEMENT_RADIUS_MULTIPLIER_BY_TYPE: Dictionary[String, float] = {
	"town": 1.0,
	"dwarfhold": 1.2,
	"woodelfgrove": 1.25,
	"lizardmencity": 1.15,
	"capital": 1.35,
	"hamlet": 0.85,
	"castle": 1.1,
	"port": 1.05
}

const SETTLEMENT_FALLOFF_BY_TYPE: Dictionary[String, float] = {
	"town": 1.25,
	"dwarfhold": 1.55,
	"woodelfgrove": 1.1,
	"lizardmencity": 1.2,
	"capital": 1.35,
	"hamlet": 1.15,
	"castle": 1.45,
	"port": 1.2
}

const DEFAULT_SETTLEMENT_BREAKDOWN_BY_TYPE: Dictionary[String, Array] = {
	"town": [
		{"key": "humans", "label": "Humans", "color": DEFAULT_CULTURE_COLORS["humans"], "share": 0.72},
		{"key": "halflings", "label": "Halflings", "color": DEFAULT_CULTURE_COLORS["halflings"], "share": 0.16},
		{"key": "dwarves", "label": "Dwarves", "color": DEFAULT_CULTURE_COLORS["dwarves"], "share": 0.12}
	],
	"dwarfhold": [
		{"key": "dwarves", "label": "Dwarves", "color": DEFAULT_CULTURE_COLORS["dwarves"], "share": 0.82},
		{"key": "humans", "label": "Humans", "color": DEFAULT_CULTURE_COLORS["humans"], "share": 0.10},
		{"key": "halflings", "label": "Halflings", "color": DEFAULT_CULTURE_COLORS["halflings"], "share": 0.08}
	],
	"woodelfgrove": [
		{"key": "wood_elves", "label": "Wood Elves", "color": DEFAULT_CULTURE_COLORS["wood_elves"], "share": 0.86},
		{"key": "humans", "label": "Humans", "color": DEFAULT_CULTURE_COLORS["humans"], "share": 0.14}
	],
	"lizardmencity": [
		{"key": "lizardmen", "label": "Lizardmen", "color": DEFAULT_CULTURE_COLORS["lizardmen"], "share": 0.88},
		{"key": "humans", "label": "Humans", "color": DEFAULT_CULTURE_COLORS["humans"], "share": 0.12}
	]
}

const AMBIENT_STRUCTURE_OPTIONS_BY_CULTURE: Dictionary[String, Array] = {
	"humans": [
		{"id": "farm", "label": "Farm", "tile": Vector2i(15, 1), "requires_tree_neighbor": false},
		{"id": "homestead", "label": "Homestead", "tile": Vector2i(13, 1), "disallow_forest_overlay": false}
	],
	"wood_elves": [
		{"id": "moonwell", "label": "Moonwell", "tile": Vector2i(2, 5), "requires_tree_neighbor": true},
		{"id": "great_tree", "label": "Great Tree", "tile": Vector2i(14, 1), "requires_tree_overlay": true}
	],
	"dwarves": [
		{"id": "lumber_mill", "label": "Lumber Mill", "tile": Vector2i(0, 5), "requires_tree_neighbor": true}
	],
	"dragons": [
		{"id": "sleeping_dragon", "label": "Sleeping Dragon", "tile": Vector2i(14, 0), "requires_cave_neighbor": true}
	],
	"demons": [
		{"id": "hunting_lodge", "label": "Forbidden Lodge", "tile": Vector2i(16, 0)}
	]
}
