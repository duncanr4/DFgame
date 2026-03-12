extends RefCounted

static func map_cell_count(map_size: Vector2i) -> int:
	return maxi(0, map_size.x * map_size.y)

static func coord_to_index(coord: Vector2i, map_size: Vector2i) -> int:
	return (coord.y * map_size.x) + coord.x

static func xy_to_index(x: int, y: int, map_size: Vector2i) -> int:
	return (y * map_size.x) + x

static func index_to_coord(index: int, map_size: Vector2i) -> Vector2i:
	if map_size.x <= 0:
		return Vector2i.ZERO
	return Vector2i(index % map_size.x, index / map_size.x)

static func dictionary_to_float_buffer(source_map: Dictionary, map_size: Vector2i, default_value: float = 0.0) -> PackedFloat32Array:
	var buffer := PackedFloat32Array()
	buffer.resize(map_cell_count(map_size))
	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord := Vector2i(x, y)
			var idx := xy_to_index(x, y, map_size)
			buffer[idx] = float(source_map.get(coord, default_value))
	return buffer
