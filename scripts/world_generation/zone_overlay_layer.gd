extends Control

var _grid: Dictionary = {}
var _tile_size := Vector2i(32, 32)
var _zoom_level := 1.0
var _map_position := Vector2.ZERO
var _zone_colors: Dictionary = {}
var _overlay_enabled := false

func set_overlay_state(grid: Dictionary, tile_size: Vector2i, zoom_level: float, map_position: Vector2, zone_colors: Dictionary, overlay_enabled: bool) -> void:
	_grid = grid
	_tile_size = tile_size
	_zoom_level = zoom_level
	_map_position = map_position
	_zone_colors = zone_colors
	_overlay_enabled = overlay_enabled
	visible = overlay_enabled
	queue_redraw()

func _draw() -> void:
	if not _overlay_enabled or _grid.is_empty():
		return

	var panel_rect := Rect2(Vector2.ZERO, size)
	for key: Variant in _grid.keys():
		var cell := key as Vector2i
		var tile := int(_grid[cell])
		if not _zone_colors.has(tile):
			continue

		var cell_top_left := _map_position + (Vector2(cell * _tile_size) * _zoom_level)
		var cell_rect := Rect2(cell_top_left, Vector2(_tile_size) * _zoom_level)
		if not panel_rect.intersects(cell_rect):
			continue

		draw_rect(cell_rect, _zone_colors[tile], true)
