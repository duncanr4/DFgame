extends Control

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_creator.tscn")


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")


func _on_pixel_dungeon_prototype_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/pixel_dungeon_prototype.tscn")


func _on_return_button_pressed() -> void:
	get_tree().quit()
