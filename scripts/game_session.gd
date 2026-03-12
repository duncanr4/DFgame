extends Node

const WorldSettings = preload("res://scripts/world_generation/world_settings.gd")

var world_settings: Dictionary = {}

func set_world_settings(settings: Dictionary) -> void:
	world_settings = WorldSettings.merge_with_defaults(settings)

func get_world_settings() -> Dictionary:
	return WorldSettings.merge_with_defaults(world_settings)

func get_world_settings_with_defaults(settings: Dictionary) -> Dictionary:
	return WorldSettings.merge_with_defaults(settings)
