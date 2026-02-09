@tool
class_name PortraitCreator
extends Control

signal resend_images

## This needs to match with the indexes in the file
## portrait_indexes.gdshaderinc with identifier uid://wfjoy5r4lanh
enum Images {
	PORTRAIT,
	BEARD,
	HAIR
}
const AMOUNT_OF_IMAGES := 3

static var instance: PortraitCreator

@export var target_render: Control
@export var part_picker: PackedScene

@export_group(&"Directories")
@export var character_name: LineEdit
@export var profession_choice: OptionButton
@export var clan_name: OptionButton
@export var female_button: Button
@export var male_button: Button

const CLAN_OPTIONS := [
	"Stonebeard",
	"Barrelbrow",
	"Oathhammer",
	"Stormshield",
	"Granitebrow",
	"Emberstone",
	"Blackdelve",
	"Hearthhammer",
	"Mithrilbeard",
	"Shieldbreaker",
	"Deepcrag",
	"Duskhollow",
	"Hammerdeep",
	"Deepmantle",
	"Ashmantle",
	"Shadowhearth",
	"Angrund",
	"Angrulok",
	"Badrikk",
	"Barruk",
	"Burrdrik",
	"Bronzebeards",
	"Bronzefist",
	"Copperback",
	"Cragbrow",
	"Craghand",
	"Cragtooth",
	"Donarkhun",
	"Dourback",
	"Dragonback",
	"Drakebeard",
	"Drazhkarak",
	"Dunrakin",
	"Firehand",
	"Firehelm",
	"Flintbeard",
	"Flinthand",
	"Flintheart",
	"Fooger",
	"Forgehand",
	"Grimhelm",
	"Grimstone",
	"Gunnarsson",
	"Gunnisson",
	"Guttrik",
	"Halgakrin",
	"Hammerback",
	"Helhein",
	"Irebeard",
	"Ironbeard",
	"Ironarm",
	"Ironback",
	"Ironfist",
	"Ironforge",
	"Ironhammer",
	"Ironpick",
	"Ironspike",
	"Izorgrung",
	"Kaznagar",
	"Magrest",
	"Norgrimlings",
	"Oakbarrel",
	"Redbeard",
	"Silverscar",
	"Skorrun",
	"Steelcrag",
	"Sternbeard",
	"Stoneback",
	"Stonebeater",
	"Stonebreakers",
	"Stonehammer",
	"Stonehand",
	"Stoneheart",
	"Stoutgirth",
	"Stoutpeak",
	"Svengeln",
	"Threkkson",
	"Thundergun",
	"Thunderheart",
	"Thunderstone",
	"Varnskan",
	"Vorgrund",
	"Yinlinsson",
	"Coppervein",
	"Graniteheart",
	"Deepdelver",
	"Amberpick",
	"Oakenshield",
	"Frosthammer",
	"Berylbraid",
	"Silverhollow",
	"Brazenaxe",
	"Stormhammer",
	"Deeprock",
	"Goldvein",
	"Runesmith",
	"Aleswiller",
	"Argent Hand",
	"Axebreaker",
	"Blackfire",
	"Bloodstone",
	"Boulderscorch",
	"Duergar",
	"Fiania",
	"Goldenforge",
	"Gordemuncher",
	"Hammerhead",
	"Ironson",
	"Kazak Uruk",
	"Orcsplitter",
	"Rockcrawler",
	"Shattered Stone",
	"Bronzebeard",
	"Stormpike",
	"Stonefist",
	"Hylar",
	"Daergar",
	"Daewar",
	"Theiwar",
	"Aghar",
	"Battlehammer",
	"Bitterroot",
	"Black Axe",
	"Boldenbar",
	"Bouldershoulder",
	"Brawnanvil",
	"Brightblade",
	"Brighthelm",
	"Broodhull",
	"Bruenghor",
	"Bukbukken",
	"Chistlesmith",
	"Eaglecleft",
	"Flameshade",
	"Muzgardt",
	"Stoneshaft",
	"Ticklebeard",
	"Dankil",
	"Daraz",
	"Forgebar",
	"Gemcrypt",
	"Girdaur",
	"Hammerhand",
	"Hardhammer",
	"Herlinga",
	"Hillborn",
	"Hillsafar",
	"Horn",
	"Icehammer",
	"Ironeater",
	"Ironstar",
	"Licehair",
	"Ludwakazar",
	"Madbeards",
	"McKnuckles",
	"McRuff",
	"Melairkyn",
	"Orcsmasher",
	"Orothiar",
	"Pwent",
	"Rockjaw",
	"Rookoath",
	"Rustfire",
	"Sandbeards",
	"Shattershield",
	"Stonebridge",
	"Stoneshoulder",
	"Stouthammer",
	"Sunblight",
	"Undurr",
	"Grimlock",
	"MacCloud",
	"Thundermore",
	"Enogtorad",
	"Drummond",
	"Tolorr",
	"Vanderholl",
	"Aringeld",
	"Firecask",
	"Gelderon",
	"Grimmark",
	"Molgrade",
	"Runebinder",
	"Orridus",
	"Shalefoot",
	"Silverhair",
	"Copperlung",
	"Stonescar",
	"Flintbristle",
	"Stonehollow",
	"Silverpick",
	"Ironheart",
	"Weoughld",
	"Llyrnillach",
	"Highhelm"
]

const MALE_NAME_POOL := [
	"Baern",
	"Dimli",
	"Einkar",
	"Gimli",
	"Harbek",
	"Kargun",
	"Mardin",
	"Orsik",
	"Rurik",
	"Thorin",
	"Ulfgar",
	"Vondal",
	"Urist",
	"Thob",
	"Kadol",
	"Stukos",
	"Likot",
	"Datan",
	"Mörul",
	"Logem",
	"Rakust",
	"Gorim",
	"Norgrim",
	"Balgor",
	"Balgrum",
	"Balro",
	"Byron",
	"Dain",
	"Daragin",
	"Darmar",
	"Darrius",
	"Datunashvili",
	"Dorgan",
	"Dranvin",
	"Duragin",
	"Durgin",
	"Durin",
	"Durnak",
	"Elgor",
	"Flindir",
	"Gardian",
	"Gorin",
	"Harald",
	"Hoogin",
	"Horgrim",
	"Hoyreal",
	"Hrothar",
	"Jamin",
	"Jarin",
	"Jarroc",
	"Khordryn",
	"Kordrim",
	"Korgrim",
	"Kurgil",
	"Maldrik",
	"Marius",
	"Mordrun",
	"Morgrim",
	"Muradin",
	"Odrin",
	"Oshuart",
	"Roorke",
	"Thaivo",
	"Thalgrim",
	"Tharagin",
	"Thorek",
	"Thorgrim",
	"Thrain",
	"Thror",
	"Thuringar",
	"Torgrim",
	"Trearagin",
	"Tyr",
	"Ulgrim",
	"Vearspan",
	"Vondar",
	"Bargrin",
	"Drokal",
	"Khardek",
	"Brundar",
	"Kolgrim",
	"Tharnok",
	"Grimvek",
	"Odrak",
	"Storn",
	"Baldrik",
	"Khemdir",
	"Rugnar",
	"Haldrek",
	"Morvek",
	"Durnik",
	"Kargath",
	"Ulvorn",
	"Brannik",
	"Thorekkan",
	"Galdur",
	"Ragnor",
	"Dromli",
	"Skarn",
	"Vuldrek",
	"Korvash",
	"Drakkel",
	"Borgran",
	"Khuldir",
	"Tarnak",
	"Grodin",
	"Malgrom",
	"Fenrik",
	"Ogrimak",
	"Durvash",
	"Balrik",
	"Thuldar",
	"Krommel",
	"Jarndek",
	"Moradin",
	"Hurgan",
	"Skeldor",
	"Brandek",
	"Vulkar",
	"Dornik",
	"Grimdar",
	"Rokhan",
	"Kharn",
	"Ulgrin",
	"Brumak",
	"Tharvek",
	"Gromlir",
	"Kardun",
	"Vordek",
	"Sturgan",
	"Malrik",
	"Orvash",
	"Drundel",
	"Hrodek",
	"Kargul",
	"Balvorn",
	"Thurnik",
	"Grovak",
	"Ruldar",
	"Dorgath",
	"Skorim",
	"Branvor",
	"Khordek",
	"Murvek",
	"Tarnor",
	"Vulgrim",
	"Drekal",
	"Harnok",
	"Borvik",
	"Grimlor",
	"Ulmar",
	"Stenrik",
	"Kardrim",
	"Throlin",
	"Gurnak",
	"Morgrin",
	"Yorrill",
	"Zromin"
]

const FEMALE_NAME_POOL := [
	"Audhild",
	"Brynna",
	"Diesa",
	"Eldeth",
	"Finellen",
	"Gurdis",
	"Helja",
	"Kathra",
	"Liftrasa",
	"Sannl",
	"Torbera",
	"Vistra",
	"Domas",
	"Rigòth",
	"Kadôl",
	"Meng",
	"Onol",
	"Rith",
	"Sigrid",
	"Thilda",
	"Asgrid",
	"Helga",
	"Goden",
	"Emera",
	"Hilda",
	"Moira",
	"Brunna",
	"Keldra",
	"Audrika",
	"Thorga",
	"Durnella",
	"Grimsa",
	"Hildren",
	"Baldris",
	"Skara",
	"Vondra",
	"Khorra",
	"Bryndis",
	"Ulvara",
	"Morna",
	"Ragna",
	"Torhilda",
	"Dagna",
	"Finra",
	"Kardra",
	"Helvara",
	"Sigrun",
	"Borna",
	"Thryssa",
	"Kelmora",
	"Audra",
	"Skaldi",
	"Vigrid",
	"Durnis",
	"Grimna",
	"Hroda",
	"Brilda",
	"Malda",
	"Orla",
	"Khendra",
	"Balra",
	"Thildaen",
	"Gurna",
	"Rigdra",
	"Ulrissa",
	"Morgria",
	"Tarnis",
	"Brylda",
	"Kardis",
	"Hella",
	"Fenna",
	"Skorla",
	"Dorga",
	"Thorae",
	"Brunnae",
	"Vendra",
	"Korga",
	"Audmora",
	"Runa",
	"Grimra",
	"Heldis",
	"Borika",
	"Dagnae",
	"Thryna",
	"Ulmara",
	"Skelda",
	"Mornael",
	"Keldis",
	"Ragnae",
	"Brindra",
	"Gildra",
	"Tarnia",
	"Kardella",
	"Hrothra",
	"Baldis",
	"Fenra",
	"Skarna",
	"Vuldra",
	"Ordis",
	"Durnika",
	"Bryssa",
	"Thulda",
	"Grena",
	"Ulgrida",
	"Mordra",
	"Khora"
]

@export_group(&"Directories")
@export_dir var portrait_dir: String
@export_dir var beard_dir: String
@export_dir var hair_dir: String

@export_group(&"Sliders")
@export var skin_color: HSlider
@export var eye_color: HSlider
@export var hair_color: HSlider
@export var beard_color: HSlider

@export_group(&"Default images")
@export var portrait: CompressedTexture2D:
	set(value):
		portrait = value
		resend_images.emit()

@export var beard: CompressedTexture2D:
	set(value):
		beard = value
		resend_images.emit()

@export var hair: CompressedTexture2D:
	set(value):
		hair = value
		resend_images.emit()

var _images: Array[CompressedTexture2D]
var _colors: Array[Vector3]

var _selected := Images.PORTRAIT
var _is_female := false
var _rng := RandomNumberGenerator.new()

var _available_beards: Array[CompressedTexture2D]
var _gender_button_hover_shadow: StyleBoxFlat
var _gender_button_pressed_shadow: StyleBoxFlat
var _gender_button_normal_shadow: StyleBoxFlat

const GENDER_BUTTON_BRIGHTNESS_NORMAL := 0.85
const GENDER_BUTTON_BRIGHTNESS_HOVER := 1.08
const GENDER_BUTTON_BRIGHTNESS_PRESSED := 1.18
const GENDER_BUTTON_ICON_Y_NORMAL := 0.0
const GENDER_BUTTON_ICON_Y_HOVER := -2.0
const GENDER_BUTTON_ICON_Y_PRESSED := 1.0
const GENDER_BUTTON_TWEEN_DURATION := 0.12

func _enter_tree() -> void:
	instance = self

func _exit_tree() -> void:
	instance = null
	_images.clear()
	_available_beards.clear()

func _ready() -> void:
	_rng.randomize()

	skin_color.value_changed.connect(_on_color_changed.bind(Images.PORTRAIT))
	hair_color.value_changed.connect(_on_color_changed.bind(Images.HAIR))
	beard_color.value_changed.connect(_on_color_changed.bind(Images.BEARD))

	character_name.text_changed.connect(_on_name_changed)
	if female_button:
		female_button.pressed.connect(_set_gender.bind(true))
		_setup_gender_button(female_button)
	if male_button:
		male_button.pressed.connect(_set_gender.bind(false))
		_setup_gender_button(male_button)

	clan_name.clear()
	for clan: String in CLAN_OPTIONS:
		clan_name.add_item(clan)

	resend_images.connect(_on_resend_images)

	_images.resize(3)
	_colors.resize(3)
	_refresh_random_name()

func _setup_gender_button(button: Button) -> void:
	if !_gender_button_normal_shadow:
		_gender_button_normal_shadow = _build_gender_shadow_style(0, Color(0, 0, 0, 0), Vector2.ZERO)
		_gender_button_hover_shadow = _build_gender_shadow_style(10, Color(0, 0, 0, 0.35), Vector2(0, 4))
		_gender_button_pressed_shadow = _build_gender_shadow_style(14, Color(0, 0, 0, 0.45), Vector2(0, 6))

	button.add_theme_stylebox_override("normal", _gender_button_normal_shadow)
	button.add_theme_stylebox_override("hover", _gender_button_hover_shadow)
	button.add_theme_stylebox_override("pressed", _gender_button_pressed_shadow)
	button.add_theme_stylebox_override("focus", _gender_button_hover_shadow)
	button.add_theme_stylebox_override("hover_pressed", _gender_button_pressed_shadow)

	button.self_modulate = Color(GENDER_BUTTON_BRIGHTNESS_NORMAL, GENDER_BUTTON_BRIGHTNESS_NORMAL, GENDER_BUTTON_BRIGHTNESS_NORMAL, 1.0)
	if button.has_method("set_icon_offset"):
		button.set_icon_offset(Vector2(0.0, GENDER_BUTTON_ICON_Y_NORMAL))

	button.mouse_entered.connect(_on_gender_button_hover.bind(button))
	button.mouse_exited.connect(_on_gender_button_unhover.bind(button))
	button.focus_entered.connect(_on_gender_button_hover.bind(button))
	button.focus_exited.connect(_on_gender_button_unhover.bind(button))
	button.button_down.connect(_on_gender_button_pressed.bind(button))
	button.button_up.connect(_on_gender_button_released.bind(button))

func _build_gender_shadow_style(size: int, color: Color, offset: Vector2) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.shadow_size = size
	style.shadow_color = color
	style.shadow_offset = offset
	return style

func _on_gender_button_hover(button: Button) -> void:
	if button.is_pressed():
		return
	_animate_gender_button(button, GENDER_BUTTON_BRIGHTNESS_HOVER, GENDER_BUTTON_ICON_Y_HOVER)

func _on_gender_button_unhover(button: Button) -> void:
	if button.is_pressed():
		return
	_animate_gender_button(button, GENDER_BUTTON_BRIGHTNESS_NORMAL, GENDER_BUTTON_ICON_Y_NORMAL)

func _on_gender_button_pressed(button: Button) -> void:
	_animate_gender_button(button, GENDER_BUTTON_BRIGHTNESS_PRESSED, GENDER_BUTTON_ICON_Y_PRESSED)

func _on_gender_button_released(button: Button) -> void:
	if button.is_hovered() or button.has_focus():
		_animate_gender_button(button, GENDER_BUTTON_BRIGHTNESS_HOVER, GENDER_BUTTON_ICON_Y_HOVER)
	else:
		_animate_gender_button(button, GENDER_BUTTON_BRIGHTNESS_NORMAL, GENDER_BUTTON_ICON_Y_NORMAL)

func _animate_gender_button(button: Button, brightness: float, icon_y: float) -> void:
	var tween := button.create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "self_modulate", Color(brightness, brightness, brightness, 1.0), GENDER_BUTTON_TWEEN_DURATION)
	if button.has_method("set_icon_offset"):
		tween.tween_property(button, "icon_offset", Vector2(0.0, icon_y), GENDER_BUTTON_TWEEN_DURATION)

func _refresh_random_name() -> void:
	if character_name.text.strip_edges().is_empty():
		character_name.text = _generate_random_name()

func _set_gender(is_female: bool) -> void:
	_is_female = is_female
	character_name.text = _generate_random_name()

func _generate_random_name() -> String:
	var pool := FEMALE_NAME_POOL if _is_female else MALE_NAME_POOL
	if pool.is_empty():
		return ""
	return pool[_rng.randi_range(0, pool.size() - 1)]

func _on_name_changed(_new_text: String) -> void:
	for curr_idx in AMOUNT_OF_IMAGES:
		_colors[curr_idx].z = 1

	var dir := DirAccess.open(beard_dir)
	for curr_file in dir.get_files():
		if !curr_file.ends_with(".png"):
			continue
		_available_beards.append(load(beard_dir + curr_file))

func _on_resend_images() -> void:
	_images[Images.PORTRAIT] = portrait
	_images[Images.BEARD] = beard
	_images[Images.HAIR] = hair

	var shader: ShaderMaterial = target_render.material
	shader.set_shader_parameter(&"images", _images)

func _on_color_changed(value: float, type: Images) -> void:
	_colors[type].x = value
	var shader: ShaderMaterial = target_render.material
	shader.set_shader_parameter(&"colors", _colors)

func swap_color(type: Images) -> void:
	_selected = type
	var shader: ShaderMaterial = target_render.material
	shader.set_shader_parameter(&"colors", _colors)

func _on_gamma_changed(value: float) -> void:
	_colors[_selected].z = value
	var shader: ShaderMaterial = target_render.material
	shader.set_shader_parameter(&"colors", _colors)

func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

func _on_create_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/embark_preparation.tscn")

func _on_randomize_button_pressed() -> void:
	if profession_choice and profession_choice.item_count > 0:
		profession_choice.select(_rng.randi_range(0, profession_choice.item_count - 1))
	if clan_name and clan_name.item_count > 0:
		clan_name.select(_rng.randi_range(0, clan_name.item_count - 1))
	if skin_color:
		skin_color.value = _rng.randf_range(skin_color.min_value, skin_color.max_value)
	if eye_color:
		eye_color.value = _rng.randf_range(eye_color.min_value, eye_color.max_value)

	character_name.text = _generate_random_name()
