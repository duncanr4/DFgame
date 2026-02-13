extends Control

const CELL_ROCK := 0
const CELL_HALL := 1
const CELL_TUNNEL := 2
const CELL_DISTRICT := 3
const CELL_KEEP := 4
const CELL_GATE := 5
const CELL_ROOM := 6
const CELL_HOUSE := 7
const CELL_BUILDING := 8

@export var map_size := Vector2i(96, 64)
@export var district_count := 14
@export var hall_count := 18
@export var room_count := 120
@export var housing_count := 180
@export var civic_building_count := 70
@export var tile_size := Vector2i(16, 16)
@export var tilesheet_path := "res://Github Game/tilesheet/Interior_Tileset.png"

# Atlas coordinates are 1-based (row, col) to match design docs.
const NAMED_TILE_LIBRARY := {
	"stone": Vector2i(3, 3),
	"stone_alt": Vector2i(4, 6),
	"stone_dark": Vector2i(4, 7),
	"wall": Vector2i(3, 5),
	"wall_left_corner": Vector2i(3, 7),
	"wall_right_corner": Vector2i(1, 9),
	"wall_inner_left": Vector2i(1, 5),
	"wall_inner_right": Vector2i(1, 7),
	"floor_carved": Vector2i(7, 11),
	"floor_carved_alt": Vector2i(6, 10),
	"floor_carved_worn": Vector2i(6, 11),
	"floor_polished": Vector2i(10, 10),
	"floor_polished_alt": Vector2i(10, 11),
	"floor_polished_dark": Vector2i(11, 8),
	"floor_polished_light": Vector2i(11, 9),
	"floor_workshop": Vector2i(15, 11),
	"floor_workshop_alt": Vector2i(15, 12),
	"floor_damp": Vector2i(13, 10),
	"floor_damp_alt": Vector2i(13, 11),
	"moss": Vector2i(13, 1),
	"moss_alt": Vector2i(13, 2),
	"door_open": Vector2i(2, 2),
	"door_closed": Vector2i(3, 3),
	"carpet_top_left": Vector2i(13, 7),
	"carpet_top_middle": Vector2i(13, 8),
	"carpet_top_right": Vector2i(14, 7),
	"carpet_mid_left": Vector2i(14, 8),
	"carpet_mid_middle": Vector2i(11, 9),
	"carpet_mid_right": Vector2i(11, 8),
	"carpet_bottom_left": Vector2i(14, 9),
	"carpet_bottom_middle": Vector2i(14, 10),
	"carpet_bottom_right": Vector2i(14, 11),
	"anvil": Vector2i(1, 15),
	"crate": Vector2i(3, 5),
	"barrel": Vector2i(3, 6),
	"throne": Vector2i(1, 13),
	"stairs": Vector2i(3, 4),
	"forge": Vector2i(1, 15),
	"brazier": Vector2i(7, 6)
}



# Pre-scanned non-empty cells from Interior_Tileset (1-based atlas coords as Vector2i(col, row)).
const INTERIOR_TILESET_NON_EMPTY_CELLS: Array[Vector2i] = [
	Vector2i(5, 1),
	Vector2i(7, 1),
	Vector2i(9, 1),
	Vector2i(13, 1),
	Vector2i(15, 1),
	Vector2i(2, 2),
	Vector2i(5, 2),
	Vector2i(13, 2),
	Vector2i(1, 3),
	Vector2i(3, 3),
	Vector2i(4, 3),
	Vector2i(5, 3),
	Vector2i(6, 3),
	Vector2i(7, 3),
	Vector2i(3, 4),
	Vector2i(5, 4),
	Vector2i(6, 4),
	Vector2i(7, 4),
	Vector2i(1, 5),
	Vector2i(3, 5),
	Vector2i(4, 5),
	Vector2i(3, 6),
	Vector2i(4, 6),
	Vector2i(7, 6),
	Vector2i(10, 6),
	Vector2i(11, 6),
	Vector2i(1, 7),
	Vector2i(3, 7),
	Vector2i(4, 7),
	Vector2i(5, 7),
	Vector2i(6, 7),
	Vector2i(7, 7),
	Vector2i(9, 7),
	Vector2i(11, 7),
	Vector2i(13, 7),
	Vector2i(14, 7),
	Vector2i(2, 8),
	Vector2i(11, 8),
	Vector2i(13, 8),
	Vector2i(14, 8),
	Vector2i(1, 9),
	Vector2i(5, 9),
	Vector2i(7, 9),
	Vector2i(11, 9),
	Vector2i(14, 9),
	Vector2i(6, 10),
	Vector2i(10, 10),
	Vector2i(11, 10),
	Vector2i(13, 10),
	Vector2i(14, 10),
	Vector2i(6, 11),
	Vector2i(7, 11),
	Vector2i(8, 11),
	Vector2i(9, 11),
	Vector2i(10, 11),
	Vector2i(13, 11),
	Vector2i(14, 11),
	Vector2i(15, 11),
	Vector2i(15, 12),
	Vector2i(1, 13),
	Vector2i(2, 13),
	Vector2i(3, 13),
	Vector2i(4, 13),
	Vector2i(7, 13),
	Vector2i(8, 13),
	Vector2i(10, 13),
	Vector2i(11, 13),
	Vector2i(13, 13),
	Vector2i(7, 14),
	Vector2i(8, 14),
	Vector2i(9, 14),
	Vector2i(10, 14),
	Vector2i(11, 14),
	Vector2i(12, 14),
	Vector2i(13, 14),
	Vector2i(1, 15),
	Vector2i(11, 15),
	Vector2i(12, 15),
	Vector2i(13, 15),
	Vector2i(14, 15)
]

const TILE_POOLS := {
	"stone": ["stone", "stone_alt", "stone_dark"],
	"wall": ["wall", "wall_inner_left", "wall_inner_right"],
	"floor_carved": ["floor_carved", "floor_carved_alt", "floor_carved_worn"],
	"floor_polished": ["floor_polished", "floor_polished_alt", "floor_polished_dark", "floor_polished_light"],
	"floor_workshop": ["floor_workshop", "floor_workshop_alt"],
	"floor_damp": ["floor_damp", "floor_damp_alt"],
	"moss": ["moss", "moss_alt"]
}

@onready var seed_input: LineEdit = %SeedInput
@onready var generate_button: Button = %GenerateButton
@onready var city_texture_rect: TextureRect = %CityTexture
@onready var city_summary: Label = %CitySummary

var _rng := RandomNumberGenerator.new()
var _tilesheet_image: Image
var _tile_library: Dictionary = NAMED_TILE_LIBRARY.duplicate(true)

func _ready() -> void:
	_build_tile_library_from_static_index()
	_load_tilesheet_image()
	generate_button.pressed.connect(_on_generate_pressed)
	seed_input.text_submitted.connect(func(_text: String) -> void:
		_generate_city()
	)
	_generate_city()

func _on_generate_pressed() -> void:
	_generate_city()

func _generate_city() -> void:
	var seed_text := seed_input.text.strip_edges()
	if seed_text.is_empty():
		_rng.randomize()
		seed_text = str(_rng.randi())
		seed_input.text = seed_text
	_rng.seed = hash(seed_text)

	var grid := _create_grid(CELL_ROCK)
	var keep_center := map_size / 2
	var keep_size := Vector2i(
		clampi(map_size.x / 6, 10, 22),
		clampi(map_size.y / 5, 10, 18)
	)
	_dig_rect(grid, keep_center - keep_size / 2, keep_center + keep_size / 2, CELL_KEEP)

	var hubs: Array[Vector2i] = [keep_center]
	for i in hall_count:
		var center := Vector2i(
			_rng.randi_range(7, map_size.x - 8),
			_rng.randi_range(7, map_size.y - 8)
		)
		var hall_size := Vector2i(_rng.randi_range(4, 10), _rng.randi_range(3, 7))
		_dig_rect(grid, center - hall_size / 2, center + hall_size / 2, CELL_HALL)
		_connect_points(grid, center, _nearest_point(center, hubs), CELL_TUNNEL)
		hubs.append(center)

	for i in district_count:
		var district_center := Vector2i(
			_rng.randi_range(6, map_size.x - 7),
			_rng.randi_range(6, map_size.y - 7)
		)
		var radius := Vector2i(_rng.randi_range(6, 12), _rng.randi_range(4, 9))
		_dig_ellipse(grid, district_center, radius, CELL_DISTRICT)
		_connect_points(grid, district_center, _nearest_point(district_center, hubs), CELL_TUNNEL)
		hubs.append(district_center)

	for i in room_count:
		var hall_anchor := hubs[_rng.randi_range(0, hubs.size() - 1)]
		var room_center := hall_anchor + Vector2i(_rng.randi_range(-12, 12), _rng.randi_range(-8, 8))
		var room_size := Vector2i(_rng.randi_range(2, 5), _rng.randi_range(2, 4))
		_dig_rect(grid, room_center - room_size, room_center + room_size, CELL_ROOM)
		_connect_points(grid, room_center, hall_anchor, CELL_TUNNEL)

	for i in housing_count:
		var home_anchor := hubs[_rng.randi_range(0, hubs.size() - 1)]
		var home_center := home_anchor + Vector2i(_rng.randi_range(-10, 10), _rng.randi_range(-7, 7))
		var home_size := Vector2i(_rng.randi_range(1, 3), _rng.randi_range(1, 2))
		_dig_rect(grid, home_center - home_size, home_center + home_size, CELL_HOUSE)
		_connect_points(grid, home_center, home_anchor, CELL_TUNNEL)

	for i in civic_building_count:
		var civic_anchor := hubs[_rng.randi_range(0, hubs.size() - 1)]
		var civic_center := civic_anchor + Vector2i(_rng.randi_range(-10, 10), _rng.randi_range(-8, 8))
		var civic_size := Vector2i(_rng.randi_range(2, 4), _rng.randi_range(2, 3))
		_dig_rect(grid, civic_center - civic_size, civic_center + civic_size, CELL_BUILDING)
		_connect_points(grid, civic_center, civic_anchor, CELL_TUNNEL)

	var gate_y := keep_center.y
	for x in range(0, 4):
		_set_cell(grid, Vector2i(x, gate_y), CELL_GATE)
		_set_cell(grid, Vector2i(map_size.x - 1 - x, gate_y), CELL_GATE)
	_connect_points(grid, Vector2i(0, gate_y), keep_center, CELL_HALL)
	_connect_points(grid, Vector2i(map_size.x - 1, gate_y), keep_center, CELL_HALL)

	_render_city(grid)
	_update_summary(grid, seed_text)

func _create_grid(fill_value: int) -> Array:
	var rows: Array = []
	for y in map_size.y:
		var row: Array = []
		for x in map_size.x:
			row.append(fill_value)
		rows.append(row)
	return rows

func _dig_rect(grid: Array, from_cell: Vector2i, to_cell: Vector2i, tile: int) -> void:
	for y in range(from_cell.y, to_cell.y + 1):
		for x in range(from_cell.x, to_cell.x + 1):
			_set_cell(grid, Vector2i(x, y), tile)

func _dig_ellipse(grid: Array, center: Vector2i, radius: Vector2i, tile: int) -> void:
	for y in range(center.y - radius.y, center.y + radius.y + 1):
		for x in range(center.x - radius.x, center.x + radius.x + 1):
			var normalized_x := float(x - center.x) / maxf(float(radius.x), 1.0)
			var normalized_y := float(y - center.y) / maxf(float(radius.y), 1.0)
			if normalized_x * normalized_x + normalized_y * normalized_y <= 1.0:
				_set_cell(grid, Vector2i(x, y), tile)

func _connect_points(grid: Array, start: Vector2i, finish: Vector2i, tile: int) -> void:
	var cursor := start
	while cursor.x != finish.x:
		_set_cell(grid, cursor, tile)
		cursor.x += 1 if finish.x > cursor.x else -1
	while cursor.y != finish.y:
		_set_cell(grid, cursor, tile)
		cursor.y += 1 if finish.y > cursor.y else -1
	_set_cell(grid, finish, tile)

func _nearest_point(target: Vector2i, points: Array[Vector2i]) -> Vector2i:
	var nearest := points[0]
	var nearest_distance := target.distance_squared_to(nearest)
	for point in points:
		var candidate := target.distance_squared_to(point)
		if candidate < nearest_distance:
			nearest = point
			nearest_distance = candidate
	return nearest

func _set_cell(grid: Array, cell: Vector2i, tile: int) -> void:
	if cell.x < 0 or cell.y < 0 or cell.x >= map_size.x or cell.y >= map_size.y:
		return
	grid[cell.y][cell.x] = tile

func _render_city(grid: Array) -> void:
	if _tilesheet_image == null:
		return

	var output_size := Vector2i(map_size.x * tile_size.x, map_size.y * tile_size.y)
	var image := Image.create(output_size.x, output_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var keep_bounds := _find_bounds(grid, CELL_KEEP)

	for y in map_size.y:
		for x in map_size.x:
			var cell := int(grid[y][x])
			var base_tile := _pick_base_tile_key(grid, x, y, cell)
			_draw_named_tile(image, base_tile, Vector2i(x, y))
			var overlay_tile := _pick_overlay_tile_key(grid, x, y, cell, keep_bounds)
			if not overlay_tile.is_empty():
				_draw_named_tile(image, overlay_tile, Vector2i(x, y))

	city_texture_rect.texture = ImageTexture.create_from_image(image)

func _load_tilesheet_image() -> void:
	if not FileAccess.file_exists(tilesheet_path):
		return
	var loaded_image := Image.load_from_file(tilesheet_path)
	if loaded_image == null or loaded_image.is_empty():
		return
	_tilesheet_image = loaded_image

func _build_tile_library_from_static_index() -> void:
	_tile_library = NAMED_TILE_LIBRARY.duplicate(true)
	for atlas_cell in INTERIOR_TILESET_NON_EMPTY_CELLS:
		var auto_key := "interior_r%02d_c%02d" % [atlas_cell.y, atlas_cell.x]
		if not _tile_library.has(auto_key):
			_tile_library[auto_key] = atlas_cell

func _pick_base_tile_key(_grid: Array, _x: int, _y: int, cell: int) -> String:
	if _is_stone_floor_cell(cell):
		return "stone"
	return ""

func _pick_overlay_tile_key(grid: Array, x: int, y: int, cell: int, _keep_bounds: Rect2i) -> String:
	if not _is_stone_floor_cell(cell):
		return ""

	var north_void := _is_void_cell(grid, x, y - 1)
	var south_void := _is_void_cell(grid, x, y + 1)
	var west_void := _is_void_cell(grid, x - 1, y)
	var east_void := _is_void_cell(grid, x + 1, y)

	if north_void and west_void:
		return "wall_left_corner"
	if north_void and east_void:
		return "wall_right_corner"
	if north_void or south_void or west_void or east_void:
		return "wall"

	return ""

func _draw_named_tile(image: Image, key: String, map_cell: Vector2i) -> void:
	var atlas_cell: Vector2i = _tile_library.get(key, Vector2i.ZERO)
	if atlas_cell == Vector2i.ZERO:
		return
	var atlas_zero_based := atlas_cell - Vector2i.ONE
	var source_rect := Rect2i(atlas_zero_based.x * tile_size.x, atlas_zero_based.y * tile_size.y, tile_size.x, tile_size.y)
	var draw_position := Vector2i(map_cell.x * tile_size.x, map_cell.y * tile_size.y)
	image.blit_rect(_tilesheet_image, source_rect, draw_position)

func _pick_from_pool(pool: String) -> String:
	var entries: Array = TILE_POOLS.get(pool, [])
	if entries.is_empty():
		return "stone"
	return str(entries[_rng.randi_range(0, entries.size() - 1)])

func _find_bounds(grid: Array, tile_type: int) -> Rect2i:
	var min_x := map_size.x
	var min_y := map_size.y
	var max_x := -1
	var max_y := -1
	for y in map_size.y:
		for x in map_size.x:
			if int(grid[y][x]) != tile_type:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		return Rect2i(Vector2i.ZERO, Vector2i.ZERO)
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)

func _carpet_tile_for(carpet_rect: Rect2i, pos: Vector2i) -> String:
	var left := pos.x == carpet_rect.position.x
	var right := pos.x == carpet_rect.end.x - 1
	var top := pos.y == carpet_rect.position.y
	var bottom := pos.y == carpet_rect.end.y - 1

	if top and left:
		return "carpet_top_left"
	if top and right:
		return "carpet_top_right"
	if top:
		return "carpet_top_middle"
	if bottom and left:
		return "carpet_bottom_left"
	if bottom and right:
		return "carpet_bottom_right"
	if bottom:
		return "carpet_bottom_middle"
	if left:
		return "carpet_mid_left"
	if right:
		return "carpet_mid_right"
	return "carpet_mid_middle"

func _is_carved(grid: Array, x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= map_size.x or y >= map_size.y:
		return false
	return int(grid[y][x]) != CELL_ROCK

func _is_stone_floor_cell(cell: int) -> bool:
	return cell == CELL_HALL or cell == CELL_TUNNEL or cell == CELL_KEEP

func _is_void_cell(grid: Array, x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= map_size.x or y >= map_size.y:
		return true
	return not _is_stone_floor_cell(int(grid[y][x]))

func _is_focal_tile(x: int, y: int, stride: int) -> bool:
	return int(abs((x * 97 + y * 57 + int(_rng.seed)) % stride)) == 0

func _update_summary(grid: Array, seed_text: String) -> void:
	var tile_counts := {
		"Districts": 0,
		"Main Halls": 0,
		"Rooms": 0,
		"Houses": 0,
		"Buildings": 0,
		"Tunnels": 0,
		"Citadel": 0,
		"Gates": 0
	}
	for row: Array in grid:
		for tile: int in row:
			match int(tile):
				CELL_DISTRICT:
					tile_counts["Districts"] += 1
				CELL_HALL:
					tile_counts["Main Halls"] += 1
				CELL_ROOM:
					tile_counts["Rooms"] += 1
				CELL_HOUSE:
					tile_counts["Houses"] += 1
				CELL_BUILDING:
					tile_counts["Buildings"] += 1
				CELL_TUNNEL:
					tile_counts["Tunnels"] += 1
				CELL_KEEP:
					tile_counts["Citadel"] += 1
				CELL_GATE:
					tile_counts["Gates"] += 1

	var summary_lines: Array[String] = []
	for tile_label: String in tile_counts.keys():
		summary_lines.append("%s: %d" % [tile_label, tile_counts[tile_label]])

	var tile_role_lines := [
		"stone / wall / wall_left_corner / wall_right_corner",
		"door_open / door_closed",
		"carpet_top_left / carpet_top_middle / carpet_top_right",
		"carpet_mid_left / carpet_mid_middle / carpet_mid_right",
		"carpet_bottom_left / carpet_bottom_middle / carpet_bottom_right",
		"anvil / crate / barrel / throne / stairs / brazier"
	]

	city_summary.text = "Seed %s\nDistrict count: %d | Hall count: %d | Rooms: %d | Houses: %d | Buildings: %d\n%s\n\nTile roles\n%s" % [
		seed_text,
		district_count,
		hall_count,
		room_count,
		housing_count,
		civic_building_count,
		"\n".join(summary_lines),
		"\n".join(tile_role_lines)
	]
