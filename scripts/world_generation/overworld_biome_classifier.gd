class_name OverworldBiomeClassifier
extends RefCounted

func classify(host: Node, terrain_maps: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var map_size: Vector2i = host.map_size
	var height_map: Dictionary = terrain_maps["height_map"]
	var temperature_map: Dictionary = terrain_maps["temperature_map"]
	var moisture_map: Dictionary = terrain_maps["moisture_map"]
	var vegetation_map: Dictionary = terrain_maps["vegetation_map"]

	var base_biome_map: Dictionary = {}
	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord := Vector2i(x, y)
			base_biome_map[coord] = host._assign_base_biome(
				coord,
				height_map[coord],
				temperature_map[coord],
				moisture_map[coord],
				height_map
			)

	host._smooth_biomes(base_biome_map, 2)
	if host._count_biome(base_biome_map, host.BIOME_DESERT) == 0:
		host._seed_desert_biomes(base_biome_map, temperature_map, moisture_map, height_map)
		host._smooth_biomes(base_biome_map, 1)

	var tree_biome_map: Dictionary = base_biome_map.duplicate()
	var tree_map := host._apply_tree_overlays(
		tree_biome_map,
		temperature_map,
		moisture_map,
		vegetation_map,
		height_map,
		rng
	)
	var highland_map: Dictionary = host._build_highland_overlays(base_biome_map, height_map)
	var biome_map: Dictionary = tree_biome_map.duplicate()
	for coord: Vector2i in highland_map.keys():
		biome_map[coord] = highland_map[coord]

	return {
		"base_biome_map": base_biome_map,
		"tree_map": tree_map,
		"highland_map": highland_map,
		"biome_map": biome_map
	}

func apply_base_tiles(host: Node, base_biome_map: Dictionary) -> void:
	for y in range(host.map_size.y):
		for x in range(host.map_size.x):
			var coord := Vector2i(x, y)
			var base_biome := base_biome_map.get(coord, host.BIOME_GRASSLAND) as String
			var tile_coords := host._biome_to_tile(base_biome)
			host.map_layer.set_cell(coord, host._atlas_source_id, tile_coords)
