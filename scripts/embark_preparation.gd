extends Control

@onready var seed_input: LineEdit = %SeedInput
@onready var world_name_input: LineEdit = %WorldNameInput
@onready var embark_button: Button = %EmbarkButton
@onready var back_button: Button = %BackButton

func _ready() -> void:
	push_warning("embark_preparation.gd is deprecated; world_generation_display.gd is the authoritative world setup flow.")
	randomize()
	if seed_input and seed_input.text.strip_edges().is_empty():
		seed_input.text = str(randi())
	embark_button.pressed.connect(_on_embark_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_embark_pressed() -> void:
	_store_world_settings()
	get_tree().change_scene_to_file("res://scenes/overworld.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_creator.tscn")

func _store_world_settings() -> void:
	var settings := {
		"world_seed": seed_input.text.strip_edges(),
		"world_name": world_name_input.text.strip_edges()
	}
	var game_session := get_node_or_null("/root/GameSession")
	if game_session && game_session.has_method("set_world_settings"):
		if game_session.has_method("normalize_world_settings"):
			settings = game_session.call("normalize_world_settings", settings)
		game_session.call("set_world_settings", settings)
