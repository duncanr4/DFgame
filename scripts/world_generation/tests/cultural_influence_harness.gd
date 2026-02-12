extends SceneTree

const CulturalInfluenceScript := preload("res://scripts/world_generation/cultural_influence.gd")

func _initialize() -> void:
	var width := 12
	var height := 8
	var tiles: Dictionary = {}
	for y in range(height):
		for x in range(width):
			tiles[Vector2i(x, y)] = {
				"base": "land",
				"base_biome": "grassland" if y < 6 else "marsh",
				"biome_type": "grassland" if y < 6 else "marsh",
				"overlay": "",
				"hill_overlay": "",
				"river": false,
				"structure": ""
			}

	tiles[Vector2i(9, 2)]["structure"] = "cave"
	tiles[Vector2i(4, 5)]["structure"] = "dungeon"

	var pipeline := CulturalInfluenceScript.new() as CulturalInfluence
	var settlements: Array[Dictionary] = [
		{
			"x": 2,
			"y": 2,
			"type": "town",
			"population_breakdown": [
				{"key": "humans", "label": "Humans", "color": Color("#9ec3de"), "percentage": 70.0},
				{"key": "dwarves", "label": "Dwarves", "color": Color("#cda167"), "percentage": 30.0}
			]
		},
		{
			"x": 8,
			"y": 3,
			"type": "dwarfhold"
		}
	]
	var factions: Array[Dictionary] = [
		{"key": "wood_elves", "label": "Wood Elves", "capital": {"x": 6, "y": 6}, "claim_radius": 8}
	]

	pipeline.apply_cultural_influence(
		width,
		height,
		tiles,
		settlements,
		factions,
		func(_coord: Vector2i, tile_data: Dictionary) -> bool:
			return String(tile_data.get("base", "land")) != "water",
		12345,
		{"center": {"x": 6, "y": 6}, "radius": 7}
	)

	var samples: Array[Vector2i] = [Vector2i(2, 2), Vector2i(6, 3), Vector2i(9, 2), Vector2i(6, 6)]
	for sample: Vector2i in samples:
		var tile := tiles.get(sample, {}) as Dictionary
		var influence: Variant = tile.get("cultural_influence", null)
		print("tile=", sample, " influence=", influence)

	quit()
