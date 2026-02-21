extends Control

const FRAME_STRIP_SHADER := preload("res://shaders/ui/frame_strip_overlay.gdshader")
const LFS_POINTER_PREFIX := "version https://git-lfs.github.com/spec/"
const BACKGROUND_TEXTURE_PATH := "res://resources/images/main_menu/Title-Background.png"
const LOGO_TEXTURE_PATH := "res://resources/images/main_menu/logo.png"
const START_TEXTURE_PATH := "res://resources/images/main_menu/Start.png"
const OPTIONS_TEXTURE_PATH := "res://resources/images/main_menu/Options.png"
const RETURN_TEXTURE_PATH := "res://resources/images/main_menu/return.png"

@export_file("*.png") var smith_frames_path := "res://resources/images/main_menu/smith.png"
@export_file("*.png") var title_frames_path := "res://resources/images/main_menu/title.png"
@export_file("*.gif") var smith_fallback_path := "res://resources/images/main_menu/smith.gif"
@export_file("*.gif") var title_fallback_path := "res://resources/images/main_menu/title.gif"
@export var frame_count := 12
@export var frames_per_second := 12.0

@onready var background: TextureRect = $Background
@onready var logo: TextureRect = $Logo
@onready var start_button: TextureButton = $CenterContainer/VBoxContainer/StartButton
@onready var options_button: TextureButton = $CenterContainer/VBoxContainer/OptionsButton
@onready var return_button: TextureButton = $CenterContainer/VBoxContainer/ReturnButton
@onready var smith_overlay: TextureRect = $Background/OverlayRoot/SmithOverlay
@onready var title_overlay: TextureRect = $Background/OverlayRoot/TitleOverlay

func _ready() -> void:
	_configure_animated_overlays()
	_apply_missing_asset_fallbacks()


func _configure_animated_overlays() -> void:
	_configure_overlay_texture(smith_overlay, smith_frames_path, smith_fallback_path)
	_configure_overlay_texture(title_overlay, title_frames_path, title_fallback_path)


func _configure_overlay_texture(overlay: TextureRect, png_path: String, gif_path: String) -> void:
	if overlay == null:
		return

	var strip_texture := _load_texture_if_available(png_path)
	if strip_texture != null:
		overlay.texture = strip_texture
		var shader_material := ShaderMaterial.new()
		shader_material.shader = FRAME_STRIP_SHADER
		shader_material.set_shader_parameter("frame_count", max(frame_count, 1))
		shader_material.set_shader_parameter("fps", max(frames_per_second, 1.0))
		overlay.material = shader_material
		return

	var gif_texture := _load_texture_if_available(gif_path)
	overlay.texture = gif_texture
	overlay.material = null


func _load_texture_if_available(resource_path: String) -> Texture2D:
	if not ResourceLoader.exists(resource_path):
		return null
	if _is_lfs_pointer_resource(resource_path):
		return null
	var loaded_resource := load(resource_path)
	if loaded_resource is Texture2D:
		return loaded_resource as Texture2D
	return null


func _is_lfs_pointer_resource(resource_path: String) -> bool:
	var absolute_path := ProjectSettings.globalize_path(resource_path)
	if not FileAccess.file_exists(absolute_path):
		return false
	var file := FileAccess.open(absolute_path, FileAccess.READ)
	if file == null:
		return false
	var header := file.get_as_text(min(file.get_length(), 80))
	return header.begins_with(LFS_POINTER_PREFIX)


func _apply_missing_asset_fallbacks() -> void:
	if _is_lfs_pointer_resource(BACKGROUND_TEXTURE_PATH):
		background.texture = null
		background.self_modulate = Color(0.09, 0.08, 0.12, 1.0)

	if _is_lfs_pointer_resource(LOGO_TEXTURE_PATH):
		logo.texture = null
		_ensure_button_label(logo, "Dwarfhold", 48)

	if _is_lfs_pointer_resource(START_TEXTURE_PATH):
		start_button.texture_normal = null
		_ensure_button_label(start_button, "Start", 28)

	if _is_lfs_pointer_resource(OPTIONS_TEXTURE_PATH):
		options_button.texture_normal = null
		_ensure_button_label(options_button, "Options", 28)

	if _is_lfs_pointer_resource(RETURN_TEXTURE_PATH):
		return_button.texture_normal = null
		_ensure_button_label(return_button, "Return", 28)


func _ensure_button_label(parent: Control, text: String, font_size: int) -> void:
	var existing := parent.get_node_or_null("FallbackLabel")
	if existing != null:
		return

	var label := Label.new()
	label.name = "FallbackLabel"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(label)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_creator.tscn")


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")


func _on_dwarf_hold_generator_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/dwarf_hold_generation.tscn")


func _on_return_button_pressed() -> void:
	get_tree().quit()
