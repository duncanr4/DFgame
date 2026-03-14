extends RefCounted
class_name DwarfHoldLightingService

static func has_line_of_sight_to_cell(from_cell: Vector2i, to_cell: Vector2i, is_transparent_cell: Callable) -> bool:
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
		var cell := Vector2i(x0, y0)
		if cell != from_cell and not bool(is_transparent_cell.call(cell)):
			return false
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy
	return true
