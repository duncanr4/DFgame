extends Node

var world_settings: Dictionary = {}

func set_world_settings(settings: Dictionary) -> void:
	world_settings = settings.duplicate(true)

func get_world_settings() -> Dictionary:
	return world_settings.duplicate(true)
