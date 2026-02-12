extends Control

const MAP_SIZES := [
	{
		"name": "Mini",
		"dimensions": "213 × 120",
		"size": Vector2i(213, 120)
	},
	{
		"name": "Small",
		"dimensions": "347 × 195",
		"size": Vector2i(347, 195)
	},
	{
		"name": "Normal",
		"dimensions": "480 × 270",
		"size": Vector2i(480, 270)
	},
	{
		"name": "Large",
		"dimensions": "613 × 345",
		"size": Vector2i(613, 345)
	},
	{
		"name": "Extra Large",
		"dimensions": "747 × 420",
		"size": Vector2i(747, 420)
	}
]

const WORLD_LAYOUTS := [
	"Normal",
	"Major Continent",
	"Twin Continents",
	"Inland Sea",
	"Archipelago"
]

const WORLD_NAMES := [
	"Nûrn",
	"Ardganor",
	"Drakmor",
	"Thaldur",
	"Eldrakis",
	"Karrûn",
	"Tholmar",
	"Torra",
	"Albia",
	"Tor",
	"Lassel",
	"Marrov'gar",
	"Planetos",
	"Ulthos",
	"Grrth",
	"Erin",
	"Nûrnheim",
	"Midkemia",
	"Skarnheim",
	"Shannara",
	"Alagaësia",
	"Syf",
	"Elysium",
	"Lankhmar",
	"Arcadia",
	"Eberron",
	"Crobuzon",
	"Valdemar",
	"Uresia",
	"Tiassa",
	"Tairnadal",
	"Solara",
	"Golarion",
	"Aerth",
	"Khand",
	"Sanctuary",
	"Thra",
	"Acheron",
	"Cosmere",
	"Tékumel",
	"Norrathal",
	"Prydain",
	"Kulthea",
	"Bas-Lag",
	"Eternia",
	"Xanth",
	"Abeir-Toril",
	"Earthsea",
	"Pern",
	"Discworld",
	"Hyboria",
	"Avalon",
	"Tyria",
	"Tarnadam",
	"Rokugan",
	"Glorantha",
	"Ivalice",
	"The World of the Five Gods",
	"Narnia",
	"Azeroth",
	"Spira",
	"Noxus",
	"Volkran",
	"Tal'Dorei",
	"Exandria",
	"Runeterra",
	"Eorzea",
	"Thraenor",
	"Xadia",
	"Roshar",
	"Teldrassil",
	"Draenor",
	"Valisthea",
	"Gensokyo",
	"Temeria",
	"Nilfgaard",
	"Aedirn",
	"Redania",
	"Kaedwen",
	"Toussaint",
	"Rivellon",
	"Lucis",
	"Gransys",
	"Drangleic",
	"Lothric",
	"Boletaria",
	"Lordran",
	"Caelid",
	"Limgrave",
	"Altus",
	"Plateauonia",
	"Iria",
	"Theros",
	"Dominaria",
	"Zendikar",
	"Innistrad",
	"Ravnica",
	"Kamigawa",
	"Lorwyn",
	"Tarkir",
	"Ikoria",
	"Strixhaven",
	"Brazenforge",
	"Solarae",
	"Ethyra",
	"Lunathor",
	"Aethernis",
	"Veydris",
	"Nytherra",
	"Astralis",
	"Zephyra",
	"Umbryss",
	"Eclipthar",
	"Skibiti Toliterium",
	"Syx",
	"Quidd"
]

@onready var map_size_select: OptionButton = %MapSizeSelect
@onready var world_layout_select: OptionButton = %WorldLayoutSelect
@onready var seed_input: LineEdit = %SeedInput
@onready var year_input: SpinBox = %YearInput
@onready var age_input: SpinBox = %AgeInput
@onready var randomise_chronology_button: Button = %RandomiseChronologyButton
@onready var world_name_input: LineEdit = %WorldNameInput
@onready var randomise_world_name_button: Button = %RandomiseWorldNameButton
@onready var embark_button: Button = %EmbarkButton
@onready var back_button: Button = %BackButton

@onready var summary_map_size: Label = %SummaryMapSize
@onready var summary_layout: Label = %SummaryLayout
@onready var summary_seed: Label = %SummarySeed
@onready var summary_chronology: Label = %SummaryChronology
func _ready() -> void:
	randomize()
	_populate_options()
	seed_input.text = _generate_seed()
	year_input.value = 1485
	age_input.value = 18
	world_name_input.text = _generate_world_name()
	_refresh_summary()

	map_size_select.item_selected.connect(func(_index: int) -> void: _refresh_summary())
	world_layout_select.item_selected.connect(func(_index: int) -> void: _refresh_summary())
	seed_input.text_changed.connect(func(_text: String) -> void: _refresh_summary())
	year_input.value_changed.connect(func(_value: float) -> void: _refresh_summary())
	age_input.value_changed.connect(func(_value: float) -> void: _refresh_summary())
	world_name_input.text_changed.connect(func(_text: String) -> void: _refresh_summary())

	randomise_chronology_button.pressed.connect(_on_randomise_chronology_pressed)
	randomise_world_name_button.pressed.connect(_on_randomise_world_name_pressed)
	embark_button.pressed.connect(_on_embark_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _populate_options() -> void:
	map_size_select.clear()
	for map_size: Dictionary in MAP_SIZES:
		map_size_select.add_item("%s — %s" % [map_size["name"], map_size["dimensions"]])
	map_size_select.select(2)

	world_layout_select.clear()
	for layout: String in WORLD_LAYOUTS:
		world_layout_select.add_item(layout)
	world_layout_select.select(0)

func _refresh_summary() -> void:
	var map_size: Dictionary = MAP_SIZES[map_size_select.selected]
	summary_map_size.text = "%s — %s" % [map_size["name"], map_size["dimensions"]]
	summary_layout.text = world_layout_select.get_item_text(world_layout_select.selected)
	summary_seed.text = seed_input.text.strip_edges() if not seed_input.text.strip_edges().is_empty() else "Random"
	summary_chronology.text = "Year %d of the %d Age" % [int(year_input.value), int(age_input.value)]

func _on_randomise_chronology_pressed() -> void:
	year_input.value = randi_range(200, 2500)
	age_input.value = randi_range(2, 20)
	_refresh_summary()

func _on_randomise_world_name_pressed() -> void:
	world_name_input.text = _generate_world_name()
	_refresh_summary()

func _generate_seed() -> String:
	return "%s%s%s" % [
		_characters_for_seed(3),
		randi_range(100, 999),
		_characters_for_seed(2)
	]

func _generate_world_name() -> String:
	return WORLD_NAMES.pick_random()

func _characters_for_seed(amount: int) -> String:
	const OPTIONS := "abcdefghijklmnopqrstuvwxyz"
	var result := ""
	for _i in amount:
		result += OPTIONS[randi_range(0, OPTIONS.length() - 1)]
	return result

func _on_embark_pressed() -> void:
	if world_name_input.text.strip_edges().is_empty():
		world_name_input.text = _generate_world_name()
		_refresh_summary()
	_store_world_settings()
	get_tree().change_scene_to_file("res://scenes/overworld.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_creator.tscn")

func _store_world_settings() -> void:
	var map_size: Dictionary = MAP_SIZES[map_size_select.selected]
	var settings := {
		"map_size": map_size["name"],
		"map_dimensions": map_size["size"],
		"world_layout": world_layout_select.get_item_text(world_layout_select.selected),
		"world_seed": seed_input.text.strip_edges()
	}
	var game_session := get_node_or_null("/root/GameSession")
	if game_session && game_session.has_method("set_world_settings"):
		game_session.call("set_world_settings", settings)
