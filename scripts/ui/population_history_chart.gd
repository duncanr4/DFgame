extends Control

var points: Array = []

func set_points(data: Array) -> void:
	points = data.duplicate()
	queue_redraw()

func _draw() -> void:
	var rect := get_rect()
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return

	draw_rect(rect, Color(0.08, 0.08, 0.1, 0.6), true)
	var padding := Vector2(8, 6)
	var inner := Rect2(rect.position + padding, rect.size - padding * 2.0)
	if inner.size.x <= 0.0 or inner.size.y <= 0.0:
		return

	var values: Array[float] = []
	for entry: Dictionary in points:
		values.append(float(entry.get("population", 0.0)))
	if values.is_empty():
		draw_rect(inner, Color(0.2, 0.2, 0.25, 0.6), true)
		return

	var min_value: float = values.min()
	var max_value: float = values.max()
	if is_equal_approx(min_value, max_value):
		max_value = min_value + 1.0

	var chart_points := PackedVector2Array()
	for index in range(values.size()):
		var ratio := 0.0
		if values.size() > 1:
			ratio = float(index) / float(values.size() - 1)
		var x := inner.position.x + inner.size.x * ratio
		var value_ratio: float = (values[index] - min_value) / (max_value - min_value)
		var y: float = inner.position.y + inner.size.y * (1.0 - value_ratio)
		chart_points.append(Vector2(x, y))

	if chart_points.size() >= 2:
		draw_polyline(chart_points, Color(0.85, 0.9, 0.95, 0.9), 2.0, true)
	for point in chart_points:
		draw_circle(point, 2.5, Color(0.95, 0.95, 1.0, 0.95))
