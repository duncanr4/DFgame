extends Control

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_creator.tscn")


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")


func _on_shattered_pixel_dungeon_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/shattered_pixel_dungeon_windows.tscn")


func _on_return_button_pressed() -> void:
	get_tree().quit()
