extends Control

@export var segment_count: int = 4
@export var bar_height: float = 12.0
@export var stroke_color: Color = Color(0.08, 0.08, 0.08, 0.95)
@export var light_segment_color: Color = Color(0.95, 0.95, 0.95, 0.95)
@export var dark_segment_color: Color = Color(0.12, 0.12, 0.12, 0.95)
@export var target_pixel_width: float = 150.0
@export var min_pixel_width: float = 72.0
@export var max_pixel_width: float = 220.0

var _bar_pixel_width: float = 120.0
var _display_distance_km: float = 100.0

func _ready() -> void:
	custom_minimum_size = Vector2(max_pixel_width + 8.0, bar_height + 18.0)
	queue_redraw()

func set_scale_display(pixels_per_km: float) -> void:
	if pixels_per_km <= 0.0:
		visible = false
		return
	visible = true
	_display_distance_km = _pick_nice_distance(target_pixel_width / pixels_per_km)
	_bar_pixel_width = clampf(_display_distance_km * pixels_per_km, min_pixel_width, max_pixel_width)
	queue_redraw()

func get_distance_label() -> String:
	if _display_distance_km >= 1000.0:
		return "%s km" % _format_number(snapped(_display_distance_km, 1.0))
	return "%s km" % _format_number(_display_distance_km)

func _draw() -> void:
	var top := 0.0
	var left := 0.0
	var safe_segments := maxi(segment_count, 1)
	var segment_width := _bar_pixel_width / float(safe_segments)
	for i in range(safe_segments):
		var rect := Rect2(Vector2(left + segment_width * float(i), top), Vector2(segment_width, bar_height))
		draw_rect(rect, dark_segment_color if i % 2 == 0 else light_segment_color, true)
	draw_rect(Rect2(Vector2(left, top), Vector2(_bar_pixel_width, bar_height)), stroke_color, false, 1.5)
	draw_line(Vector2(left, top + bar_height), Vector2(left, top + bar_height + 4.0), stroke_color, 1.5)
	draw_line(Vector2(left + _bar_pixel_width, top + bar_height), Vector2(left + _bar_pixel_width, top + bar_height + 4.0), stroke_color, 1.5)

func _pick_nice_distance(target_distance: float) -> float:
	var safe_target: float = maxf(target_distance, 0.001)
	var exponent: float = floor(log(safe_target) / log(10.0))
	var magnitude: float = pow(10.0, exponent)
	var normalized: float = safe_target / magnitude
	var step: float = 1.0
	if normalized > 1.0:
		step = 2.0
	if normalized > 2.0:
		step = 3.0
	if normalized > 3.0:
		step = 5.0
	if normalized > 5.0:
		step = 10.0
	return step * magnitude

func _format_number(value: float) -> String:
	if value >= 100.0:
		return str(int(round(value)))
	if value >= 10.0:
		return String.num(value, 1)
	return String.num(value, 2)
