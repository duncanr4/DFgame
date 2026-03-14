extends RefCounted
class_name OverworldSettlementService

static func build_settlement_candidates(biome_map: Dictionary, tree_layer: TileMapLayer, tree_tile: Vector2i, jungle_tree_tile: Vector2i, settlement_biome_label: Callable) -> Array:
	var candidates: Array = []
	for coord: Vector2i in biome_map.keys():
		var biome := String(settlement_biome_label.call(String(biome_map.get(coord, "grassland"))))
		var tree_overlay := Vector2i(-1, -1)
		if tree_layer != null:
			tree_overlay = tree_layer.get_cell_atlas_coords(coord)
		candidates.append({
			"coord": coord,
			"biome": biome,
			"tree_overlay": tree_overlay,
			"has_forest_tree_overlay": tree_overlay == tree_tile,
			"has_jungle_tree_overlay": tree_overlay == jungle_tree_tile
		})
	return candidates

static func filter_settlement_candidates(candidates: Array, occupied: Array[Vector2i], min_distance: float) -> Array:
	var filtered: Array = []
	for candidate: Dictionary in candidates:
		var coord: Vector2i = Vector2i(-1, -1)
		if candidate.has("coord"):
			coord = candidate["coord"] as Vector2i
		if coord == Vector2i(-1, -1):
			continue
		if is_too_close(coord, occupied, min_distance):
			continue
		filtered.append(candidate)
	return filtered

static func is_too_close(coord: Vector2i, occupied: Array[Vector2i], min_distance: float) -> bool:
	for other: Vector2i in occupied:
		if coord.distance_to(other) < min_distance:
			return true
	return false
