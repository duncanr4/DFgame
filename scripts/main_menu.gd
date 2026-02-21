extends Control

@export_file("*.png") var smith_frames_path := "res://resources/images/main_menu/smith.png"
@export_file("*.png") var title_frames_path := "res://resources/images/main_menu/title.png"
@export_file("*.gif") var smith_fallback_path := "res://resources/images/main_menu/smith.gif"
@export_file("*.gif") var title_fallback_path := "res://resources/images/main_menu/title.gif"
@export var frame_count := 12
@export var frames_per_second := 12.0

@onready var smith_overlay: TextureRect = $Background/OverlayRoot/SmithOverlay
@onready var title_overlay: TextureRect = $Background/OverlayRoot/TitleOverlay

func _ready() -> void:
	_configure_animated_overlays()


func _configure_animated_overlays() -> void:
	_assign_overlay_texture(smith_overlay, smith_frames_path, smith_fallback_path)
	_assign_overlay_texture(title_overlay, title_frames_path, title_fallback_path)
	_apply_animation_settings(smith_overlay)
	_apply_animation_settings(title_overlay)


func _assign_overlay_texture(overlay: TextureRect, texture_path: String, fallback_path: String) -> void:
	if overlay == null:
		return
	if ResourceLoader.exists(texture_path):
		overlay.texture = load(texture_path)
	elif ResourceLoader.exists(fallback_path):
		overlay.texture = load(fallback_path)


func _apply_animation_settings(overlay: TextureRect) -> void:
	if overlay == null or overlay.material == null:
		return
	if overlay.material is ShaderMaterial:
		var shader_material := overlay.material as ShaderMaterial
		shader_material.set_shader_parameter("frame_count", max(frame_count, 1))
		shader_material.set_shader_parameter("fps", max(frames_per_second, 1.0))

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_creator.tscn")


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")


func _on_dwarf_hold_generator_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/dwarf_hold_generation.tscn")


func _on_return_button_pressed() -> void:
	get_tree().quit()
