extends RefCounted

static func get_tile_coord_from_global_position(tile_map: TileMap, world_pos: Vector2) -> Vector2i:
	if tile_map == null:
		return Vector2i(-1, -1)
	var local_pos := tile_map.to_local(world_pos)
	return tile_map.local_to_map(local_pos)

static func is_valid_map_coord(coord: Vector2i, map_size: Vector2i) -> bool:
	return coord.x >= 0 and coord.y >= 0 and coord.x < map_size.x and coord.y < map_size.y

static func map_cell_center(coord: Vector2i, tile_size: int) -> Vector2:
	return (Vector2(coord) + Vector2(0.5, 0.5)) * float(tile_size)
