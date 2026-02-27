extends Control


var state_toggle_enabled: bool = false


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED
	)


func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value / 100.0))


func _on_music_volume_value_changed(value: float) -> void:
	var music_bus: int = AudioServer.get_bus_index("Music")
	if music_bus == -1:
		return
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value / 100.0))


func _on_sfx_volume_value_changed(value: float) -> void:
	var sfx_bus: int = AudioServer.get_bus_index("SFX")
	if sfx_bus == -1:
		return
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value / 100.0))


func _on_resolution_item_selected(index: int) -> void:
	var resolutions: Array[Vector2i] = [
		Vector2i(1280, 720),
		Vector2i(1600, 900),
		Vector2i(1920, 1080)
	]
	if index < 0 or index >= resolutions.size():
		return
	DisplayServer.window_set_size(resolutions[index])


func _on_vsync_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED
	)


func _on_state_toggle_toggled(toggled_on: bool) -> void:
	state_toggle_enabled = toggled_on
