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

@export var district_count := 14
@export var hall_count := 18
@export var room_count := 120
@export var housing_count := 180
@export var civic_building_count := 70
@export var tile_size := Vector2i(32, 32)
@export var tilesheet_path := "res://resources/images/dwarfhold/map.png"

const TILE_ATLAS := {
	"dirt": Vector2i(0, 2),
	"workbench": Vector2i(0, 3),
	"shelf": Vector2i(0, 4),
	"winepress": Vector2i(0, 5),
	"grain_bag": Vector2i(0, 6),
	"wall_right": Vector2i(1, 1),
	"bed": Vector2i(1, 1),
	"butcher_table": Vector2i(1, 3),
	"chest": Vector2i(1, 5),
	"flour": Vector2i(1, 5),
	"sign": Vector2i(1, 7),
	"stone": Vector2i(2, 1),
	"wall_top": Vector2i(2, 2),
	"wall_bottom": Vector2i(2, 0),
	"mushroom_crops": Vector2i(2, 3),
	"wardrobe": Vector2i(2, 4),
	"floor": Vector2i(2, 6),
	"armor_stand": Vector2i(2, 7),
	"wall_left": Vector2i(3, 1),
	"table": Vector2i(3, 3),
	"mug": Vector2i(3, 4),
	"mushroom_crop_wild": Vector2i(3, 5),
	"water_bucket": Vector2i(3, 6),
	"stool": Vector2i(4, 2),
	"table_alt": Vector2i(5, 2),
	"door": Vector2i(4, 3),
	"desk": Vector2i(4, 4),
	"mushroom_wild": Vector2i(4, 5),
	"keg": Vector2i(5, 5),
	"target": Vector2i(6, 3),
	"anvil": Vector2i(6, 4)
}

const EXPECTED_TILE_COORDS := {
	"dirt": Vector2i(0, 2),
	"workbench": Vector2i(0, 3),
	"shelf": Vector2i(0, 4),
	"winepress": Vector2i(0, 5),
	"grain_bag": Vector2i(0, 6),
	"wall_right": Vector2i(1, 1),
	"bed": Vector2i(1, 1),
	"butcher_table": Vector2i(1, 3),
	"chest": Vector2i(1, 5),
	"flour": Vector2i(1, 5),
	"sign": Vector2i(1, 7),
	"stone": Vector2i(2, 1),
	"wall_top": Vector2i(2, 2),
	"wall_bottom": Vector2i(2, 0),
	"mushroom_crops": Vector2i(2, 3),
	"wardrobe": Vector2i(2, 4),
	"floor": Vector2i(2, 6),
	"armor_stand": Vector2i(2, 7),
	"wall_left": Vector2i(3, 1),
	"table": Vector2i(3, 3),
	"mug": Vector2i(3, 4),
	"mushroom_crop_wild": Vector2i(3, 5),
	"water_bucket": Vector2i(3, 6),
	"stool": Vector2i(4, 2),
	"table_alt": Vector2i(5, 2),
	"door": Vector2i(4, 3),
	"desk": Vector2i(4, 4),
	"mushroom_wild": Vector2i(4, 5),
	"keg": Vector2i(5, 5),
	"target": Vector2i(6, 3),
	"anvil": Vector2i(6, 4)
}

@onready var seed_input: LineEdit = %SeedInput
@onready var generate_button: Button = %GenerateButton
@onready var city_summary: Label = %CitySummary
@onready var city_panel: PanelContainer = %CityPanel
@onready var city_layer: TileMapLayer = %CityTileLayer
@onready var tile_hover_tooltip: PanelContainer = %TileHoverTooltip
@onready var tile_hover_label: Label = %TileHoverLabel

var _rng := RandomNumberGenerator.new()
var _is_panning := false
var _zoom_level := 1.0
var _pan_offset := Vector2.ZERO
var _map_origin_offset := Vector2.ZERO

const MIN_ZOOM := 0.25
const MAX_ZOOM := 2.5
const ZOOM_STEP := 0.1

func _ready() -> void:
	_configure_tile_layer()
	generate_button.pressed.connect(_on_generate_pressed)
	city_panel.gui_input.connect(_on_city_panel_gui_input)
	seed_input.text_submitted.connect(func(_text: String) -> void:
		_generate_city()
	)
	_generate_city()

func _configure_tile_layer() -> void:
	if not _validate_tile_mapping():
		return
	if not FileAccess.file_exists(tilesheet_path):
		push_error("Missing dwarf hold tilesheet at %s" % tilesheet_path)
		return
	var texture := load(tilesheet_path) as Texture2D
	if texture == null:
		push_error("Unable to load dwarf hold tilesheet texture at %s" % tilesheet_path)
		return

	var atlas := TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = tile_size
	for atlas_coords: Vector2i in TILE_ATLAS.values():
		atlas.create_tile(atlas_coords)

	var tile_set := TileSet.new()
	tile_set.tile_size = tile_size
	tile_set.add_source(atlas, 0)
	city_layer.tile_set = tile_set

func _validate_tile_mapping() -> bool:
	for tile_key: String in EXPECTED_TILE_COORDS.keys():
		if not TILE_ATLAS.has(tile_key):
			push_error("Tile mapping missing required key: %s" % tile_key)
			return false
		var expected_coords: Vector2i = EXPECTED_TILE_COORDS[tile_key]
		var actual_coords: Vector2i = TILE_ATLAS[tile_key]
		if actual_coords != expected_coords:
			push_error("Tile mapping mismatch for %s. Expected %s but found %s" % [tile_key, expected_coords, actual_coords])
			return false
	return true

func _on_generate_pressed() -> void:
	_generate_city()

func _generate_city() -> void:
	var seed_text := seed_input.text.strip_edges()
	if seed_text.is_empty():
		_rng.randomize()
		seed_text = str(_rng.randi())
		seed_input.text = seed_text
	_rng.seed = hash(seed_text)

	var grid: Dictionary = {}
	var keep_center := Vector2i.ZERO
	var keep_size := Vector2i(18, 14)
	_dig_rect(grid, keep_center - keep_size / 2, keep_center + keep_size / 2, CELL_KEEP)

	var hubs: Array[Vector2i] = [keep_center]

	for i in hall_count:
		var anchor := hubs[_rng.randi_range(0, hubs.size() - 1)]
		var center := anchor + Vector2i(_rng.randi_range(-30, 30), _rng.randi_range(-20, 20))
		var hall_size := Vector2i(_rng.randi_range(4, 10), _rng.randi_range(3, 7))
		_dig_rect(grid, center - hall_size / 2, center + hall_size / 2, CELL_HALL)
		_connect_points(grid, center, _nearest_point(center, hubs), CELL_TUNNEL)
		hubs.append(center)

	for i in district_count:
		var anchor := hubs[_rng.randi_range(0, hubs.size() - 1)]
		var district_center := anchor + Vector2i(_rng.randi_range(-28, 28), _rng.randi_range(-18, 18))
		var radius := Vector2i(_rng.randi_range(6, 12), _rng.randi_range(4, 9))
		_dig_ellipse(grid, district_center, radius, CELL_DISTRICT)
		_connect_points(grid, district_center, _nearest_point(district_center, hubs), CELL_TUNNEL)
		hubs.append(district_center)

	for i in room_count:
		var hall_anchor := hubs[_rng.randi_range(0, hubs.size() - 1)]
		var room_center := hall_anchor + Vector2i(_rng.randi_range(-16, 16), _rng.randi_range(-10, 10))
		var room_size := Vector2i(_rng.randi_range(2, 5), _rng.randi_range(2, 4))
		_dig_rect(grid, room_center - room_size, room_center + room_size, CELL_ROOM)
		_connect_points(grid, room_center, hall_anchor, CELL_TUNNEL)

	for i in housing_count:
		var home_anchor := hubs[_rng.randi_range(0, hubs.size() - 1)]
		var home_center := home_anchor + Vector2i(_rng.randi_range(-14, 14), _rng.randi_range(-9, 9))
		var home_size := Vector2i(_rng.randi_range(1, 3), _rng.randi_range(1, 2))
		_dig_rect(grid, home_center - home_size, home_center + home_size, CELL_HOUSE)
		_connect_points(grid, home_center, home_anchor, CELL_TUNNEL)

	for i in civic_building_count:
		var civic_anchor := hubs[_rng.randi_range(0, hubs.size() - 1)]
		var civic_center := civic_anchor + Vector2i(_rng.randi_range(-15, 15), _rng.randi_range(-10, 10))
		var civic_size := Vector2i(_rng.randi_range(2, 4), _rng.randi_range(2, 3))
		_dig_rect(grid, civic_center - civic_size, civic_center + civic_size, CELL_BUILDING)
		_connect_points(grid, civic_center, civic_anchor, CELL_TUNNEL)

	var bounds := _find_bounds(grid)
	var gate_y := keep_center.y
	var left_gate_x := bounds.position.x - 6
	var right_gate_x := bounds.end.x + 5
	for x in range(left_gate_x, left_gate_x + 4):
		_set_cell(grid, Vector2i(x, gate_y), CELL_GATE)
	for x in range(right_gate_x - 3, right_gate_x + 1):
		_set_cell(grid, Vector2i(x, gate_y), CELL_GATE)
	_connect_points(grid, Vector2i(left_gate_x, gate_y), keep_center, CELL_HALL)
	_connect_points(grid, Vector2i(right_gate_x, gate_y), keep_center, CELL_HALL)

	_render_city(grid)
	_update_summary(grid, seed_text)

func _dig_rect(grid: Dictionary, from_cell: Vector2i, to_cell: Vector2i, tile: int) -> void:
	for y in range(from_cell.y, to_cell.y + 1):
		for x in range(from_cell.x, to_cell.x + 1):
			_set_cell(grid, Vector2i(x, y), tile)

func _dig_ellipse(grid: Dictionary, center: Vector2i, radius: Vector2i, tile: int) -> void:
	for y in range(center.y - radius.y, center.y + radius.y + 1):
		for x in range(center.x - radius.x, center.x + radius.x + 1):
			var normalized_x := float(x - center.x) / maxf(float(radius.x), 1.0)
			var normalized_y := float(y - center.y) / maxf(float(radius.y), 1.0)
			if normalized_x * normalized_x + normalized_y * normalized_y <= 1.0:
				_set_cell(grid, Vector2i(x, y), tile)

func _connect_points(grid: Dictionary, start: Vector2i, finish: Vector2i, tile: int) -> void:
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

func _set_cell(grid: Dictionary, cell: Vector2i, tile: int) -> void:
	grid[cell] = tile

func _cell_at(grid: Dictionary, x: int, y: int) -> int:
	return int(grid.get(Vector2i(x, y), CELL_ROCK))

func _is_structural_cell(cell: int) -> bool:
	return cell == CELL_ROOM or cell == CELL_HOUSE or cell == CELL_BUILDING or cell == CELL_KEEP

func _is_corridor_cell(cell: int) -> bool:
	return cell == CELL_TUNNEL or cell == CELL_HALL or cell == CELL_DISTRICT or cell == CELL_GATE

func _find_bounds(grid: Dictionary) -> Rect2i:
	if grid.is_empty():
		return Rect2i(Vector2i.ZERO, Vector2i.ONE)
	var min_x := 2147483647
	var min_y := 2147483647
	var max_x := -2147483648
	var max_y := -2147483648
	for key: Variant in grid.keys():
		var cell := key as Vector2i
		min_x = mini(min_x, cell.x)
		min_y = mini(min_y, cell.y)
		max_x = maxi(max_x, cell.x)
		max_y = maxi(max_y, cell.y)
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)

func _render_city(grid: Dictionary) -> void:
	if city_layer.tile_set == null:
		return
	city_layer.clear()
	var bounds := _find_bounds(grid)
	var house_decor_overrides := _build_house_decor_layouts(grid)
	for y in range(bounds.position.y, bounds.end.y):
		for x in range(bounds.position.x, bounds.end.x):
			var cell := _cell_at(grid, x, y)
			if cell == CELL_ROCK:
				continue
			var base_tile := _pick_base_tile(grid, x, y, cell)
			_place_tile(Vector2i(x, y), base_tile)
			var decor_tile := _pick_decor_tile(grid, x, y, cell, house_decor_overrides)
			if not decor_tile.is_empty():
				_place_tile(Vector2i(x, y), decor_tile)
	_reset_view(bounds)

func _build_house_decor_layouts(grid: Dictionary) -> Dictionary:
	var visited: Dictionary = {}
	var overrides: Dictionary = {}
	for key: Variant in grid.keys():
		var start_cell := key as Vector2i
		if _cell_at(grid, start_cell.x, start_cell.y) != CELL_HOUSE:
			continue
		if visited.has(start_cell):
			continue

		var queue: Array[Vector2i] = [start_cell]
		var component: Array[Vector2i] = []
		visited[start_cell] = true
		while not queue.is_empty():
			var current := queue.pop_front()
			component.append(current)
			for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var neighbor := current + direction
				if visited.has(neighbor):
					continue
				if _cell_at(grid, neighbor.x, neighbor.y) != CELL_HOUSE:
					continue
				visited[neighbor] = true
				queue.append(neighbor)

		if component.is_empty():
			continue
		_place_house_decor_template(component, overrides)

	return overrides

func _place_house_decor_template(component: Array[Vector2i], overrides: Dictionary) -> void:
	var occupied: Dictionary = {}
	for cell: Vector2i in component:
		occupied[cell] = true

	var min_x := component[0].x
	var max_x := component[0].x
	var min_y := component[0].y
	var max_y := component[0].y
	for cell: Vector2i in component:
		min_x = mini(min_x, cell.x)
		max_x = maxi(max_x, cell.x)
		min_y = mini(min_y, cell.y)
		max_y = maxi(max_y, cell.y)

	var top_left_chest := Vector2i(min_x + 1, min_y + 1)
	var top_left_bed := Vector2i(min_x + 2, min_y + 1)
	var top_right_wardrobe := Vector2i(max_x - 1, min_y + 1)
	var center_table := Vector2i((min_x + max_x) / 2, (min_y + max_y) / 2)
	var stool_a := center_table + Vector2i(-1, 0)
	var stool_b := center_table + Vector2i(0, -1)

	_try_assign_house_decor(overrides, occupied, top_left_chest, "chest")
	_try_assign_house_decor(overrides, occupied, top_left_bed, "bed")
	_try_assign_house_decor(overrides, occupied, top_right_wardrobe, "wardrobe")
	_try_assign_house_decor(overrides, occupied, center_table, "table")
	_try_assign_house_decor(overrides, occupied, stool_a, "stool")
	_try_assign_house_decor(overrides, occupied, stool_b, "stool")

func _try_assign_house_decor(overrides: Dictionary, occupied: Dictionary, cell: Vector2i, tile_key: String) -> void:
	if not occupied.has(cell):
		return
	overrides[cell] = tile_key

func _on_city_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_MIDDLE or mouse_button.button_index == MOUSE_BUTTON_RIGHT:
			_is_panning = mouse_button.pressed
		if mouse_button.pressed:
			if mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP:
				_apply_zoom(ZOOM_STEP, mouse_button.position)
			elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_apply_zoom(-ZOOM_STEP, mouse_button.position)
	if event is InputEventMouseMotion and _is_panning:
		var motion := event as InputEventMouseMotion
		_pan_offset += motion.relative
		_update_city_layer_transform()
	if event is InputEventMouse:
		_update_hover_tooltip((event as InputEventMouse).position)

func _apply_zoom(zoom_delta: float, focus_position: Vector2) -> void:
	var previous_zoom := _zoom_level
	_zoom_level = clampf(_zoom_level + zoom_delta, MIN_ZOOM, MAX_ZOOM)
	if is_equal_approx(previous_zoom, _zoom_level):
		return
	var zoom_ratio := _zoom_level / previous_zoom
	_pan_offset = focus_position - ((focus_position - _pan_offset) * zoom_ratio)
	_update_city_layer_transform()

func _reset_view(bounds: Rect2i) -> void:
	var panel_size := city_panel.size
	if panel_size.x <= 0.0 or panel_size.y <= 0.0:
		return
	var map_size := Vector2(bounds.size * tile_size)
	_map_origin_offset = -Vector2(bounds.position * tile_size)
	var fit_zoom := minf(
		panel_size.x / maxf(map_size.x + 32.0, 1.0),
		panel_size.y / maxf(map_size.y + 32.0, 1.0)
	)
	_zoom_level = clampf(fit_zoom, MIN_ZOOM, 1.0)
	var scaled_map_size := map_size * _zoom_level
	_pan_offset = (panel_size - scaled_map_size) * 0.5
	_update_city_layer_transform()

func _update_city_layer_transform() -> void:
	city_layer.scale = Vector2.ONE * _zoom_level
	city_layer.position = _pan_offset + (_map_origin_offset * _zoom_level)
	if tile_hover_tooltip.visible:
		tile_hover_tooltip.position = _clamp_tooltip_position(tile_hover_tooltip.position)

func _place_tile(cell: Vector2i, tile_key: String) -> void:
	var atlas_coords: Vector2i = TILE_ATLAS.get(tile_key, Vector2i(-1, -1))
	if atlas_coords.x < 0:
		return
	city_layer.set_cell(cell, 0, atlas_coords, 0)

func _pick_base_tile(grid: Dictionary, x: int, y: int, cell: int) -> String:
	if _is_structural_cell(cell):
		return _wall_or_floor_tile(grid, x, y, cell)
	match cell:
		CELL_DISTRICT:
			return "dirt" if _rng.randf() < 0.55 else "mushroom_crop_wild"
		CELL_HALL, CELL_TUNNEL, CELL_GATE:
			return "floor"
		_:
			return "stone"

func _wall_or_floor_tile(grid: Dictionary, x: int, y: int, cell: int) -> String:
	var left_cell := _cell_at(grid, x - 1, y)
	var right_cell := _cell_at(grid, x + 1, y)
	var top_cell := _cell_at(grid, x, y - 1)
	var bottom_cell := _cell_at(grid, x, y + 1)
	var left_open := _is_corridor_cell(left_cell)
	var right_open := _is_corridor_cell(right_cell)
	var top_open := _is_corridor_cell(top_cell)
	var bottom_open := _is_corridor_cell(bottom_cell)
	var left_same := left_cell == cell
	var right_same := right_cell == cell
	var top_same := top_cell == cell
	var bottom_same := bottom_cell == cell

	if left_open:
		return "door" if _rng.randf() < 0.25 else "wall_left"
	if right_open:
		return "door" if _rng.randf() < 0.25 else "wall_right"
	if top_open or not top_same:
		return "wall_top"
	if bottom_open or not bottom_same:
		return "wall_bottom"
	if not left_same:
		return "wall_left"
	if not right_same:
		return "wall_right"

	return "floor"

func _pick_decor_tile(grid: Dictionary, x: int, y: int, cell: int, house_decor_overrides: Dictionary) -> String:
	var key := Vector2i(x, y)
	if house_decor_overrides.has(key):
		return String(house_decor_overrides[key])

	if _is_corridor_cell(cell):
		if _rng.randf() < 0.015:
			return ["target", "sign", "keg", "water_bucket"][_rng.randi_range(0, 3)]
		return ""
	if cell == CELL_DISTRICT:
		if _rng.randf() < 0.06:
			return ["mushroom_crops", "mushroom_wild", "grain_bag"][_rng.randi_range(0, 2)]
		return ""
	if _is_structural_cell(cell):
		if _is_corridor_cell(_cell_at(grid, x - 1, y)) or _is_corridor_cell(_cell_at(grid, x + 1, y)) or _is_corridor_cell(_cell_at(grid, x, y - 1)) or _is_corridor_cell(_cell_at(grid, x, y + 1)):
			return ""
		if _rng.randf() > 0.09:
			return ""
		if cell == CELL_HOUSE:
			return ["bed", "chest", "wardrobe", "stool", "mug"][_rng.randi_range(0, 4)]
		if cell == CELL_BUILDING:
			return ["workbench", "desk", "anvil", "shelf", "armor_stand", "winepress", "butcher_table", "flour"][_rng.randi_range(0, 7)]
		if cell == CELL_KEEP:
			return ["table", "table_alt", "keg", "target"][_rng.randi_range(0, 3)]
		return ["table", "mug", "water_bucket"][_rng.randi_range(0, 2)]
	return ""

func _update_summary(grid: Dictionary, seed_text: String) -> void:
	var bounds := _find_bounds(grid)

	city_summary.text = "Seed %s\nBounds: %dx%d (origin %d, %d)\nDistrict count: %d | Hall count: %d | Rooms: %d | Houses: %d | Buildings: %d" % [
		seed_text,
		bounds.size.x,
		bounds.size.y,
		bounds.position.x,
		bounds.position.y,
		district_count,
		hall_count,
		room_count,
		housing_count,
		civic_building_count
	]

func _update_hover_tooltip(mouse_position: Vector2) -> void:
	if city_layer.tile_set == null:
		_hide_hover_tooltip()
		return

	var local_position := (mouse_position - city_layer.position) / _zoom_level
	var hovered_cell := city_layer.local_to_map(local_position)
	if city_layer.get_cell_source_id(hovered_cell) < 0:
		_hide_hover_tooltip()
		return

	var atlas_coords := city_layer.get_cell_atlas_coords(hovered_cell)
	var tile_name := _tile_name_from_atlas(atlas_coords)
	tile_hover_label.text = "Tile: %s" % tile_name
	tile_hover_tooltip.visible = true
	tile_hover_tooltip.reset_size()
	tile_hover_tooltip.position = _clamp_tooltip_position(mouse_position + Vector2(14, 14))

func _hide_hover_tooltip() -> void:
	tile_hover_tooltip.visible = false

func _tile_name_from_atlas(atlas_coords: Vector2i) -> String:
	for tile_key: String in TILE_ATLAS.keys():
		if TILE_ATLAS[tile_key] == atlas_coords:
			return tile_key.replace("_", " ").capitalize()
	return "Unknown"

func _clamp_tooltip_position(desired_position: Vector2) -> Vector2:
	var tooltip_size := tile_hover_tooltip.size
	var panel_size := city_panel.size
	return Vector2(
		clampf(desired_position.x, 0.0, maxf(panel_size.x - tooltip_size.x, 0.0)),
		clampf(desired_position.y, 0.0, maxf(panel_size.y - tooltip_size.y, 0.0))
	)
