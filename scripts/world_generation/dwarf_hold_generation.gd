extends Control

const CELL_ROCK := 0
const CELL_HALL := 1
const CELL_TUNNEL := 2
const CELL_DISTRICT := 3
const CELL_KEEP := 4
const CELL_GATE := 5

const TILE_COLORS := {
	CELL_ROCK: Color("1f1a1a"),
	CELL_HALL: Color("4f4946"),
	CELL_TUNNEL: Color("8b7f78"),
	CELL_DISTRICT: Color("b59f7a"),
	CELL_KEEP: Color("d8c49a"),
	CELL_GATE: Color("b56b3f")
}

@export var map_size := Vector2i(96, 64)
@export var district_count := 14

@onready var seed_input: LineEdit = %SeedInput
@onready var generate_button: Button = %GenerateButton
@onready var city_texture_rect: TextureRect = %CityTexture
@onready var city_summary: Label = %CitySummary

var _rng := RandomNumberGenerator.new()

func _ready() -> void:
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
		clampi(map_size.x / 8, 6, 16),
		clampi(map_size.y / 6, 6, 14)
	)
	_dig_rect(grid, keep_center - keep_size / 2, keep_center + keep_size / 2, CELL_KEEP)

	var district_centers: Array[Vector2i] = [keep_center]
	for i in district_count:
		var center := Vector2i(
			_rng.randi_range(6, map_size.x - 7),
			_rng.randi_range(6, map_size.y - 7)
		)
		var radius := Vector2i(_rng.randi_range(3, 8), _rng.randi_range(2, 6))
		_dig_ellipse(grid, center, radius, CELL_DISTRICT)
		_connect_points(grid, center, _nearest_point(center, district_centers), CELL_TUNNEL)
		district_centers.append(center)

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
	var image := Image.create(map_size.x, map_size.y, false, Image.FORMAT_RGBA8)
	for y in map_size.y:
		for x in map_size.x:
			image.set_pixel(x, y, TILE_COLORS.get(grid[y][x], Color.BLACK))
	var texture := ImageTexture.create_from_image(image)
	city_texture_rect.texture = texture

func _update_summary(grid: Array, seed_text: String) -> void:
	var tile_counts := {
		"Districts": 0,
		"Main Halls": 0,
		"Tunnels": 0,
		"Citadel": 0,
		"Gates": 0
	}
	for row in grid:
		for tile in row:
			match int(tile):
				CELL_DISTRICT:
					tile_counts["Districts"] += 1
				CELL_HALL:
					tile_counts["Main Halls"] += 1
				CELL_TUNNEL:
					tile_counts["Tunnels"] += 1
				CELL_KEEP:
					tile_counts["Citadel"] += 1
				CELL_GATE:
					tile_counts["Gates"] += 1

	var summary_lines: Array[String] = []
	for name in tile_counts.keys():
		summary_lines.append("%s: %d" % [name, tile_counts[name]])

	city_summary.text = "Seed %s\nDistrict count: %d\n%s" % [
		seed_text,
		district_count,
		"\n".join(summary_lines)
	]
