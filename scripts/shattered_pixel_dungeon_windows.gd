extends Control

const TILE_EMPTY := -1
const TILE_WALL := 0
const TILE_FLOOR := 1
const TILE_DOOR_CLOSED := 2
const TILE_DOOR_OPEN := 3
const TILE_WATER := 4
const TILE_GRASS := 5
const TILE_BARREL := 6
const TILE_CHEST := 7

const MAP_WIDTH := 36
const MAP_HEIGHT := 26
const CELL_SIZE := 16
const SOURCE_TILE_SIZE := 16
const VISION_RADIUS := 7

const TILE_SHEET_PATH := "res://resources/images/shattered_ui/tiles_sewers.png"
const HERO_SPRITE_PATH := "res://resources/images/shattered_ui/warrior.png"

# SPD-inspired tile buckets sampled from the sewers atlas.
const FLOOR_VARIANTS := [
	Vector2i(0, 0), Vector2i(4, 8), Vector2i(5, 8), Vector2i(6, 8), Vector2i(7, 8), Vector2i(8, 8)
]
const WALL_VARIANTS := {
	0: Vector2i(0, 0),
	1: Vector2i(1, 0),
	2: Vector2i(2, 0),
	3: Vector2i(3, 0),
	4: Vector2i(4, 0),
	5: Vector2i(5, 0),
	6: Vector2i(6, 0),
	7: Vector2i(7, 0),
	8: Vector2i(8, 0),
	9: Vector2i(9, 0),
	10: Vector2i(10, 0),
	11: Vector2i(11, 0),
	12: Vector2i(12, 0),
	13: Vector2i(13, 0),
	14: Vector2i(14, 0),
	15: Vector2i(15, 0)
}
const DOOR_CLOSED_VARIANTS := [Vector2i(11, 3)]
const DOOR_OPEN_VARIANTS := [Vector2i(12, 3)]
const WATER_VARIANTS := [
	Vector2i(2, 14), Vector2i(3, 14), Vector2i(6, 14), Vector2i(7, 14), Vector2i(8, 14)
]
const GRASS_VARIANTS := [
	Vector2i(2, 4), Vector2i(3, 4), Vector2i(5, 4), Vector2i(7, 4), Vector2i(10, 7)
]
const BARREL_VARIANTS := [Vector2i(10, 4), Vector2i(11, 4), Vector2i(2, 8), Vector2i(3, 8)]
const CHEST_VARIANTS := [Vector2i(10, 3), Vector2i(11, 3)]

@onready var dungeon_view: Control = $Layout/Margin/Content/DungeonView
@onready var status_label: Label = $Layout/Margin/Content/HUD/StatusLabel

var rng := RandomNumberGenerator.new()
var tile_sheet: Texture2D
var hero_sprite: Texture2D
var map_tiles: Array[PackedInt32Array] = []
var revealed: Array[PackedByteArray] = []
var visible_cells: Array[PackedByteArray] = []
var player_cell := Vector2i.ZERO
var missing_tile_sheet_warning := false


func _ready() -> void:
	rng.randomize()
	tile_sheet = load(TILE_SHEET_PATH) as Texture2D
	hero_sprite = load(HERO_SPRITE_PATH) as Texture2D
	if tile_sheet == null and _is_git_lfs_pointer(TILE_SHEET_PATH):
		missing_tile_sheet_warning = true
	_generate_dungeon()
	dungeon_view.draw.connect(_on_dungeon_view_draw)
	dungeon_view.gui_input.connect(_on_dungeon_view_gui_input)
	if missing_tile_sheet_warning:
		_update_status("Shattered tileset missing (Git LFS pointer detected). Rendering fallback dungeon colors.")
	else:
		_update_status("Dungeon generated. Dense rooms, corridors, and line-of-sight lighting enabled.")
	dungeon_view.queue_redraw()


func _on_regenerate_button_pressed() -> void:
	_generate_dungeon()
	_update_status("A deeper sewer layout has been generated.")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


func _generate_dungeon() -> void:
	_initialize_maps()

	var rooms: Array[Rect2i] = _generate_room_candidates()
	if rooms.is_empty():
		_generate_dungeon()
		return

	_connect_rooms(rooms)
	_build_walls_from_floors()
	_place_doors()
	_place_terrain_features(rooms)
	_place_decor(rooms)

	player_cell = _room_center(rooms[0])
	_ensure_player_on_floor()
	_update_visibility()
	dungeon_view.queue_redraw()


func _initialize_maps() -> void:
	map_tiles.clear()
	revealed.clear()
	visible_cells.clear()

	for _y in MAP_HEIGHT:
		var tile_row := PackedInt32Array()
		var seen_row := PackedByteArray()
		var vis_row := PackedByteArray()
		tile_row.resize(MAP_WIDTH)
		seen_row.resize(MAP_WIDTH)
		vis_row.resize(MAP_WIDTH)
		tile_row.fill(TILE_EMPTY)
		seen_row.fill(0)
		vis_row.fill(0)
		map_tiles.append(tile_row)
		revealed.append(seen_row)
		visible_cells.append(vis_row)


func _generate_room_candidates() -> Array[Rect2i]:
	var rooms: Array[Rect2i] = []
	for _attempt in 160:
		var room_size := Vector2i(rng.randi_range(4, 10), rng.randi_range(4, 9))
		var pos := Vector2i(
			rng.randi_range(2, MAP_WIDTH - room_size.x - 3),
			rng.randi_range(2, MAP_HEIGHT - room_size.y - 3)
		)
		var candidate := Rect2i(pos, room_size)
		var overlaps := false
		for room: Rect2i in rooms:
			if room.grow(2).intersects(candidate):
				overlaps = true
				break
		if overlaps:
			continue
		rooms.append(candidate)
		_carve_room(candidate)
		if rooms.size() >= 18:
			break

	return rooms


func _connect_rooms(rooms: Array[Rect2i]) -> void:
	if rooms.size() < 2:
		return

	var connected: Array[int] = [0]
	while connected.size() < rooms.size():
		var best_a := -1
		var best_b := -1
		var best_dist := INF

		for a_index: int in connected:
			for b_index in rooms.size():
				if connected.has(b_index):
					continue
				var a_center := _room_center(rooms[a_index])
				var b_center := _room_center(rooms[b_index])
				var dist := a_center.distance_squared_to(b_center)
				if dist < best_dist:
					best_dist = dist
					best_a = a_index
					best_b = b_index

		if best_a == -1 or best_b == -1:
			break
		_carve_corridor(_room_center(rooms[best_a]), _room_center(rooms[best_b]))
		connected.append(best_b)

	# Add a few loops so the dungeon doesn't feel like a strict tree.
	for _i in 4:
		var room_a := rooms[rng.randi_range(0, rooms.size() - 1)]
		var room_b := rooms[rng.randi_range(0, rooms.size() - 1)]
		if room_a == room_b:
			continue
		if rng.randf() < 0.65:
			_carve_corridor(_room_center(room_a), _room_center(room_b))


func _carve_room(room: Rect2i) -> void:
	for y in range(room.position.y, room.end.y):
		for x in range(room.position.x, room.end.x):
			map_tiles[y][x] = TILE_FLOOR


func _carve_corridor(from_cell: Vector2i, to_cell: Vector2i) -> void:
	if rng.randf() < 0.5:
		_carve_h_tunnel(from_cell.x, to_cell.x, from_cell.y)
		_carve_v_tunnel(from_cell.y, to_cell.y, to_cell.x)
	else:
		_carve_v_tunnel(from_cell.y, to_cell.y, from_cell.x)
		_carve_h_tunnel(from_cell.x, to_cell.x, to_cell.y)


func _carve_h_tunnel(x1: int, x2: int, y: int) -> void:
	for x in range(mini(x1, x2), maxi(x1, x2) + 1):
		if _in_bounds(x, y):
			map_tiles[y][x] = TILE_FLOOR


func _carve_v_tunnel(y1: int, y2: int, x: int) -> void:
	for y in range(mini(y1, y2), maxi(y1, y2) + 1):
		if _in_bounds(x, y):
			map_tiles[y][x] = TILE_FLOOR


func _build_walls_from_floors() -> void:
	for y in MAP_HEIGHT:
		for x in MAP_WIDTH:
			if map_tiles[y][x] != TILE_FLOOR:
				continue
			for ny in range(y - 1, y + 2):
				for nx in range(x - 1, x + 2):
					if not _in_bounds(nx, ny):
						continue
					if map_tiles[ny][nx] == TILE_EMPTY:
						map_tiles[ny][nx] = TILE_WALL


func _place_doors() -> void:
	for y in range(1, MAP_HEIGHT - 1):
		for x in range(1, MAP_WIDTH - 1):
			if map_tiles[y][x] != TILE_FLOOR:
				continue

			var left_wall := map_tiles[y][x - 1] == TILE_WALL
			var right_wall := map_tiles[y][x + 1] == TILE_WALL
			var up_wall := map_tiles[y - 1][x] == TILE_WALL
			var down_wall := map_tiles[y + 1][x] == TILE_WALL

			var vertical_door := up_wall and down_wall and not left_wall and not right_wall
			var horizontal_door := left_wall and right_wall and not up_wall and not down_wall
			if (vertical_door or horizontal_door) and rng.randf() < 0.12:
				map_tiles[y][x] = TILE_DOOR_CLOSED


func _place_terrain_features(rooms: Array[Rect2i]) -> void:
	for room: Rect2i in rooms:
		if rng.randf() < 0.35:
			_place_patch(room, TILE_WATER, rng.randi_range(3, 6), 0.65)
		if rng.randf() < 0.45:
			_place_patch(room, TILE_GRASS, rng.randi_range(4, 8), 0.75)


func _place_patch(room: Rect2i, tile_type: int, attempts: int, chance: float) -> void:
	if room.size.x <= 3 or room.size.y <= 3:
		return
	var patch_origin := Vector2i(
		rng.randi_range(room.position.x + 1, room.end.x - 2),
		rng.randi_range(room.position.y + 1, room.end.y - 2)
	)
	for _i in attempts:
		var pos := patch_origin + Vector2i(rng.randi_range(-2, 2), rng.randi_range(-2, 2))
		if not _in_bounds(pos.x, pos.y):
			continue
		if map_tiles[pos.y][pos.x] == TILE_FLOOR and rng.randf() < chance:
			map_tiles[pos.y][pos.x] = tile_type


func _place_decor(rooms: Array[Rect2i]) -> void:
	for room: Rect2i in rooms:
		for _i in rng.randi_range(0, 2):
			var x := rng.randi_range(room.position.x + 1, room.end.x - 2)
			var y := rng.randi_range(room.position.y + 1, room.end.y - 2)
			if map_tiles[y][x] != TILE_FLOOR:
				continue
			if _adjacent_wall_count(x, y) == 0 and rng.randf() < 0.75:
				continue
			map_tiles[y][x] = TILE_BARREL if rng.randf() < 0.85 else TILE_CHEST


func _adjacent_wall_count(x: int, y: int) -> int:
	var count := 0
	if map_tiles[y - 1][x] == TILE_WALL:
		count += 1
	if map_tiles[y + 1][x] == TILE_WALL:
		count += 1
	if map_tiles[y][x - 1] == TILE_WALL:
		count += 1
	if map_tiles[y][x + 1] == TILE_WALL:
		count += 1
	return count


func _ensure_player_on_floor() -> void:
	if _is_walkable_tile(map_tiles[player_cell.y][player_cell.x]):
		return
	for y in MAP_HEIGHT:
		for x in MAP_WIDTH:
			if _is_walkable_tile(map_tiles[y][x]):
				player_cell = Vector2i(x, y)
				return


func _on_dungeon_view_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		dungeon_view.grab_focus()
	if event.is_action_pressed("ui_left"):
		_try_move(Vector2i.LEFT)
	elif event.is_action_pressed("ui_right"):
		_try_move(Vector2i.RIGHT)
	elif event.is_action_pressed("ui_up"):
		_try_move(Vector2i.UP)
	elif event.is_action_pressed("ui_down"):
		_try_move(Vector2i.DOWN)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		_try_move(Vector2i.LEFT)
	elif event.is_action_pressed("ui_right"):
		_try_move(Vector2i.RIGHT)
	elif event.is_action_pressed("ui_up"):
		_try_move(Vector2i.UP)
	elif event.is_action_pressed("ui_down"):
		_try_move(Vector2i.DOWN)


func _try_move(delta: Vector2i) -> void:
	var target := player_cell + delta
	if not _in_bounds(target.x, target.y):
		return

	var tile := map_tiles[target.y][target.x]
	if tile == TILE_WALL or tile == TILE_EMPTY:
		_update_status("You bump into solid masonry.")
		return
	if tile == TILE_DOOR_CLOSED:
		map_tiles[target.y][target.x] = TILE_DOOR_OPEN
		_update_status("The old door creaks open.")
	elif tile == TILE_WATER:
		_update_status("Water ripples beneath your boots.")
	elif tile == TILE_GRASS:
		_update_status("Tall grass rustles quietly.")
	else:
		_update_status("You advance deeper into the dungeon.")

	if _is_walkable_tile(map_tiles[target.y][target.x]):
		player_cell = target
		_update_visibility()
		dungeon_view.queue_redraw()


func _on_dungeon_view_draw() -> void:
	dungeon_view.draw_rect(Rect2(Vector2.ZERO, Vector2(MAP_WIDTH, MAP_HEIGHT) * CELL_SIZE), Color.BLACK)
	for y in MAP_HEIGHT:
		for x in MAP_WIDTH:
			if revealed[y][x] == 0:
				continue
			var tile := map_tiles[y][x]
			var rect := Rect2(Vector2(x, y) * CELL_SIZE, Vector2.ONE * CELL_SIZE)
			_draw_tile(tile, x, y, rect)
			if visible_cells[y][x] == 0:
				dungeon_view.draw_rect(rect, Color(0.02, 0.02, 0.02, 0.72))

	_draw_player()
	_draw_vignette()


func _draw_tile(tile: int, x: int, y: int, rect: Rect2) -> void:
	if tile_sheet == null:
		_draw_fallback_tile(tile, x, y, rect)
		return

	var atlas_coords := Vector2i.ZERO
	match tile:
		TILE_WALL:
			atlas_coords = _wall_atlas(x, y)
		TILE_FLOOR:
			atlas_coords = _pick_variant(FLOOR_VARIANTS, x, y)
		TILE_DOOR_CLOSED:
			atlas_coords = _pick_variant(DOOR_CLOSED_VARIANTS, x, y)
		TILE_DOOR_OPEN:
			atlas_coords = _pick_variant(DOOR_OPEN_VARIANTS, x, y)
		TILE_WATER:
			atlas_coords = _pick_variant(WATER_VARIANTS, x, y)
		TILE_GRASS:
			atlas_coords = _pick_variant(GRASS_VARIANTS, x, y)
		TILE_BARREL:
			atlas_coords = _pick_variant(BARREL_VARIANTS, x, y)
		TILE_CHEST:
			atlas_coords = _pick_variant(CHEST_VARIANTS, x, y)
		_:
			return

	var atlas_origin := Vector2(atlas_coords) * SOURCE_TILE_SIZE
	var source := Rect2(atlas_origin, Vector2.ONE * SOURCE_TILE_SIZE)
	dungeon_view.draw_texture_rect_region(tile_sheet, rect, source)

	if tile == TILE_WALL and _is_floorish(x, y + 1):
		dungeon_view.draw_rect(Rect2(rect.position + Vector2(0, CELL_SIZE - 3), Vector2(CELL_SIZE, 3)), Color(0, 0, 0, 0.35))


func _draw_fallback_tile(tile: int, x: int, y: int, rect: Rect2) -> void:
	match tile:
		TILE_WALL:
			dungeon_view.draw_rect(rect, Color("3b2f2a"))
			dungeon_view.draw_line(rect.position + Vector2(0, 4), rect.position + Vector2(CELL_SIZE, 4), Color("2a201c"), 1.0)
			dungeon_view.draw_line(rect.position + Vector2(0, 10), rect.position + Vector2(CELL_SIZE, 10), Color("2a201c"), 1.0)
		TILE_FLOOR:
			dungeon_view.draw_rect(rect, Color("5a5f58"))
		TILE_DOOR_CLOSED:
			dungeon_view.draw_rect(rect, Color("7a5432"))
		TILE_DOOR_OPEN:
			dungeon_view.draw_rect(rect, Color("6a4a2c"))
		TILE_WATER:
			dungeon_view.draw_rect(rect, Color("1f4766"))
		TILE_GRASS:
			dungeon_view.draw_rect(rect, Color("375b2f"))
		TILE_BARREL:
			dungeon_view.draw_rect(rect, Color("8a6238"))
		TILE_CHEST:
			dungeon_view.draw_rect(rect, Color("9b7a2f"))
		_:
			dungeon_view.draw_rect(rect, Color("1a1a1a"))


func _is_git_lfs_pointer(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var first_line := file.get_line()
	return first_line == "version https://git-lfs.github.com/spec/v1"


func _draw_player() -> void:
	if visible_cells[player_cell.y][player_cell.x] == 0:
		return

	var dst := Rect2(Vector2(player_cell) * CELL_SIZE, Vector2.ONE * CELL_SIZE)
	if hero_sprite != null:
		var src := Rect2(Vector2(0, 0), Vector2.ONE * SOURCE_TILE_SIZE)
		dungeon_view.draw_texture_rect_region(hero_sprite, dst, src)
	else:
		dungeon_view.draw_rect(dst.grow(-3), Color("f0e68c"))


func _draw_vignette() -> void:
	var view_size := Vector2(MAP_WIDTH, MAP_HEIGHT) * CELL_SIZE
	dungeon_view.draw_rect(Rect2(Vector2.ZERO, Vector2(view_size.x, 10)), Color(0, 0, 0, 0.75))
	dungeon_view.draw_rect(Rect2(Vector2(0, view_size.y - 10), Vector2(view_size.x, 10)), Color(0, 0, 0, 0.75))
	dungeon_view.draw_rect(Rect2(Vector2.ZERO, Vector2(10, view_size.y)), Color(0, 0, 0, 0.75))
	dungeon_view.draw_rect(Rect2(Vector2(view_size.x - 10, 0), Vector2(10, view_size.y)), Color(0, 0, 0, 0.75))


func _wall_atlas(x: int, y: int) -> Vector2i:
	var mask := 0
	if _is_wallish(x, y - 1):
		mask |= 1
	if _is_wallish(x + 1, y):
		mask |= 2
	if _is_wallish(x, y + 1):
		mask |= 4
	if _is_wallish(x - 1, y):
		mask |= 8
	return WALL_VARIANTS.get(mask, Vector2i(0, 0))


func _is_wallish(x: int, y: int) -> bool:
	if not _in_bounds(x, y):
		return true
	var tile := map_tiles[y][x]
	return tile == TILE_WALL or tile == TILE_EMPTY


func _is_floorish(x: int, y: int) -> bool:
	if not _in_bounds(x, y):
		return false
	return map_tiles[y][x] in [TILE_FLOOR, TILE_DOOR_CLOSED, TILE_DOOR_OPEN, TILE_WATER, TILE_GRASS]


func _pick_variant(variants: Array, x: int, y: int) -> Vector2i:
	var idx := int(abs((x * 73856093) ^ (y * 19349663))) % variants.size()
	return variants[idx]


func _room_center(room: Rect2i) -> Vector2i:
	return room.position + room.size / 2


func _in_bounds(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < MAP_WIDTH and y < MAP_HEIGHT


func _is_walkable_tile(tile: int) -> bool:
	return tile in [TILE_FLOOR, TILE_DOOR_OPEN, TILE_DOOR_CLOSED, TILE_WATER, TILE_GRASS, TILE_BARREL, TILE_CHEST]


func _update_visibility() -> void:
	for y in MAP_HEIGHT:
		for x in MAP_WIDTH:
			visible_cells[y][x] = 0
	for dy in range(-VISION_RADIUS, VISION_RADIUS + 1):
		for dx in range(-VISION_RADIUS, VISION_RADIUS + 1):
			var cell := player_cell + Vector2i(dx, dy)
			if not _in_bounds(cell.x, cell.y):
				continue
			if Vector2(dx, dy).length() > VISION_RADIUS + 0.25:
				continue
			if not _has_line_of_sight(player_cell, cell):
				continue
			visible_cells[cell.y][cell.x] = 1
			revealed[cell.y][cell.x] = 1


func _has_line_of_sight(from_cell: Vector2i, to_cell: Vector2i) -> bool:
	var x0 := from_cell.x
	var y0 := from_cell.y
	var x1 := to_cell.x
	var y1 := to_cell.y
	var dx := absi(x1 - x0)
	var dy := -absi(y1 - y0)
	var sx := 1 if x0 < x1 else -1
	var sy := 1 if y0 < y1 else -1
	var err := dx + dy

	while true:
		if x0 == x1 and y0 == y1:
			return true
		if Vector2i(x0, y0) != from_cell and map_tiles[y0][x0] == TILE_WALL:
			return false
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy

	return true


func _update_status(text: String) -> void:
	status_label.text = text
