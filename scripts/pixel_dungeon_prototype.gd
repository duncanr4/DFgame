extends Node2D

const MAP_WIDTH: int = 41
const MAP_HEIGHT: int = 25
const CELL_SIZE: int = 24
const FLOOR_TILE: int = 0
const WALL_TILE: int = 1
const ENEMY_COUNT: int = 6
const PLAYER_HP_MAX: int = 10

@onready var status_label: Label = $CanvasLayer/UI/MarginContainer/VBoxContainer/StatusLabel
@onready var help_label: Label = $CanvasLayer/UI/MarginContainer/VBoxContainer/HelpLabel

var map_data: Array[int] = []
var player_cell: Vector2i
var enemy_cells: Array[Vector2i] = []
var occupied: Dictionary = {}
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var player_hp: int = PLAYER_HP_MAX
var pending_message: String = ""


func _ready() -> void:
	rng.randomize()
	generate_dungeon()
	spawn_player_and_enemies()
	update_status("Welcome to the prototype. Find and defeat all enemies.")
	queue_redraw()


func _draw() -> void:
	for y in range(MAP_HEIGHT):
		for x in range(MAP_WIDTH):
			var tile_rect: Rect2 = Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
			if get_tile(x, y) == WALL_TILE:
				draw_rect(tile_rect, Color(0.12, 0.13, 0.15))
			else:
				draw_rect(tile_rect, Color(0.30, 0.30, 0.34))
			draw_rect(tile_rect, Color(0, 0, 0, 0.20), false, 1.0)

	draw_actor(player_cell, Color(0.2, 0.75, 1.0))
	for enemy in enemy_cells:
		draw_actor(enemy, Color(0.9, 0.25, 0.25))


func draw_actor(cell: Vector2i, color: Color) -> void:
	var pad: float = 4.0
	var rect := Rect2(cell.x * CELL_SIZE + pad, cell.y * CELL_SIZE + pad, CELL_SIZE - pad * 2.0, CELL_SIZE - pad * 2.0)
	draw_rect(rect, color)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and (player_hp <= 0 or enemy_cells.is_empty()):
		restart_run()
		return

	if player_hp <= 0 or enemy_cells.is_empty():
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


func generate_dungeon() -> void:
	map_data.clear()
	map_data.resize(MAP_WIDTH * MAP_HEIGHT)
	for index in range(map_data.size()):
		map_data[index] = WALL_TILE

	var digger: Vector2i = Vector2i(MAP_WIDTH / 2, MAP_HEIGHT / 2)
	for _step in range(1000):
		set_tile(digger.x, digger.y, FLOOR_TILE)
		var dir: Vector2i = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN][rng.randi_range(0, 3)]
		digger = Vector2i(
			clampi(digger.x + dir.x, 1, MAP_WIDTH - 2),
			clampi(digger.y + dir.y, 1, MAP_HEIGHT - 2)
		)


func spawn_player_and_enemies() -> void:
	enemy_cells.clear()
	occupied.clear()
	player_hp = PLAYER_HP_MAX
	player_cell = random_floor_cell()
	occupied[player_cell] = true

	for _enemy_index in range(ENEMY_COUNT):
		var enemy_cell: Vector2i = random_floor_cell()
		while occupied.has(enemy_cell):
			enemy_cell = random_floor_cell()
		enemy_cells.append(enemy_cell)
		occupied[enemy_cell] = true


func take_turn(direction: Vector2i) -> void:
	pending_message = ""
	var target: Vector2i = player_cell + direction
	if get_tile(target.x, target.y) == WALL_TILE:
		update_status("You bump into a wall.")
		return

	var enemy_index: int = enemy_cells.find(target)
	if enemy_index >= 0:
		enemy_cells.remove_at(enemy_index)
		occupied.erase(target)
		pending_message = "You strike down an enemy."
	else:
		occupied.erase(player_cell)
		player_cell = target
		occupied[player_cell] = true

	move_enemies()
	queue_redraw()
	if enemy_cells.is_empty():
		update_status("Dungeon cleared! Press Enter to generate a new run.")
	elif player_hp <= 0:
		update_status("You were defeated. Press Enter to try again.")
	elif pending_message.is_empty():
		update_status("Enemies advance...")
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
			pending_message = "An enemy hits you for 1 damage."
			next_enemy_cells.append(enemy)
			occupied[enemy] = true
		elif occupied.has(candidate) or get_tile(candidate.x, candidate.y) == WALL_TILE:
			next_enemy_cells.append(enemy)
			occupied[enemy] = true
		else:
			next_enemy_cells.append(candidate)
			occupied[candidate] = true

	enemy_cells = next_enemy_cells


func choose_enemy_step(enemy: Vector2i) -> Vector2i:
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
		if get_tile(option.x, option.y) == FLOOR_TILE and not occupied.has(option):
			return option
	return enemy


func random_floor_cell() -> Vector2i:
	while true:
		var x: int = rng.randi_range(1, MAP_WIDTH - 2)
		var y: int = rng.randi_range(1, MAP_HEIGHT - 2)
		if get_tile(x, y) == FLOOR_TILE:
			return Vector2i(x, y)
	return Vector2i.ZERO


func set_tile(x: int, y: int, value: int) -> void:
	map_data[y * MAP_WIDTH + x] = value


func get_tile(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= MAP_WIDTH or y >= MAP_HEIGHT:
		return WALL_TILE
	return map_data[y * MAP_WIDTH + x]


func update_status(message: String) -> void:
	status_label.text = "HP: %d    Enemies: %d\n%s" % [player_hp, enemy_cells.size(), message]
	help_label.text = "Arrow keys: move/attack • Enter: restart after win/defeat • Esc: back to menu"


func restart_run() -> void:
	generate_dungeon()
	spawn_player_and_enemies()
	update_status("New run generated.")
	queue_redraw()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
