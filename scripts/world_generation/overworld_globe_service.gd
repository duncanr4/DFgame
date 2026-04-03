extends RefCounted
class_name OverworldGlobeService

# -- Node references (set via init) ------------------------------------------
var _globe_view: Node3D
var _globe_camera: Camera3D
var _globe_mesh: MeshInstance3D
var _scene3d_view: Node3D
var _scene3d_camera: Camera3D
var _scene3d_mesh: MeshInstance3D
var _map_viewport: SubViewport
var _map_viewport_root: Node2D
var _overworld_camera: Camera2D

# Layer references
var _map_layer: TileMapLayer
var _tree_layer: TileMapLayer
var _river_layer: TileMapLayer
var _highland_layer: TileMapLayer
var _iceberg_layer: TileMapLayer
var _settlement_layer: TileMapLayer
var _map_overlays: Node2D

# Cached original parents / indices (set externally after caching)
var map_layer_original_parent: Node = null
var map_layer_original_index := -1
var tree_layer_original_parent: Node = null
var tree_layer_original_index := -1
var river_layer_original_parent: Node = null
var river_layer_original_index := -1
var highland_layer_original_parent: Node = null
var highland_layer_original_index := -1
var iceberg_layer_original_parent: Node = null
var iceberg_layer_original_index := -1
var settlement_layer_original_parent: Node = null
var settlement_layer_original_index := -1
var overlays_original_parent: Node = null
var overlays_original_index := -1

# -- Public state (read by owner) --------------------------------------------
var is_globe_view := false
var is_scene3d_view := false
var is_dragging_globe := false
var is_dragging_scene3d := false
var height_texture: ImageTexture = null


func _init(
	globe_view: Node3D,
	globe_camera: Camera3D,
	globe_mesh: MeshInstance3D,
	scene3d_view: Node3D,
	scene3d_camera: Camera3D,
	scene3d_mesh: MeshInstance3D,
	map_viewport: SubViewport,
	map_viewport_root: Node2D,
	overworld_camera: Camera2D,
	map_layer: TileMapLayer,
	tree_layer: TileMapLayer,
	river_layer: TileMapLayer,
	highland_layer: TileMapLayer,
	iceberg_layer: TileMapLayer,
	settlement_layer: TileMapLayer,
	map_overlays: Node2D,
) -> void:
	_globe_view = globe_view
	_globe_camera = globe_camera
	_globe_mesh = globe_mesh
	_scene3d_view = scene3d_view
	_scene3d_camera = scene3d_camera
	_scene3d_mesh = scene3d_mesh
	_map_viewport = map_viewport
	_map_viewport_root = map_viewport_root
	_overworld_camera = overworld_camera
	_map_layer = map_layer
	_tree_layer = tree_layer
	_river_layer = river_layer
	_highland_layer = highland_layer
	_iceberg_layer = iceberg_layer
	_settlement_layer = settlement_layer
	_map_overlays = map_overlays


# -- Viewport / mesh configuration -------------------------------------------

func configure_globe_viewport(map_size: Vector2i, tile_size: int) -> void:
	if _map_viewport == null:
		return
	var viewport_size := Vector2i(map_size.x * tile_size, map_size.y * tile_size)
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		return
	_map_viewport.size = viewport_size
	_map_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS


func configure_scene3d_mesh(map_size: Vector2i) -> void:
	if _scene3d_mesh == null:
		return
	var plane_mesh := _scene3d_mesh.mesh as PlaneMesh
	if plane_mesh == null:
		return
	if map_size.y <= 0:
		return
	var aspect := float(map_size.x) / float(map_size.y)
	plane_mesh.size = Vector2(maxf(2.0, 4.0 * aspect), 4.0)


# -- View toggling ------------------------------------------------------------

## Enables or disables the globe view.
## The caller is responsible for updating textures, overlays, tooltips,
## and the scale bar after calling this method.
func set_globe_view(enabled: bool) -> void:
	is_globe_view = enabled
	if _globe_view != null:
		_globe_view.visible = enabled
	if _overworld_camera != null:
		_overworld_camera.enabled = not (enabled or is_scene3d_view)
		if not enabled and not is_scene3d_view:
			_overworld_camera.make_current()
	if _globe_camera != null:
		_globe_camera.current = enabled
	if not enabled:
		is_dragging_globe = false
	if enabled and not is_scene3d_view:
		move_map_layer_to_viewport()
	elif not enabled and not is_scene3d_view:
		restore_map_layer_parent()


## Enables or disables the scene3d view.
## The caller is responsible for updating textures, overlays, tooltips,
## and the scale bar after calling this method.
func set_scene3d_view(enabled: bool) -> void:
	is_scene3d_view = enabled
	if _scene3d_view != null:
		_scene3d_view.visible = enabled
	if _overworld_camera != null:
		_overworld_camera.enabled = not (is_globe_view or enabled)
		if not is_globe_view and not enabled:
			_overworld_camera.make_current()
	if _scene3d_camera != null:
		_scene3d_camera.current = enabled
	if not enabled:
		is_dragging_scene3d = false
	if enabled and not is_globe_view:
		move_map_layer_to_viewport()
	elif not enabled and not is_globe_view:
		restore_map_layer_parent()


# -- Layer reparenting --------------------------------------------------------

func move_map_layer_to_viewport() -> void:
	if _map_layer == null or _map_viewport_root == null:
		return
	if _map_layer.get_parent() == _map_viewport_root:
		return
	_map_layer.get_parent().remove_child(_map_layer)
	_map_viewport_root.add_child(_map_layer)
	_map_layer.position = Vector2.ZERO
	_reparent_layer_to_viewport(_tree_layer)
	_reparent_layer_to_viewport(_river_layer)
	_reparent_layer_to_viewport(_highland_layer)
	_reparent_layer_to_viewport(_iceberg_layer)
	_reparent_layer_to_viewport(_settlement_layer)
	if _map_overlays != null:
		if _map_overlays.get_parent() != null:
			_map_overlays.get_parent().remove_child(_map_overlays)
		_map_viewport_root.add_child(_map_overlays)
		_map_overlays.position = Vector2.ZERO


func _reparent_layer_to_viewport(layer: Node) -> void:
	if layer == null:
		return
	if layer.get_parent() != null:
		layer.get_parent().remove_child(layer)
	_map_viewport_root.add_child(layer)
	layer.position = Vector2.ZERO


func restore_map_layer_parent() -> void:
	if _map_layer == null or map_layer_original_parent == null:
		return
	if _map_layer.get_parent() == map_layer_original_parent:
		return
	_map_layer.get_parent().remove_child(_map_layer)
	if map_layer_original_index >= 0:
		map_layer_original_parent.add_child(_map_layer)
		map_layer_original_parent.move_child(_map_layer, map_layer_original_index)
	else:
		map_layer_original_parent.add_child(_map_layer)
	_map_layer.position = Vector2.ZERO
	_restore_single_layer(_tree_layer, tree_layer_original_parent, tree_layer_original_index)
	_restore_single_layer(_river_layer, river_layer_original_parent, river_layer_original_index)
	_restore_single_layer(_highland_layer, highland_layer_original_parent, highland_layer_original_index)
	_restore_single_layer(_iceberg_layer, iceberg_layer_original_parent, iceberg_layer_original_index)
	_restore_single_layer(_settlement_layer, settlement_layer_original_parent, settlement_layer_original_index)
	if _map_overlays == null or overlays_original_parent == null:
		return
	if _map_overlays.get_parent() == overlays_original_parent:
		return
	if _map_overlays.get_parent() != null:
		_map_overlays.get_parent().remove_child(_map_overlays)
	if overlays_original_index >= 0:
		overlays_original_parent.add_child(_map_overlays)
		overlays_original_parent.move_child(_map_overlays, overlays_original_index)
	else:
		overlays_original_parent.add_child(_map_overlays)
	_map_overlays.position = Vector2.ZERO


func _restore_single_layer(layer: Node, original_parent: Node, original_index: int) -> void:
	if layer == null or original_parent == null:
		return
	if layer.get_parent() != null:
		layer.get_parent().remove_child(layer)
	if original_index >= 0:
		original_parent.add_child(layer)
		original_parent.move_child(layer, original_index)
	else:
		original_parent.add_child(layer)
	layer.position = Vector2.ZERO


# -- Input handling -----------------------------------------------------------

func handle_globe_input(event: InputEvent, globe_zoom_step: float, globe_drag_sensitivity: float) -> bool:
	var mouse_button_event := event as InputEventMouseButton
	if mouse_button_event != null:
		if mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging_globe = mouse_button_event.pressed
			return true
		if mouse_button_event.pressed:
			if mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_globe_camera(-globe_zoom_step)
				return true
			if mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_globe_camera(globe_zoom_step)
				return true
	var mouse_motion_event := event as InputEventMouseMotion
	if mouse_motion_event != null and is_dragging_globe:
		rotate_globe_from_drag(mouse_motion_event.relative, globe_drag_sensitivity)
		return true
	return false


func handle_scene3d_input(event: InputEvent, scene3d_zoom_step: float, scene3d_drag_sensitivity: float) -> bool:
	var mouse_button_event := event as InputEventMouseButton
	if mouse_button_event != null:
		if mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging_scene3d = mouse_button_event.pressed
			return true
		if mouse_button_event.pressed:
			if mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_scene3d_camera(-scene3d_zoom_step)
				return true
			if mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_scene3d_camera(scene3d_zoom_step)
				return true
	var mouse_motion_event := event as InputEventMouseMotion
	if mouse_motion_event != null and is_dragging_scene3d:
		rotate_scene3d_from_drag(mouse_motion_event.relative, scene3d_drag_sensitivity)
		return true
	return false


# -- Globe rotation / drag / zoom --------------------------------------------

func rotate_globe_from_drag(relative_motion: Vector2, drag_sensitivity: float) -> void:
	if _globe_mesh == null:
		return
	_globe_mesh.rotate_y(-relative_motion.x * drag_sensitivity)
	_globe_mesh.rotate_object_local(Vector3.RIGHT, -relative_motion.y * drag_sensitivity)


func zoom_globe_camera(distance_delta: float, min_dist: float = 2.4, max_dist: float = 8.0) -> void:
	if _globe_camera == null:
		return
	var camera_origin := _globe_camera.transform.origin
	var current_distance := camera_origin.length()
	if current_distance <= 0.0001:
		return
	var target_distance := clampf(current_distance + distance_delta, min_dist, max_dist)
	if is_equal_approx(target_distance, current_distance):
		return
	_globe_camera.transform.origin = camera_origin.normalized() * target_distance


func rotate_globe(delta: float, rotation_speed: float) -> void:
	if _globe_mesh == null or rotation_speed == 0.0 or is_dragging_globe:
		return
	_globe_mesh.rotate_y(rotation_speed * delta)


# -- Scene3D rotation / drag / zoom ------------------------------------------

func rotate_scene3d_from_drag(relative_motion: Vector2, drag_sensitivity: float) -> void:
	if _scene3d_mesh == null:
		return
	_scene3d_mesh.rotate_y(-relative_motion.x * drag_sensitivity)
	_scene3d_mesh.rotate_object_local(Vector3.RIGHT, -relative_motion.y * drag_sensitivity)


func zoom_scene3d_camera(distance_delta: float, min_dist: float = 2.4, max_dist: float = 9.5) -> void:
	if _scene3d_camera == null:
		return
	var camera_origin := _scene3d_camera.transform.origin
	var current_distance := camera_origin.length()
	if current_distance <= 0.0001:
		return
	var target_distance := clampf(current_distance + distance_delta, min_dist, max_dist)
	if is_equal_approx(target_distance, current_distance):
		return
	_scene3d_camera.transform.origin = camera_origin.normalized() * target_distance


# -- Texture updates ----------------------------------------------------------

func update_globe_texture(
	water_level: float,
	mountain_level: float,
	mountain_compression: float,
	land_blend_power: float,
	globe_height_scale: float,
) -> void:
	if _globe_mesh == null or _map_viewport == null:
		return
	var viewport_texture := _map_viewport.get_texture()
	if viewport_texture == null:
		return
	var globe_material := _globe_mesh.material_override as ShaderMaterial
	if globe_material == null:
		return
	_globe_mesh.material_override = globe_material
	globe_material.set_shader_parameter("map_texture", viewport_texture)
	globe_material.set_shader_parameter("height_texture", height_texture)
	globe_material.set_shader_parameter("water_level", water_level)
	globe_material.set_shader_parameter("mountain_level", mountain_level)
	globe_material.set_shader_parameter("mountain_compression", mountain_compression)
	globe_material.set_shader_parameter("land_blend_power", land_blend_power)
	globe_material.set_shader_parameter("height_scale", globe_height_scale)


func update_scene3d_texture(
	water_level: float,
	mountain_level: float,
	mountain_compression: float,
	land_blend_power: float,
	scene3d_height_scale: float,
) -> void:
	if _scene3d_mesh == null or _map_viewport == null:
		return
	var viewport_texture := _map_viewport.get_texture()
	if viewport_texture == null:
		return
	var scene3d_material := _scene3d_mesh.material_override as ShaderMaterial
	if scene3d_material == null:
		return
	scene3d_material.set_shader_parameter("map_texture", viewport_texture)
	scene3d_material.set_shader_parameter("height_texture", height_texture)
	scene3d_material.set_shader_parameter("water_level", water_level)
	scene3d_material.set_shader_parameter("mountain_level", mountain_level)
	scene3d_material.set_shader_parameter("mountain_compression", mountain_compression)
	scene3d_material.set_shader_parameter("land_blend_power", land_blend_power)
	scene3d_material.set_shader_parameter("height_scale", scene3d_height_scale)


func update_height_texture(
	map_size: Vector2i,
	height_buffer: PackedFloat32Array,
	water_level: float,
) -> void:
	if map_size.x <= 0 or map_size.y <= 0:
		height_texture = null
		return
	var image := Image.create(map_size.x, map_size.y, false, Image.FORMAT_RF)
	if height_buffer.is_empty():
		image.fill(Color(water_level, 0.0, 0.0, 1.0))
	else:
		for y in range(map_size.y):
			for x in range(map_size.x):
				var idx := y * map_size.x + x
				var h := clampf(float(height_buffer[idx]), 0.0, 1.0)
				image.set_pixel(x, y, Color(h, 0.0, 0.0, 1.0))
	height_texture = ImageTexture.create_from_image(image)
