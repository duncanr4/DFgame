extends Control

@onready var message_log: RichTextLabel = $MessageWindow/MessageMargin/MessageLog

func _ready() -> void:
	_apply_chrome_theme()


func _apply_chrome_theme() -> void:
	var button_normal := StyleBoxFlat.new()
	button_normal.bg_color = Color("1d2433")
	button_normal.border_color = Color("7d8ea9")
	button_normal.set_border_width_all(2)

	var button_pressed := StyleBoxFlat.new()
	button_pressed.bg_color = Color("2b364a")
	button_pressed.border_color = Color("a7bedf")
	button_pressed.set_border_width_all(2)

	var button_hover := button_normal.duplicate()
	button_hover.bg_color = Color("263046")

	for node: Node in get_tree().get_nodes_in_group("spd_button"):
		if node is Button:
			_style_button(node as Button, button_normal, button_pressed, button_hover)

	for button: Button in [
		$Toolbar/ActionButtons/SearchButton,
		$Toolbar/ActionButtons/WaitButton,
		$Toolbar/ActionButtons/ZapButton,
		$InventoryWindow/InventoryMargin/InventoryGrid/Item1,
		$InventoryWindow/InventoryMargin/InventoryGrid/Item2,
		$InventoryWindow/InventoryMargin/InventoryGrid/Item3,
		$InventoryWindow/InventoryMargin/InventoryGrid/Item4,
		$InventoryWindow/InventoryMargin/InventoryGrid/Item5,
		$InventoryWindow/InventoryMargin/InventoryGrid/Item6,
		$InventoryWindow/InventoryMargin/InventoryGrid/Item7,
		$InventoryWindow/InventoryMargin/InventoryGrid/Item8,
	]:
		_style_button(button, button_normal, button_pressed, button_hover)

	for label: RichTextLabel in [
		$HeroWindow/HeroMargin/HeroStats,
		$JournalWindow/JournalMargin/JournalText,
		message_log,
	]:
		label.add_theme_color_override("default_color", Color("d5e1f2"))


func _style_button(button: Button, normal: StyleBoxFlat, pressed: StyleBoxFlat, hover: StyleBoxFlat) -> void:
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_color_override("font_color", Color("ecf3ff"))


func _on_search_button_pressed() -> void:
	_append_log("[color=#f5e4a6]You search for hidden doors.[/color]")


func _on_wait_button_pressed() -> void:
	_append_log("[color=#b9d7ff]You wait a turn and listen carefully.[/color]")


func _on_zap_button_pressed() -> void:
	_append_log("[color=#d2b8ff]A wand spark flashes across the hall.[/color]")


func _append_log(entry: String) -> void:
	if message_log.text.length() > 0:
		message_log.append_text("\n")
	message_log.append_text(entry)
