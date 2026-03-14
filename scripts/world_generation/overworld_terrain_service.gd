extends RefCounted
class_name OverworldTerrainService

static func build_ocean_distance_map(
	base_biome_map: Dictionary,
	map_size: Vector2i,
	water_biome: String,
	neighbor_definitions: Array,
	is_valid_coord: Callable
) -> Dictionary:
	var ocean_distance: Dictionary = {}
	var queue: Array[Vector2i] = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord := Vector2i(x, y)
			if String(base_biome_map.get(coord, "")) != water_biome:
				continue
			if x == 0 or y == 0 or x == map_size.x - 1 or y == map_size.y - 1:
				ocean_distance[coord] = 0.0
				queue.append(coord)
	if queue.is_empty():
		for y in range(map_size.y):
			for x in range(map_size.x):
				var coord := Vector2i(x, y)
				if String(base_biome_map.get(coord, "")) == water_biome:
					ocean_distance[coord] = 0.0
					queue.append(coord)
	var head := 0
	while head < queue.size():
		var current := queue[head]
		head += 1
		var base_distance := float(ocean_distance.get(current, 0.0))
		for def_variant: Variant in neighbor_definitions:
			var def := def_variant as Dictionary
			var neighbor := current + (def.get("offset", Vector2i.ZERO) as Vector2i)
			if not bool(is_valid_coord.call(neighbor)):
				continue
			var candidate_distance := base_distance + 1.0
			if candidate_distance < float(ocean_distance.get(neighbor, INF)):
				ocean_distance[neighbor] = candidate_distance
				queue.append(neighbor)
	return ocean_distance

static func compute_edge_connected_water_mask(
	base_biome_map: Dictionary,
	map_size: Vector2i,
	water_biome: String,
	neighbor_definitions: Array,
	is_valid_coord: Callable
) -> Dictionary:
	var mask: Dictionary = {}
	var queue: Array[Vector2i] = []
	for x in range(map_size.x):
		for y: int in [0, map_size.y - 1]:
			var coord := Vector2i(x, y)
			if String(base_biome_map.get(coord, "")) != water_biome or mask.has(coord):
				continue
			mask[coord] = true
			queue.append(coord)
	for y in range(1, map_size.y - 1):
		for x: int in [0, map_size.x - 1]:
			var coord := Vector2i(x, y)
			if String(base_biome_map.get(coord, "")) != water_biome or mask.has(coord):
				continue
			mask[coord] = true
			queue.append(coord)
	var head := 0
	while head < queue.size():
		var current := queue[head]
		head += 1
		for def_variant: Variant in neighbor_definitions:
			var def := def_variant as Dictionary
			var neighbor := current + (def.get("offset", Vector2i.ZERO) as Vector2i)
			if not bool(is_valid_coord.call(neighbor)):
				continue
			if String(base_biome_map.get(neighbor, "")) != water_biome or mask.has(neighbor):
				continue
			mask[neighbor] = true
			queue.append(neighbor)
	return mask
