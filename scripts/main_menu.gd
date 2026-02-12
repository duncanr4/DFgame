extends Control

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world_generation_setup.tscn")


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")


func _on_return_button_pressed() -> void:
	get_tree().quit()
