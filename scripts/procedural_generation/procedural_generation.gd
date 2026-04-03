@tool
class_name ProceduralGeneration
extends Node

@warning_ignore_start("unused_signal")
signal recreate_noise
signal recreate_paint
signal recreate_tilemap
@warning_ignore_restore("unused_signal")

@export var tile_map: PackedScene
@export var tilemap_container: Node2D

@export var size: Vector2i:
	set(value):
		size = value
		if is_node_ready():
			recreate_noise.emit()

@export var tile_map_size: Vector2i:
	set(value):
		assert(value.x <= size.x && value.y <= size.y)
		tile_map_size = value
		if is_node_ready():
			recreate_paint.emit()

@export var noise_type: FastNoiseLite.NoiseType:
	set(value):
		noise_type = value
		if is_node_ready():
			recreate_paint.emit()

var noise: FastNoiseLite

var image: Image
var grid_map: Dictionary[Vector2i, Dictionary]

var _curr_tilemap: TileMapLayer


static func line_coords(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var array: Array[Vector2i]
	var relative := to - from

	if relative.x == 0:
		var step := 1 if relative.y >= 0 else -1
		for curr_y in range(from.y, to.y, step):
			array.append(Vector2i(from.x, curr_y))
	else:
		var ratio := float(relative.y) / float(relative.x)
		var step := 1 if relative.x > 0 else -1
		for curr_x in range(from.x, to.x, step):
			var curr_y := roundi(ratio * (curr_x - from.x) + from.y)
			array.append(Vector2i(curr_x, curr_y))

	return array

func _enter_tree() -> void:
	noise = FastNoiseLite.new()
	grid_map = {}

func _ready() -> void:
	assert(Seeder.instance.current_seed, "Seeder did not execute")
	recreate_tilemap.connect(generate_tilemap)

func generate_noise() -> Image:
	noise.seed = Seeder.instance.current_seed
	noise.noise_type = noise_type

	return noise.get_seamless_image(size.x, size.y)

func generate_tilemap() -> void:
	assert(tile_map)
	if grid_map.is_empty():
		recreate_paint.emit()

	if _curr_tilemap:
		_curr_tilemap.queue_free()
		_curr_tilemap = null

	_curr_tilemap = tile_map.instantiate()

	for curr_key in grid_map:
		var cell: Dictionary = grid_map[curr_key]
		var source_id := int(cell.get("source", 0))
		var atlas_coords: Vector2i = cell.get("atlas", Vector2i.ZERO)
		var alt_id := int(cell.get("alt", 0))
		_curr_tilemap.set_cell(curr_key, source_id, atlas_coords, alt_id)

	tilemap_container.add_child(_curr_tilemap)
