extends Node2D

const MAP_WIDTH: int = 41
const MAP_HEIGHT: int = 25
const TILE_SIZE: int = 16

const TERRAIN_EMPTY: int = 1
const TERRAIN_GRASS: int = 2
const TERRAIN_WALL: int = 4
const TERRAIN_DOOR: int = 5
const TERRAIN_OPEN_DOOR: int = 6
const TERRAIN_ENTRANCE: int = 7
const TERRAIN_EXIT: int = 8
const TERRAIN_HIGH_GRASS: int = 15
const TERRAIN_WALL_DECO: int = 12

const ENEMY_COUNT: int = 8
const POTION_COUNT: int = 5
const PLAYER_HP_MAX: int = 12
const POTION_HEAL: int = 4
const FOV_RADIUS: int = 8
const ROOM_ATTEMPTS: int = 64
const ROOM_TARGET_MIN: int = 8
const ROOM_TARGET_MAX: int = 12

const TILESET_TEXTURE_PATH: String = "res://Github Game/pixel-dungeon-master/pixel-dungeon-master/assets/tiles0.png"
const PLAYER_TEXTURE_PATH: String = "res://Github Game/pixel-dungeon-master/pixel-dungeon-master/assets/warrior.png"
const ENEMY_TEXTURE_PATH: String = "res://Github Game/pixel-dungeon-master/pixel-dungeon-master/assets/rat.png"
const ITEMS_TEXTURE_PATH: String = "res://Github Game/pixel-dungeon-master/pixel-dungeon-master/assets/items.png"

@onready var dungeon_layer: TileMapLayer = $DungeonLayer
@onready var status_label: Label = $CanvasLayer/UI/MarginContainer/VBoxContainer/StatusLabel
@onready var help_label: Label = $CanvasLayer/UI/MarginContainer/VBoxContainer/HelpLabel

var map_data: Array[int] = []
var explored_data: Array[bool] = []
var visible_cells: Dictionary = {}
var room_rects: Array[Rect2i] = []

var player_cell: Vector2i = Vector2i.ZERO
var entrance_cell: Vector2i = Vector2i.ZERO
var exit_cell: Vector2i = Vector2i.ZERO
var enemy_cells: Array[Vector2i] = []
var potion_cells: Array[Vector2i] = []
var occupied: Dictionary = {}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var player_hp: int = PLAYER_HP_MAX
var pending_message: String = ""
var atlas_source_id: int = -1
var atlas_columns: int = 1
var player_texture: Texture2D
var enemy_texture: Texture2D
var items_texture: Texture2D
var missing_texture_warning: String = ""


func _ready() -> void:
	rng.randomize()
	_configure_tileset()
	_load_actor_and_item_textures()
	if not missing_texture_warning.is_empty():
		push_warning(missing_texture_warning)
	restart_run()


func _draw() -> void:
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			var cell := Vector2i(x, y)
			var rect := Rect2(cell * TILE_SIZE, Vector2(TILE_SIZE, TILE_SIZE))
			if not _is_explored(cell):
				draw_rect(rect, Color(0, 0, 0, 1.0), true)
			elif not _is_visible(cell):
				draw_rect(rect, Color(0, 0, 0, 0.62), true)

	for potion in potion_cells:
		if _is_visible(potion):
			draw_item(potion)

	if _is_visible(player_cell):
		draw_actor(player_cell, player_texture, Rect2(Vector2.ZERO, Vector2(TILE_SIZE, TILE_SIZE)), Color(1, 1, 1, 1), Color(0.33, 0.83, 1.0), "@")

	for enemy in enemy_cells:
		if _is_visible(enemy):
			draw_actor(enemy, enemy_texture, Rect2(Vector2.ZERO, Vector2(TILE_SIZE, TILE_SIZE)), Color(1, 1, 1, 1), Color(1.0, 0.36, 0.36), "r")


func draw_actor(cell: Vector2i, texture: Texture2D, region: Rect2, tint: Color, fallback_color: Color, glyph: String) -> void:
	var tile_position := Vector2(cell * TILE_SIZE)
	if texture != null:
		draw_texture_rect_region(texture, Rect2(tile_position, Vector2(TILE_SIZE, TILE_SIZE)), region, tint)
		return
	var center := tile_position + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
	draw_circle(center, 5.0, fallback_color)
	draw_string(ThemeDB.fallback_font, center + Vector2(-4, 4), glyph, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, Color(0, 0, 0))


func draw_item(cell: Vector2i) -> void:
	var tile_position := Vector2(cell * TILE_SIZE)
	if items_texture != null:
		draw_texture_rect_region(items_texture, Rect2(tile_position, Vector2(TILE_SIZE, TILE_SIZE)), Rect2(Vector2(0, 16), Vector2(TILE_SIZE, TILE_SIZE)), Color(1, 1, 1, 1))
		return
	var center := tile_position + Vector2(TILE_SIZE / 2, TILE_SIZE / 2)
	draw_circle(center, 4.5, Color(0.42, 1.0, 0.52))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and (player_hp <= 0 or player_cell == exit_cell):
		restart_run()
		return

	if player_hp <= 0 or player_cell == exit_cell:
		return

	var direction: Vector2i = Vector2i.ZERO
	if event.is_action_pressed("ui_left"):
		direction = Vector2i.LEFT
	elif event.is_action_pressed("ui_right"):
		direction = Vector2i.RIGHT
	elif event.is_action_pressed("ui_up"):
		direction = Vector2i.UP
	elif event.is_action_pressed("ui_down"):
		direction = Vector2i.DOWN

	if direction != Vector2i.ZERO:
		take_turn(direction)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


func restart_run() -> void:
	generate_dungeon()
	spawn_player_and_enemies()
	_compute_visibility()
	_render_tilemap()
	update_status("Explore, fight, and find the stairs down.")
	queue_redraw()


func generate_dungeon() -> void:
	map_data.clear()
	map_data.resize(MAP_WIDTH * MAP_HEIGHT)
	explored_data.clear()
	explored_data.resize(MAP_WIDTH * MAP_HEIGHT)
	room_rects.clear()
	for index in range(map_data.size()):
		map_data[index] = TERRAIN_WALL
		explored_data[index] = false

	for y in range(1, MAP_HEIGHT - 1):
		for x in range(1, MAP_WIDTH - 1):
			if rng.randf() < 0.06:
				set_tile(x, y, TERRAIN_WALL_DECO)

	for _attempt in range(ROOM_ATTEMPTS):
		if room_rects.size() >= rng.randi_range(ROOM_TARGET_MIN, ROOM_TARGET_MAX):
			break
		var room_size := Vector2i(rng.randi_range(4, 8), rng.randi_range(4, 7))
		var room_pos := Vector2i(
			rng.randi_range(1, MAP_WIDTH - room_size.x - 2),
			rng.randi_range(1, MAP_HEIGHT - room_size.y - 2)
		)
		var room := Rect2i(room_pos, room_size)
		if _room_overlaps_existing(room.grow(1)):
			continue
		_carve_room(room)
		if not room_rects.is_empty():
			var prev_center := _room_center(room_rects.back())
			var current_center := _room_center(room)
			_carve_corridor(prev_center, current_center)
		room_rects.append(room)

	if room_rects.size() < 2:
		var fallback_room := Rect2i(Vector2i(5, 5), Vector2i(10, 8))
		var fallback_room_b := Rect2i(Vector2i(21, 11), Vector2i(11, 8))
		room_rects = [fallback_room, fallback_room_b]
		_carve_room(fallback_room)
		_carve_room(fallback_room_b)
		_carve_corridor(_room_center(fallback_room), _room_center(fallback_room_b))

	entrance_cell = _room_center(room_rects.front())
	exit_cell = _room_center(room_rects.back())
	set_tile(entrance_cell.x, entrance_cell.y, TERRAIN_ENTRANCE)
	set_tile(exit_cell.x, exit_cell.y, TERRAIN_EXIT)

	for y in range(1, MAP_HEIGHT - 1):
		for x in range(1, MAP_WIDTH - 1):
			if get_tile(x, y) == TERRAIN_EMPTY and rng.randf() < 0.10:
				set_tile(x, y, TERRAIN_GRASS if rng.randf() < 0.65 else TERRAIN_HIGH_GRASS)


func spawn_player_and_enemies() -> void:
	enemy_cells.clear()
	potion_cells.clear()
	occupied.clear()
	player_hp = PLAYER_HP_MAX
	pending_message = ""
	player_cell = entrance_cell
	occupied[player_cell] = true

	for _enemy_index in range(ENEMY_COUNT):
		var enemy_cell: Vector2i = random_floor_cell()
		while occupied.has(enemy_cell) or enemy_cell == exit_cell:
			enemy_cell = random_floor_cell()
		enemy_cells.append(enemy_cell)
		occupied[enemy_cell] = true

	for _potion_index in range(POTION_COUNT):
		var potion_cell: Vector2i = random_floor_cell()
		while occupied.has(potion_cell) or potion_cell == exit_cell or potion_cells.has(potion_cell):
			potion_cell = random_floor_cell()
		potion_cells.append(potion_cell)


func take_turn(direction: Vector2i) -> void:
	pending_message = ""
	var target: Vector2i = player_cell + direction
	if not _is_walkable(target):
		if get_tile(target.x, target.y) == TERRAIN_DOOR:
			set_tile(target.x, target.y, TERRAIN_OPEN_DOOR)
			pending_message = "You open the door."
			_render_tilemap()
		else:
			update_status("You bump into a wall.")
		return

	var enemy_index: int = enemy_cells.find(target)
	if enemy_index >= 0:
		enemy_cells.remove_at(enemy_index)
		occupied.erase(target)
		pending_message = "You strike down a sewer rat."
	else:
		occupied.erase(player_cell)
		player_cell = target
		occupied[player_cell] = true
		if potion_cells.has(player_cell):
			potion_cells.erase(player_cell)
			player_hp = mini(PLAYER_HP_MAX, player_hp + POTION_HEAL)
			pending_message = "You quaff a potion and recover %d HP." % POTION_HEAL

	move_enemies()
	_compute_visibility()
	queue_redraw()

	if player_hp <= 0:
		update_status("You were defeated. Press Enter to try again.")
	elif player_cell == exit_cell:
		update_status("You descend deeper. Press Enter for a fresh floor.")
	elif enemy_cells.is_empty():
		update_status("The floor is clear. Find the stairs.")
	elif pending_message.is_empty():
		update_status("You move cautiously...")
	else:
		update_status(pending_message)


func move_enemies() -> void:
	var next_enemy_cells: Array[Vector2i] = []
	occupied.clear()
	occupied[player_cell] = true

	for enemy in enemy_cells:
		var candidate: Vector2i = choose_enemy_step(enemy)
		if candidate == player_cell:
			player_hp -= 1
			pending_message = "A rat bites you for 1 damage."
			next_enemy_cells.append(enemy)
			occupied[enemy] = true
		elif occupied.has(candidate) or not _is_walkable(candidate):
			next_enemy_cells.append(enemy)
			occupied[enemy] = true
		else:
			next_enemy_cells.append(candidate)
			occupied[candidate] = true

	enemy_cells = next_enemy_cells


func choose_enemy_step(enemy: Vector2i) -> Vector2i:
	if enemy.distance_to(player_cell) > float(FOV_RADIUS + 2):
		return enemy
	var delta: Vector2i = player_cell - enemy
	var x_step: Vector2i = Vector2i(signi(delta.x), 0)
	var y_step: Vector2i = Vector2i(0, signi(delta.y))

	var options: Array[Vector2i] = []
	if abs(delta.x) > abs(delta.y):
		options = [enemy + x_step, enemy + y_step]
	else:
		options = [enemy + y_step, enemy + x_step]
	options.append(enemy)

	for option in options:
		if option == player_cell:
			return option
		if _is_walkable(option) and not occupied.has(option):
			return option
	return enemy


func random_floor_cell() -> Vector2i:
	while true:
		var x: int = rng.randi_range(1, MAP_WIDTH - 2)
		var y: int = rng.randi_range(1, MAP_HEIGHT - 2)
		var cell := Vector2i(x, y)
		if _is_walkable(cell) and cell != entrance_cell:
			return cell
	return Vector2i.ZERO


func set_tile(x: int, y: int, value: int) -> void:
	map_data[y * MAP_WIDTH + x] = value


func get_tile(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= MAP_WIDTH or y >= MAP_HEIGHT:
		return TERRAIN_WALL
	return map_data[y * MAP_WIDTH + x]


func update_status(message: String) -> void:
	status_label.text = "HP: %d/%d    Rats: %d    Potions: %d\n%s" % [player_hp, PLAYER_HP_MAX, enemy_cells.size(), potion_cells.size(), message]
	help_label.text = "Arrow keys: move/attack • Enter: next floor after death/exit • Esc: back"
	if not missing_texture_warning.is_empty():
		help_label.text += "\n" + missing_texture_warning


func _is_walkable(cell: Vector2i) -> bool:
	var tile: int = get_tile(cell.x, cell.y)
	return tile in [TERRAIN_EMPTY, TERRAIN_GRASS, TERRAIN_HIGH_GRASS, TERRAIN_OPEN_DOOR, TERRAIN_ENTRANCE, TERRAIN_EXIT]


func _room_overlaps_existing(room: Rect2i) -> bool:
	for existing in room_rects:
		if existing.intersects(room):
			return true
	return false


func _carve_room(room: Rect2i) -> void:
	for y in range(room.position.y, room.end.y):
		for x in range(room.position.x, room.end.x):
			set_tile(x, y, TERRAIN_EMPTY)


func _carve_corridor(from_cell: Vector2i, to_cell: Vector2i) -> void:
	var current := from_cell
	if rng.randi_range(0, 1) == 0:
		while current.x != to_cell.x:
			current.x += signi(to_cell.x - current.x)
			_carve_corridor_cell(current)
		while current.y != to_cell.y:
			current.y += signi(to_cell.y - current.y)
			_carve_corridor_cell(current)
	else:
		while current.y != to_cell.y:
			current.y += signi(to_cell.y - current.y)
			_carve_corridor_cell(current)
		while current.x != to_cell.x:
			current.x += signi(to_cell.x - current.x)
			_carve_corridor_cell(current)


func _carve_corridor_cell(cell: Vector2i) -> void:
	if get_tile(cell.x, cell.y) == TERRAIN_WALL or get_tile(cell.x, cell.y) == TERRAIN_WALL_DECO:
		set_tile(cell.x, cell.y, TERRAIN_EMPTY)
	if rng.randf() < 0.06:
		var corridor_offsets: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
		for offset: Vector2i in corridor_offsets:
			var neighbor: Vector2i = cell + offset
			if get_tile(neighbor.x, neighbor.y) == TERRAIN_WALL and _touches_floor_on_other_side(neighbor, offset):
				set_tile(neighbor.x, neighbor.y, TERRAIN_DOOR)


func _touches_floor_on_other_side(cell: Vector2i, toward_floor_dir: Vector2i) -> bool:
	var opposite := cell - toward_floor_dir
	return _is_walkable(cell + toward_floor_dir) and _is_walkable(opposite)


func _room_center(room: Rect2i) -> Vector2i:
	return Vector2i(room.position.x + room.size.x / 2, room.position.y + room.size.y / 2)


func _configure_tileset() -> void:
	var texture := load(TILESET_TEXTURE_PATH) as Texture2D
	if texture == null:
		push_error("Pixel Dungeon tileset texture could not be loaded: %s" % TILESET_TEXTURE_PATH)
		return

	atlas_columns = maxi(1, int(texture.get_width()) / TILE_SIZE)

	var tileset := TileSet.new()
	var atlas := TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)

	atlas_source_id = tileset.get_next_source_id()
	tileset.add_source(atlas, atlas_source_id)

	var atlas_rows := maxi(1, int(texture.get_height()) / TILE_SIZE)
	for y in range(atlas_rows):
		for x in range(atlas_columns):
			atlas.create_tile(Vector2i(x, y))

	dungeon_layer.tile_set = tileset


func _load_actor_and_item_textures() -> void:
	player_texture = load(PLAYER_TEXTURE_PATH) as Texture2D
	enemy_texture = load(ENEMY_TEXTURE_PATH) as Texture2D
	items_texture = load(ITEMS_TEXTURE_PATH) as Texture2D
	if player_texture == null or enemy_texture == null or items_texture == null:
		missing_texture_warning = "Sprite textures failed to load. Run 'git lfs install && git lfs pull' to fetch Pixel Dungeon assets."


func _render_tilemap() -> void:
	dungeon_layer.clear()
	if atlas_source_id < 0:
		return
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			var terrain_id := get_tile(x, y)
			dungeon_layer.set_cell(Vector2i(x, y), atlas_source_id, _atlas_coords_for_terrain(terrain_id), 0)


func _atlas_coords_for_terrain(terrain_id: int) -> Vector2i:
	return Vector2i(terrain_id % atlas_columns, terrain_id / atlas_columns)


func _compute_visibility() -> void:
	visible_cells.clear()
	visible_cells[player_cell] = true
	_set_explored(player_cell, true)

	for tx in range(player_cell.x - FOV_RADIUS, player_cell.x + FOV_RADIUS + 1):
		for ty in range(player_cell.y - FOV_RADIUS, player_cell.y + FOV_RADIUS + 1):
			var target := Vector2i(tx, ty)
			if not _is_in_bounds(target):
				continue
			if player_cell.distance_to(target) > float(FOV_RADIUS):
				continue
			_cast_visibility_ray(player_cell, target)


func _cast_visibility_ray(from_cell: Vector2i, to_cell: Vector2i) -> void:
	for cell in _line_cells(from_cell, to_cell):
		if not _is_in_bounds(cell):
			return
		visible_cells[cell] = true
		_set_explored(cell, true)
		if _blocks_sight(cell) and cell != from_cell:
			return


func _line_cells(start: Vector2i, finish: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	var x0 := start.x
	var y0 := start.y
	var x1 := finish.x
	var y1 := finish.y
	var dx := absi(x1 - x0)
	var dy := -absi(y1 - y0)
	var sx := 1 if x0 < x1 else -1
	var sy := 1 if y0 < y1 else -1
	var err := dx + dy

	while true:
		points.append(Vector2i(x0, y0))
		if x0 == x1 and y0 == y1:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy
	return points


func _blocks_sight(cell: Vector2i) -> bool:
	var tile := get_tile(cell.x, cell.y)
	return tile in [TERRAIN_WALL, TERRAIN_WALL_DECO, TERRAIN_DOOR]


func _is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < MAP_WIDTH and cell.y < MAP_HEIGHT


func _is_visible(cell: Vector2i) -> bool:
	return visible_cells.has(cell)


func _set_explored(cell: Vector2i, explored: bool) -> void:
	explored_data[cell.y * MAP_WIDTH + cell.x] = explored


func _is_explored(cell: Vector2i) -> bool:
	return explored_data[cell.y * MAP_WIDTH + cell.x]
