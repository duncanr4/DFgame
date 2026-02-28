extends Control

const TILE_WALL := 0
const TILE_FLOOR := 1
const TILE_DOOR_CLOSED := 2
const TILE_DOOR_OPEN := 3
const TILE_WATER := 4
const TILE_GRASS := 5
const TILE_EMPTY := 6
const TILE_BARREL := 7
const TILE_CHEST := 8

const MAP_WIDTH := 34
const MAP_HEIGHT := 24
const CELL_SIZE := 16
const SOURCE_TILE_SIZE := 16
const VISION_RADIUS := 6

const TILE_SHEET_PATH := "res://resources/images/shattered_ui/tiles_sewers.png"
const HERO_SPRITE_PATH := "res://resources/images/shattered_ui/warrior.png"

# SPD-like tile buckets from the sewers sheet.
const FLOOR_VARIANTS := [
	Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(1, 1), Vector2i(2, 1)
]
const WALL_VARIANTS := {
	0: Vector2i(0, 0),
	1: Vector2i(4, 0),
	2: Vector2i(5, 0),
	3: Vector2i(6, 0),
	4: Vector2i(7, 0),
	5: Vector2i(8, 0),
	6: Vector2i(9, 0),
	7: Vector2i(10, 0),
	8: Vector2i(11, 0),
	9: Vector2i(12, 0),
	10: Vector2i(13, 0),
	11: Vector2i(14, 0),
	12: Vector2i(15, 0),
	13: Vector2i(0, 1),
	14: Vector2i(3, 1),
	15: Vector2i(4, 1)
}
const DOOR_CLOSED_VARIANTS := [Vector2i(6, 1), Vector2i(6, 2)]
const DOOR_OPEN_VARIANTS := [Vector2i(7, 1), Vector2i(7, 2)]
const WATER_VARIANTS := [
	Vector2i(8, 1), Vector2i(9, 1), Vector2i(10, 1), Vector2i(11, 1), Vector2i(12, 1)
]
const GRASS_VARIANTS := [
	Vector2i(13, 1), Vector2i(14, 1), Vector2i(15, 1), Vector2i(0, 2), Vector2i(1, 2)
]
const BARREL_VARIANTS := [Vector2i(2, 2), Vector2i(3, 2)]
const CHEST_VARIANTS := [Vector2i(4, 2), Vector2i(5, 2)]

@onready var dungeon_view: Control = $Layout/Margin/Content/DungeonView
@onready var status_label: Label = $Layout/Margin/Content/HUD/StatusLabel

var rng := RandomNumberGenerator.new()
var tile_sheet: Texture2D
var hero_sprite: Texture2D
var map_tiles: Array[PackedInt32Array] = []
var revealed: Array[PackedByteArray] = []
var visible: Array[PackedByteArray] = []
var player_cell := Vector2i.ZERO


func _ready() -> void:
	rng.randomize()
	tile_sheet = load(TILE_SHEET_PATH) as Texture2D
	hero_sprite = load(HERO_SPRITE_PATH) as Texture2D
	_generate_dungeon()
	dungeon_view.draw.connect(_on_dungeon_view_draw)
	dungeon_view.gui_input.connect(_on_dungeon_view_gui_input)
	_update_status("Dungeon generated. Use WASD / arrows to move.")
	dungeon_view.queue_redraw()


func _on_regenerate_button_pressed() -> void:
	_generate_dungeon()
	_update_status("A new dungeon forms from the shadows.")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


func _generate_dungeon() -> void:
	map_tiles.clear()
	revealed.clear()
	visible.clear()

	for y in MAP_HEIGHT:
		var tile_row := PackedInt32Array()
		var seen_row := PackedByteArray()
		var vis_row := PackedByteArray()
		tile_row.resize(MAP_WIDTH)
		seen_row.resize(MAP_WIDTH)
		vis_row.resize(MAP_WIDTH)
		tile_row.fill(TILE_WALL)
		seen_row.fill(0)
		vis_row.fill(0)
		map_tiles.append(tile_row)
		revealed.append(seen_row)
		visible.append(vis_row)

	var rooms: Array[Rect2i] = []
	for _attempt in 80:
		var room_size := Vector2i(rng.randi_range(4, 9), rng.randi_range(4, 8))
		var pos := Vector2i(
			rng.randi_range(1, MAP_WIDTH - room_size.x - 2),
			rng.randi_range(1, MAP_HEIGHT - room_size.y - 2)
		)
		var candidate := Rect2i(pos, room_size)
		var overlaps := false
		for room: Rect2i in rooms:
			if room.grow(1).intersects(candidate):
				overlaps = true
				break
		if overlaps:
			continue
		rooms.append(candidate)
		_carve_room(candidate)
		if rooms.size() >= 14:
			break

	if rooms.is_empty():
		_generate_dungeon()
		return

	rooms.sort_custom(func(a: Rect2i, b: Rect2i) -> bool: return a.position.x < b.position.x)
	for i in rooms.size() - 1:
		var from_center := _room_center(rooms[i])
		var to_center := _room_center(rooms[i + 1])
		if rng.randf() < 0.5:
			_carve_h_tunnel(from_center.x, to_center.x, from_center.y)
			_carve_v_tunnel(from_center.y, to_center.y, to_center.x)
		else:
			_carve_v_tunnel(from_center.y, to_center.y, from_center.x)
			_carve_h_tunnel(from_center.x, to_center.x, to_center.y)

	_place_doors()
	_place_terrain_features(rooms)
	_place_decor(rooms)
	player_cell = _room_center(rooms[0])
	_update_visibility()
	dungeon_view.queue_redraw()


func _carve_room(room: Rect2i) -> void:
	for y in range(room.position.y, room.end.y):
		for x in range(room.position.x, room.end.x):
			map_tiles[y][x] = TILE_FLOOR


func _carve_h_tunnel(x1: int, x2: int, y: int) -> void:
	for x in range(mini(x1, x2), maxi(x1, x2) + 1):
		if _in_bounds(x, y):
			map_tiles[y][x] = TILE_FLOOR


func _carve_v_tunnel(y1: int, y2: int, x: int) -> void:
	for y in range(mini(y1, y2), maxi(y1, y2) + 1):
		if _in_bounds(x, y):
			map_tiles[y][x] = TILE_FLOOR


func _place_doors() -> void:
	for y in range(1, MAP_HEIGHT - 1):
		for x in range(1, MAP_WIDTH - 1):
			if map_tiles[y][x] != TILE_FLOOR:
				continue
			var left_floor := _is_walkable_tile(map_tiles[y][x - 1])
			var right_floor := _is_walkable_tile(map_tiles[y][x + 1])
			var up_floor := _is_walkable_tile(map_tiles[y - 1][x])
			var down_floor := _is_walkable_tile(map_tiles[y + 1][x])
			var vertical_door := up_floor and down_floor and not left_floor and not right_floor
			var horizontal_door := left_floor and right_floor and not up_floor and not down_floor
			if (vertical_door or horizontal_door) and rng.randf() < 0.2:
				map_tiles[y][x] = TILE_DOOR_CLOSED


func _place_terrain_features(rooms: Array[Rect2i]) -> void:
	for room: Rect2i in rooms:
		if rng.randf() < 0.5:
			_place_patch(room, TILE_WATER, rng.randi_range(3, 7))
		if rng.randf() < 0.7:
			_place_patch(room, TILE_GRASS, rng.randi_range(4, 10))


func _place_patch(room: Rect2i, tile_type: int, attempts: int) -> void:
	if room.size.x <= 2 or room.size.y <= 2:
		return
	var seed := Vector2i(
		rng.randi_range(room.position.x + 1, room.end.x - 2),
		rng.randi_range(room.position.y + 1, room.end.y - 2)
	)
	for _i in attempts:
		var pos := seed + Vector2i(rng.randi_range(-2, 2), rng.randi_range(-2, 2))
		if not _in_bounds(pos.x, pos.y):
			continue
		if map_tiles[pos.y][pos.x] == TILE_FLOOR and rng.randf() < 0.8:
			map_tiles[pos.y][pos.x] = tile_type


func _place_decor(rooms: Array[Rect2i]) -> void:
	for room: Rect2i in rooms:
		for _i in rng.randi_range(0, 3):
			var x := rng.randi_range(room.position.x + 1, room.end.x - 2)
			var y := rng.randi_range(room.position.y + 1, room.end.y - 2)
			if map_tiles[y][x] != TILE_FLOOR:
				continue
			map_tiles[y][x] = TILE_BARREL if rng.randf() < 0.8 else TILE_CHEST


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
		_update_status("You bump into the dungeon wall.")
		return
	if tile == TILE_DOOR_CLOSED:
		map_tiles[target.y][target.x] = TILE_DOOR_OPEN
		_update_status("You open the door and step through.")
	elif tile == TILE_WATER:
		_update_status("Water ripples beneath your boots.")
	else:
		_update_status("You move silently through the corridor.")

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
			if visible[y][x] == 0:
				dungeon_view.draw_rect(rect, Color(0, 0, 0, 0.6))

	_draw_player()
	_draw_vignette()


func _draw_tile(tile: int, x: int, y: int, rect: Rect2) -> void:
	if tile_sheet == null:
		dungeon_view.draw_rect(rect, Color("2a2a2a"))
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
			atlas_coords = Vector2i(0, 0)

	var atlas_origin := Vector2(atlas_coords) * SOURCE_TILE_SIZE
	var source := Rect2(atlas_origin, Vector2.ONE * SOURCE_TILE_SIZE)
	dungeon_view.draw_texture_rect_region(tile_sheet, rect, source)


func _draw_player() -> void:
	if visible[player_cell.y][player_cell.x] == 0:
		return

	var dst := Rect2(Vector2(player_cell) * CELL_SIZE, Vector2.ONE * CELL_SIZE)
	if hero_sprite != null:
		var src := Rect2(Vector2(0, 0), Vector2.ONE * SOURCE_TILE_SIZE)
		dungeon_view.draw_texture_rect_region(hero_sprite, dst, src)
	else:
		dungeon_view.draw_rect(dst.grow(-3), Color("f0e68c"))


func _draw_vignette() -> void:
	var view_size := Vector2(MAP_WIDTH, MAP_HEIGHT) * CELL_SIZE
	dungeon_view.draw_rect(Rect2(Vector2.ZERO, Vector2(view_size.x, 8)), Color(0, 0, 0, 0.7))
	dungeon_view.draw_rect(Rect2(Vector2(0, view_size.y - 8), Vector2(view_size.x, 8)), Color(0, 0, 0, 0.7))
	dungeon_view.draw_rect(Rect2(Vector2.ZERO, Vector2(8, view_size.y)), Color(0, 0, 0, 0.7))
	dungeon_view.draw_rect(Rect2(Vector2(view_size.x - 8, 0), Vector2(8, view_size.y)), Color(0, 0, 0, 0.7))


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
			visible[y][x] = 0
	for dy in range(-VISION_RADIUS, VISION_RADIUS + 1):
		for dx in range(-VISION_RADIUS, VISION_RADIUS + 1):
			var cell := player_cell + Vector2i(dx, dy)
			if not _in_bounds(cell.x, cell.y):
				continue
			if Vector2(dx, dy).length() > VISION_RADIUS + 0.25:
				continue
			visible[cell.y][cell.x] = 1
			revealed[cell.y][cell.x] = 1


func _update_status(text: String) -> void:
	status_label.text = text
