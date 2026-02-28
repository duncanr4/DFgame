extends Control

const TILE_WALL := 0
const TILE_FLOOR := 1
const TILE_DOOR_CLOSED := 2
const TILE_DOOR_OPEN := 3

const MAP_WIDTH := 48
const MAP_HEIGHT := 30
const CELL_SIZE := 24

@onready var dungeon_view: Control = $Layout/Margin/Content/DungeonView
@onready var status_label: Label = $Layout/Margin/Content/HUD/StatusLabel

var rng := RandomNumberGenerator.new()
var map_tiles: Array[PackedInt32Array] = []
var player_cell := Vector2i.ZERO


func _ready() -> void:
	rng.randomize()
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
	for y in MAP_HEIGHT:
		var row := PackedInt32Array()
		row.resize(MAP_WIDTH)
		row.fill(TILE_WALL)
		map_tiles.append(row)

	var rooms: Array[Rect2i] = []
	var room_count := rng.randi_range(10, 16)

	for _i in room_count:
		var size := Vector2i(rng.randi_range(5, 9), rng.randi_range(5, 8))
		var pos := Vector2i(
			rng.randi_range(1, MAP_WIDTH - size.x - 2),
			rng.randi_range(1, MAP_HEIGHT - size.y - 2)
		)
		var candidate := Rect2i(pos, size)
		var overlaps := false
		for room: Rect2i in rooms:
			if room.grow(1).intersects(candidate):
				overlaps = true
				break
		if overlaps:
			continue
		rooms.append(candidate)
		_carve_room(candidate)

	if rooms.size() == 0:
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
	player_cell = _room_center(rooms[0])
	dungeon_view.queue_redraw()


func _carve_room(room: Rect2i) -> void:
	for y in range(room.position.y, room.end.y):
		for x in range(room.position.x, room.end.x):
			map_tiles[y][x] = TILE_FLOOR


func _carve_h_tunnel(x1: int, x2: int, y: int) -> void:
	for x in range(mini(x1, x2), maxi(x1, x2) + 1):
		map_tiles[y][x] = TILE_FLOOR


func _carve_v_tunnel(y1: int, y2: int, x: int) -> void:
	for y in range(mini(y1, y2), maxi(y1, y2) + 1):
		map_tiles[y][x] = TILE_FLOOR


func _place_doors() -> void:
	for y in range(1, MAP_HEIGHT - 1):
		for x in range(1, MAP_WIDTH - 1):
			if map_tiles[y][x] != TILE_FLOOR:
				continue
			var left_floor := map_tiles[y][x - 1] == TILE_FLOOR
			var right_floor := map_tiles[y][x + 1] == TILE_FLOOR
			var up_floor := map_tiles[y - 1][x] == TILE_FLOOR
			var down_floor := map_tiles[y + 1][x] == TILE_FLOOR
			var vertical_door := up_floor and down_floor and not left_floor and not right_floor
			var horizontal_door := left_floor and right_floor and not up_floor and not down_floor
			if (vertical_door or horizontal_door) and rng.randf() < 0.22:
				map_tiles[y][x] = TILE_DOOR_CLOSED


func _on_dungeon_view_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
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
	if target.x < 0 or target.y < 0 or target.x >= MAP_WIDTH or target.y >= MAP_HEIGHT:
		return

	var tile := map_tiles[target.y][target.x]
	if tile == TILE_WALL:
		_update_status("You bump into the dungeon wall.")
		return
	if tile == TILE_DOOR_CLOSED:
		map_tiles[target.y][target.x] = TILE_DOOR_OPEN
		_update_status("You open the door and step through.")
	else:
		_update_status("You move silently through the corridor.")

	player_cell = target
	dungeon_view.queue_redraw()


func _on_dungeon_view_draw() -> void:
	for y in MAP_HEIGHT:
		for x in MAP_WIDTH:
			var tile := map_tiles[y][x]
			var color := Color("1a1d26")
			match tile:
				TILE_FLOOR:
					color = Color("3a4354")
				TILE_DOOR_CLOSED:
					color = Color("8c6a44")
				TILE_DOOR_OPEN:
					color = Color("5f8f63")
				_:
					color = Color("0b0d13")
			var rect := Rect2(Vector2(x, y) * CELL_SIZE, Vector2.ONE * CELL_SIZE)
			dungeon_view.draw_rect(rect, color)
			dungeon_view.draw_rect(rect, Color(0, 0, 0, 0.2), false, 1.0)

	var player_rect := Rect2(Vector2(player_cell) * CELL_SIZE + Vector2(4, 4), Vector2.ONE * (CELL_SIZE - 8))
	dungeon_view.draw_rect(player_rect, Color("f0e68c"))


func _room_center(room: Rect2i) -> Vector2i:
	return room.position + room.size / 2


func _update_status(text: String) -> void:
	status_label.text = text
