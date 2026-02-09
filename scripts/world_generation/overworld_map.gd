extends Node2D

@export var map_size: Vector2i = Vector2i(256, 256)
@export var water_level: float = 0.45
@export var falloff_strength: float = 0.55
@export var falloff_power: float = 2.4
@export var noise_frequency: float = 2.0
@export var noise_octaves: int = 4
@export var hill_level: float = 0.72
@export var mountain_level: float = 0.82
@export var landmass_center_count: int = 4
@export var landmass_center_margin: float = 0.12
@export var landmass_falloff_scale: float = 1.35
@export var landmass_mask_strength: float = 0.55
@export var landmass_mask_power: float = 0.82
@export var temperature_frequency: float = 1.2
@export var rainfall_frequency: float = 1.7
@export var map_seed: int = 0
@export var tile_size: int = 32
@export var globe_rotation_speed: float = 0.25
@export_range(0.0, 1.0, 0.01) var iceberg_temperature_threshold: float = 0.32
@export_range(0.0, 1.0, 0.01) var iceberg_density: float = 0.12
@export var iceberg_tile_options: Array[Vector2i] = [Vector2i(4, 3), Vector2i(5, 3)]

@export_group("Biomes")
@export_range(0.0, 1.0, 0.01) var tundra_threshold: float = 0.28
@export_range(0.0, 1.0, 0.01) var desert_threshold: float = 0.25
@export_range(0.0, 0.4, 0.01) var desert_temperature_bias: float = 0.08
@export_range(0.0, 0.4, 0.01) var desert_moisture_bias: float = 0.08
@export_range(0.0, 1.0, 0.01) var badlands_threshold: float = 0.4
@export_range(0.0, 1.0, 0.01) var forest_threshold: float = 0.6
@export_range(0.0, 1.0, 0.01) var jungle_threshold: float = 0.75
@export_range(0.0, 1.0, 0.01) var marsh_threshold: float = 0.68
@export_range(0.0, 1.0, 0.01) var hot_threshold: float = 0.7
@export_range(0.0, 1.0, 0.01) var warm_threshold: float = 0.55

const MASK_TWIN_LEFT_CENTER := Vector2(0.32, 0.48)
const MASK_TWIN_RIGHT_CENTER := Vector2(0.68, 0.52)
const MASK_TWIN_RADIUS := Vector2(0.55, 0.33)
const MASK_SADDLE_SCALE := 2.2

const ATLAS_TEXTURE := "res://resources/images/overworld/atlas/overworld.png"
const SAND_TILE := Vector2i(0, 0)
const GRASS_TILE := Vector2i(1, 0)
const BADLANDS_TILE := Vector2i(2, 1)
const MINE_TILE := Vector2i(3, 1)
const MARSH_TILE := Vector2i(2, 4)
const SNOW_TILE := Vector2i(3, 2)
const TREE_TILE := Vector2i(0, 1)
const TREE_LONE_TILE := Vector2i(6, 5)
const JUNGLE_TREE_TILE := Vector2i(0, 3)
const CUT_TREES_TILE := Vector2i(1, 5)
const AMBIENT_LUMBER_MILL_TILE := Vector2i(0, 5)
const WATER_TILE := Vector2i(4, 1)
const MOUNTAIN_TILE := Vector2i(3, 0)
const MOUNTAIN_TOP_A_TILE := Vector2i(4, 0)
const MOUNTAIN_TOP_B_TILE := Vector2i(5, 0)
const MOUNTAIN_BOTTOM_A_TILE := Vector2i(7, 0)
const MOUNTAIN_BOTTOM_B_TILE := Vector2i(8, 0)
const DAM_TILE := Vector2i(8, 1)
const MOUNTAIN_PEAK_TILE := Vector2i(10, 0)
const STONE_TILE := Vector2i(2, 0)
const DWARFHOLD_TILE := Vector2i(9, 2)
const ABANDONED_DWARFHOLD_TILE := Vector2i(8, 2)
const GREAT_DWARFHOLD_TILE := Vector2i(6, 0)
const DARK_DWARFHOLD_TILE := Vector2i(17, 0)
const HILLHOLD_TILE := Vector2i(7, 4)
const CAVE_TILE := Vector2i(5, 1)
const TOWER_TILE := Vector2i(6, 1)
const EVIL_WIZARDS_TOWER_TILE := Vector2i(3, 3)
const WOOD_ELF_GROVES_TILE := Vector2i(4, 2)
const WOOD_ELF_GROVES_LARGE_TILE := Vector2i(5, 2)
const WOOD_ELF_GROVES_GRAND_TILE := Vector2i(6, 2)
const HILLS_TILE := Vector2i(1, 3)
const HILLS_BADLANDS_TILE := Vector2i(1, 4)
const HILLS_VARIANT_A_TILE := Vector2i(4, 4)
const HILLS_VARIANT_B_TILE := Vector2i(2, 5)
const HILLS_SNOW_TILE := Vector2i(2, 3)
const TOWN_TILE := Vector2i(1, 2)
const PORT_TOWN_TILE := Vector2i(5, 4)
const CASTLE_TILE := Vector2i(6, 4)
const ROADSIDE_TAVERN_TILE := Vector2i(12, 1)
const HAMLET_TILE := Vector2i(16, 1)
const TREE_SNOW_TILE := Vector2i(1, 1)
const ACTIVE_VOLCANO_TILE := Vector2i(12, 2)
const VOLCANO_TILE := Vector2i(13, 2)
const LAVA_TILE := Vector2i(14, 2)
const OASIS_TILE := Vector2i(12, 0)
const HAMLET_SNOW_TILE := Vector2i(13, 0)
const AMBIENT_SLEEPING_DRAGON_TILE := Vector2i(14, 0)
const AMBIENT_HUNTING_LODGE_TILE := Vector2i(16, 0)
const AMBIENT_HOMESTEAD_TILE := Vector2i(13, 1)
const AMBIENT_MOONWELL_TILE := Vector2i(2, 5)
const AMBIENT_FARM_TILE := Vector2i(15, 1)
const FARM_CROPS_TILE := Vector2i(15, 0)
const AMBIENT_FARM_VARIANT_TILE := Vector2i(15, 0)
const AMBIENT_GREAT_TREE_TILE := Vector2i(14, 1)
const AMBIENT_GREAT_TREE_ALT_TILE := Vector2i(14, 2)
const LIZARDMEN_CITY_TILE := Vector2i(11, 2)
const SAINT_SHRINE_TILE := Vector2i(11, 1)
const MONASTERY_TILE := Vector2i(2, 2)
const ORC_CAMP_TILE := Vector2i(11, 3)
const GNOLL_CAMP_TILE := Vector2i(1, 5)
const TROLL_CAMP_TILE := Vector2i(1, 5)
const OGRE_CAMP_TILE := Vector2i(1, 5)
const BANDIT_CAMP_TILE := Vector2i(1, 5)
const TRAVELERS_CAMP_TILE := Vector2i(1, 5)
const DUNGEON_TILE := Vector2i(7, 2)
const CENTAUR_ENCAMPMENT_TILE := Vector2i(10, 2)
const BIOME_WATER := "water"
const BIOME_MOUNTAIN := "mountain"
const BIOME_HILLS := "hills"
const BIOME_MARSH := "marsh"
const BIOME_TUNDRA := "tundra"
const BIOME_DESERT := "desert"
const BIOME_BADLANDS := "badlands"
const BIOME_FOREST := "forest"
const BIOME_JUNGLE := "jungle"
const BIOME_GRASSLAND := "grassland"
const DWARFHOLD_LOGIC := preload("res://scripts/world_generation/dwarfhold_logic.gd")

const SETTLEMENT_TILES := {
	"dwarfhold": [DWARFHOLD_TILE, ABANDONED_DWARFHOLD_TILE, GREAT_DWARFHOLD_TILE, DARK_DWARFHOLD_TILE],
	"town": [TOWN_TILE, PORT_TOWN_TILE, CASTLE_TILE, HAMLET_TILE],
	"woodElfGrove": [WOOD_ELF_GROVES_TILE, WOOD_ELF_GROVES_LARGE_TILE, WOOD_ELF_GROVES_GRAND_TILE],
	"lizardmenCity": [LIZARDMEN_CITY_TILE]
}

const SETTLEMENT_NAMES := {
	"dwarves": "Dwarven Hold",
	"humans": "Town",
	"wood_elves": "Grove",
	"lizardmen": "Lizard City"
}
const DWARFHOLD_NAMES: Array[String] = [
	"Khazadûn Kharn",
	"Dhurnomli Bûr",
	"Zarak-az-Garaz",
	"Barûn-karag",
	"Gundûm Garmak",
	"Azar-khazad",
	"Thûrdrim Duraz",
	"Kazad-grimil",
	"Bêrdûm Barak",
	"Zirak-khazad",
	"Uzbad-az-Narg",
	"Karag Gor",
	"Dûmthûr Mîn",
	"Gûndâl Grum",
	"Thrâng-khazad",
	"Khirûn-karag",
	"Gazad-az-Bôr",
	"Dûrgrim Dûm",
	"Bazâr-durin",
	"Kharak-khazad",
	"Thûrdûn Thrum",
	"Gazûl-dûm",
	"Gor Dûrgheled",
	"Khûrmak Dûm",
	"Barak-dûrûn",
	"Gadrin-karag",
	"Mornûl Khazad",
	"Tharûm Barûn",
	"Dûr-az-Gor",
	"Kûzad Thrang",
	"Grumkhaz Dûm",
	"Narûm-barak",
	"Khûldar Narg",
	"Azûl-az-Khazad",
	"Dûmthrûn Garaz",
	"Grom-dûrin",
	"Khazdûl Garm",
	"Burin-dûm",
	"Zarak-nâl",
	"Thuldûn Karag",
	"Durgrûn Khazad",
	"Garak-dûm",
	"Tharn-az-Dûr",
	"Kharûm Grimdûm",
	"Balzûr Karûn",
	"Mûrkhaz Barak",
	"Thrûm-az-Garaz",
	"Gundûl-dûm",
	"Bârgrin Khazad",
	"Dûmbar Thûr",
	"Nûrgrim Karag",
	"Thûlûm Dûrûn",
	"Kharn-dûm-nâl",
	"Throgar-Mâl",
	"Krundûn Barak",
	"Dûrkhal Varrum",
	"Ghazdûr Grimbar",
	"Kuldûn-Dûr",
	"Brakûl Thrang",
	"Zarnak-dûm",
	"Throldar Kharn",
	"Mûldûn Grakhaz",
	"Durmûr Barûn",
	"Merûn Barin",
	"Dûldar Harnûm",
	"Bronarûm",
	"Kharalûn Dûr",
	"Garûn-kaz",
	"Thûrli Barûn",
	"Balnar Dûm",
	"Orûn Khazal",
	"Dûmren Thûr",
	"Beldûr Karûn",
	"Uldûm Nargaz",
	"Khardûl Barzûn",
	"Thûrkûn-Môr",
	"Zuldarûn",
	"Dûrthang Kharûz",
	"Brûm-dûl",
	"Gûldûn Thazrak",
	"Khazûr-Dumli",
	"Thrûnûl Barûz",
	"Mûrzan-Dûm",
	"Grendûl Varrin",
	"Kharnfell",
	"Dûmholm",
	"Barakdel",
	"Thûrdûn Holdfast",
	"Gromir Karûn",
	"Kharûm Tor",
	"Thulgar's Deep",
	"Brumkeldûm",
	"Dûrmar Hollow",
	"the Great Halls of Thorbardin",
	"Hammerguard",
	"Gor Karakazol",
	"Dur-Vazhatun",
	"Throal",
	"Dun-Ôrdstun",
	"Dûrandur",
	"Black Rock Hold",
	"Barat Nûmenz",
	"Dun Toruhm",
	"Karad-Graef",
	"Dûmthûr Mînrth",
	"Y'olazad-az-Bôr",
	"Gor Dûrgheld",
	"Dwemerhelm",
	"Tuwad-Dhumakon",
	"Skomdihir",
	"Hul-Jorkad",
	"Hul-Az-Krakazol",
	"Ovdal-az-An",
	"Orocarni",
	"Dun-Gardro",
	"Azrak Ordrim",
	"Dal Dulrah",
	"Dungrum",
	"Dun'ragram",
	"Karak Isural",
	"Sinterholm",
	"Karak-Dûmankon",
	"Grozumdihr",
	"Gor Ozumbrog",
	"Azad-Khas",
	"Karag Burag",
	"Hul-Kargdrum",
	"Karak-Duraz",
	"Tharn Khazrim",
	"Karak Grumdril",
	"Mirabar",
	"Dun Ashborun",
	"Avlar-Thrûn",
	"Grom's Peak",
	"Karak Gorûmzra",
	"Ostapchuk",
	"Dammerhall",
	"Almharaz",
	"Haraz Oldrum",
	"Elaig Drum",
	"Karak Ozambrald",
	"Ironhold",
	"Alvar-Baroag",
	"Ondrehrdin",
	"Azrak Zarak",
	"Dun Ezmar",
	"Azgark Metzger"
]

const TREE_BIOMES: Array[String] = [
	BIOME_FOREST,
	BIOME_JUNGLE,
	BIOME_TUNDRA
]
const TREE_BASE_BIOMES: Array[String] = [
	BIOME_GRASSLAND,
	BIOME_TUNDRA
]

@onready var map_layer: TileMapLayer = $MapLayer
@onready var tree_layer: TileMapLayer = get_node_or_null("TreeLayer")
@onready var highland_layer: TileMapLayer = get_node_or_null("HighlandLayer")
@onready var iceberg_layer: TileMapLayer = get_node_or_null("IcebergLayer")
@onready var settlement_layer: TileMapLayer = get_node_or_null("SettlementLayer")
@onready var map_overlays: Node2D = get_node_or_null("MapOverlays")
@onready var elevation_overlay: Sprite2D = get_node_or_null("MapOverlays/ElevationOverlay")
@onready var temperature_overlay: Sprite2D = get_node_or_null("MapOverlays/TemperatureOverlay")
@onready var moisture_overlay: Sprite2D = get_node_or_null("MapOverlays/MoistureOverlay")
@onready var biome_overlay: Sprite2D = get_node_or_null("MapOverlays/BiomeOverlay")
@onready var overworld_camera: OverworldCamera = get_node_or_null("OverworldCamera")
@onready var globe_view: Node3D = get_node_or_null("GlobeView")
@onready var globe_camera: Camera3D = get_node_or_null("GlobeView/GlobeCamera")
@onready var globe_mesh: MeshInstance3D = get_node_or_null("GlobeView/GlobeMesh")
@onready var map_viewport: SubViewport = get_node_or_null("MapViewport")
@onready var map_viewport_root: Node2D = get_node_or_null("MapViewport/MapViewportRoot")
@onready var regenerate_button: Button = get_node_or_null("MapUi/TopBar/TopBarLayout/RegenerateButton")
@onready var globe_view_button: Button = get_node_or_null("MapUi/TopBar/TopBarLayout/GlobeViewButton")
@onready var temperature_map_button: Button = get_node_or_null("MapUi/TopBar/TopBarLayout/TemperatureMapButton")
@onready var elevation_map_button: Button = get_node_or_null("MapUi/TopBar/TopBarLayout/ElevationMapButton")
@onready var moisture_map_button: Button = get_node_or_null("MapUi/TopBar/TopBarLayout/MoistureMapButton")
@onready var biome_map_button: Button = get_node_or_null("MapUi/TopBar/TopBarLayout/BiomeMapButton")
@onready var loading_screen: Control = get_node_or_null("MapUi/LoadingScreen")
@onready var tooltip_panel: PanelContainer = get_node_or_null("MapUi/MapTooltip")
@onready var tooltip_title: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipTitle")
@onready var tooltip_biome: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipBiome")
@onready var tooltip_climate: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipClimate")
@onready var tooltip_resources: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipResources")

var _atlas_source_id := -1
var _temperature_noise: FastNoiseLite
var _rainfall_noise: FastNoiseLite
var _vegetation_noise: FastNoiseLite
var _tile_data: Dictionary = {}
var _height_map: Dictionary = {}
var _temperature_map: Dictionary = {}
var _moisture_map: Dictionary = {}
var _biome_map: Dictionary = {}
var _world_settings: Dictionary = {}
var _landmass_centers: Array[Vector2] = []
var _map_layer_original_parent: Node = null
var _map_layer_original_index := -1
var _tree_layer_original_parent: Node = null
var _tree_layer_original_index := -1
var _highland_layer_original_parent: Node = null
var _highland_layer_original_index := -1
var _iceberg_layer_original_parent: Node = null
var _iceberg_layer_original_index := -1
var _settlement_layer_original_parent: Node = null
var _settlement_layer_original_index := -1
var _overlays_original_parent: Node = null
var _overlays_original_index := -1
var _is_globe_view := false
var _elevation_overlay_enabled := false
var _temperature_overlay_enabled := false
var _moisture_overlay_enabled := false
var _biome_overlay_enabled := false
var _hovered_tile := Vector2i(-999, -999)

func _ready() -> void:
	if map_layer == null:
		push_error("Overworld map is missing a TileMapLayer named MapLayer.")
		return
	_show_loading_screen()
	await get_tree().process_frame
	_apply_cached_world_settings()
	_configure_tileset()
	await _generate_map()
	_hide_loading_screen()
	if regenerate_button == null:
		push_error("Overworld map is missing a RegenerateButton at MapUi/TopBar/TopBarLayout/RegenerateButton.")
	else:
		regenerate_button.pressed.connect(_on_regenerate_pressed)
	if globe_view_button != null:
		globe_view_button.toggled.connect(_on_globe_view_toggled)
		globe_view_button.button_pressed = false
	if temperature_map_button != null:
		temperature_map_button.toggled.connect(_on_temperature_map_toggled)
		temperature_map_button.button_pressed = false
	if elevation_map_button != null:
		elevation_map_button.toggled.connect(_on_elevation_map_toggled)
		elevation_map_button.button_pressed = false
	if moisture_map_button != null:
		moisture_map_button.toggled.connect(_on_moisture_map_toggled)
		moisture_map_button.button_pressed = false
	if biome_map_button != null:
		biome_map_button.toggled.connect(_on_biome_map_toggled)
		biome_map_button.button_pressed = false
	_cache_map_layer_parent()
	_cache_tree_layer_parent()
	_cache_highland_layer_parent()
	_cache_iceberg_layer_parent()
	_cache_settlement_layer_parent()
	_cache_overlay_parent()
	_configure_globe_viewport()
	_set_globe_view(false)

func _show_loading_screen() -> void:
	if loading_screen != null:
		loading_screen.visible = true

func _hide_loading_screen() -> void:
	if loading_screen != null:
		loading_screen.visible = false

func _process(delta: float) -> void:
	_update_map_tooltip()
	if _is_globe_view:
		_rotate_globe(delta)

func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed:
		return
	if key_event.keycode == KEY_R:
		await _regenerate_map()

func _on_regenerate_pressed() -> void:
	await _regenerate_map()

func _on_globe_view_toggled(is_pressed: bool) -> void:
	_set_globe_view(is_pressed)

func _on_temperature_map_toggled(is_pressed: bool) -> void:
	_temperature_overlay_enabled = is_pressed
	_update_temperature_overlay_visibility()

func _on_elevation_map_toggled(is_pressed: bool) -> void:
	_elevation_overlay_enabled = is_pressed
	_update_elevation_overlay_visibility()

func _on_moisture_map_toggled(is_pressed: bool) -> void:
	_moisture_overlay_enabled = is_pressed
	_update_moisture_overlay_visibility()

func _on_biome_map_toggled(is_pressed: bool) -> void:
	_biome_overlay_enabled = is_pressed
	_update_biome_overlay_visibility()

func _regenerate_map() -> void:
	_show_loading_screen()
	await get_tree().process_frame
	map_seed = 0
	await _generate_map()
	_hide_loading_screen()

func _generate_map() -> void:
	if map_layer == null:
		push_error("Overworld map is missing a TileMapLayer named MapLayer.")
		return
	if map_layer.tile_set == null:
		_configure_tileset()
	if tree_layer != null and tree_layer.tile_set == null and map_layer.tile_set != null:
		tree_layer.tile_set = map_layer.tile_set
	if _atlas_source_id < 0:
		push_error("Overworld map tileset is missing a valid atlas source.")
		return
	map_layer.clear()
	if tree_layer != null:
		tree_layer.clear()
	if highland_layer != null:
		highland_layer.clear()
	if iceberg_layer != null:
		iceberg_layer.clear()
	if settlement_layer != null:
		settlement_layer.clear()
	_tile_data.clear()

	var height_map: Dictionary = {}
	var temperature_map: Dictionary = {}
	var moisture_map: Dictionary = {}
	var vegetation_map: Dictionary = {}
	var base_biome_map: Dictionary = {}
	var highland_map: Dictionary = {}

	var rng := RandomNumberGenerator.new()
	if map_seed == 0:
		rng.randomize()
		map_seed = rng.randi()
	else:
		rng.seed = map_seed
	_configure_landmass_centers(rng)

	var continent_noise := FastNoiseLite.new()
	continent_noise.seed = map_seed
	continent_noise.frequency = (noise_frequency * 0.35) / float(map_size.x)
	continent_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	continent_noise.fractal_octaves = maxi(4, noise_octaves)
	continent_noise.fractal_lacunarity = 2.1
	continent_noise.fractal_gain = 0.52
	continent_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

	var detail_noise := FastNoiseLite.new()
	detail_noise.seed = map_seed + 37
	detail_noise.frequency = (noise_frequency * 2.2) / float(map_size.x)
	detail_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	detail_noise.fractal_octaves = 4
	detail_noise.fractal_lacunarity = 2.3
	detail_noise.fractal_gain = 0.55
	detail_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

	var ridge_noise := FastNoiseLite.new()
	ridge_noise.seed = map_seed + 83
	ridge_noise.frequency = (noise_frequency * 1.1) / float(map_size.x)
	ridge_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	ridge_noise.fractal_octaves = 3
	ridge_noise.fractal_lacunarity = 2.0
	ridge_noise.fractal_gain = 0.6
	ridge_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

	_temperature_noise = FastNoiseLite.new()
	_temperature_noise.seed = map_seed + 101
	_temperature_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_temperature_noise.frequency = temperature_frequency / float(map_size.x)
	_temperature_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	_temperature_noise.fractal_octaves = 3

	_rainfall_noise = FastNoiseLite.new()
	_rainfall_noise.seed = map_seed + 211
	_rainfall_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_rainfall_noise.frequency = rainfall_frequency / float(map_size.x)
	_rainfall_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	_rainfall_noise.fractal_octaves = 4

	_vegetation_noise = FastNoiseLite.new()
	_vegetation_noise.seed = map_seed + 317
	_vegetation_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_vegetation_noise.frequency = (noise_frequency * 2.8) / float(map_size.x)
	_vegetation_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	_vegetation_noise.fractal_octaves = 3

	for y in range(map_size.y):
		for x in range(map_size.x):
			var height := _sample_height(continent_noise, detail_noise, ridge_noise, x, y)
			var coord := Vector2i(x, y)
			height_map[coord] = height

	_smooth_height_map(height_map, 1, 0.35)

	var landmass_denom_x := maxf(1.0, float(map_size.x - 1))
	var landmass_denom_y := maxf(1.0, float(map_size.y - 1))
	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord := Vector2i(x, y)
			var nx := float(x) / landmass_denom_x
			var ny := float(y) / landmass_denom_y
			var height: float = height_map[coord]
			var temperature := _sample_temperature(x, y, height)
			var moisture := _sample_moisture(x, y, height)
			var vegetation := _sample_vegetation(x, y, height, moisture, temperature)
			temperature_map[coord] = temperature
			moisture_map[coord] = moisture
			vegetation_map[coord] = vegetation

	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord := Vector2i(x, y)
			var height: float = height_map[coord]
			var temperature: float = temperature_map[coord]
			var moisture: float = moisture_map[coord]
			base_biome_map[coord] = _assign_base_biome(coord, height, temperature, moisture, height_map)

	_smooth_biomes(base_biome_map, 2)
	if _count_biome(base_biome_map, BIOME_DESERT) == 0:
		_seed_desert_biomes(base_biome_map, temperature_map, moisture_map, height_map)
		_smooth_biomes(base_biome_map, 1)
	var tree_biome_map: Dictionary = base_biome_map.duplicate()
	var tree_map := _apply_tree_overlays(
		tree_biome_map,
		temperature_map,
		moisture_map,
		vegetation_map,
		height_map
	)
	highland_map = _build_highland_overlays(base_biome_map, height_map)
	var biome_map: Dictionary = tree_biome_map.duplicate()
	for coord: Vector2i in highland_map.keys():
		biome_map[coord] = highland_map[coord]

	_apply_base_tiles(base_biome_map)
	await _yield_generation_wave()
	_apply_tree_tiles(tree_map, base_biome_map)
	_apply_overlays_and_metadata(base_biome_map, biome_map, highland_map, temperature_map, moisture_map)
	await _yield_generation_wave()
	_place_icebergs(base_biome_map, temperature_map, height_map, rng)
	await _yield_generation_wave()
	_place_settlements(biome_map, rng)
	_height_map = height_map.duplicate()
	_temperature_map = temperature_map.duplicate()
	_moisture_map = moisture_map.duplicate()
	_biome_map = biome_map.duplicate()
	_update_elevation_overlay()
	_update_temperature_overlay()
	_update_moisture_overlay()
	_update_biome_overlay()
	_configure_globe_viewport()
	_configure_overworld_camera_bounds()
	if _is_globe_view:
		_update_globe_texture()

func _apply_base_tiles(base_biome_map: Dictionary) -> void:
	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord := Vector2i(x, y)
			var base_biome := base_biome_map.get(coord, BIOME_GRASSLAND) as String
			var tile_coords := _biome_to_tile(base_biome)
			map_layer.set_cell(coord, _atlas_source_id, tile_coords)

func _apply_overlays_and_metadata(
	base_biome_map: Dictionary,
	biome_map: Dictionary,
	highland_map: Dictionary,
	temperature_map: Dictionary,
	moisture_map: Dictionary
) -> void:
	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord := Vector2i(x, y)
			var base_biome := base_biome_map.get(coord, BIOME_GRASSLAND) as String
			if highland_layer != null:
				if highland_map.has(coord):
					var highland_biome := highland_map[coord] as String
					var highland_tile := _highland_tile_for_biome(highland_biome, base_biome)
					highland_layer.set_cell(coord, _atlas_source_id, highland_tile)
				else:
					highland_layer.erase_cell(coord)
			var biome := biome_map.get(coord, base_biome) as String
			_tile_data[coord] = {
				"biome_type": biome,
				"temperature": temperature_map.get(coord, 0.0),
				"moisture": moisture_map.get(coord, 0.0),
				"resources": _resources_for_biome(biome),
				"region_name": ""
			}

func _highland_tile_for_biome(highland_biome: String, base_biome: String) -> Vector2i:
	if highland_biome == BIOME_HILLS and base_biome == BIOME_TUNDRA:
		return Vector2i(HILLS_TILE.x + 1, HILLS_TILE.y)
	return _biome_to_tile(highland_biome)

func _yield_generation_wave() -> void:
	if is_inside_tree():
		await get_tree().process_frame

func _sample_height(
	continent_noise: FastNoiseLite,
	detail_noise: FastNoiseLite,
	ridge_noise: FastNoiseLite,
	x: int,
	y: int
) -> float:
	var nx := (float(x) / float(map_size.x)) * 2.0 - 1.0
	var ny := (float(y) / float(map_size.y)) * 2.0 - 1.0
	var distance := _distance_to_nearest_landmass_center(nx, ny)
	var scaled_distance := clampf(distance / maxf(0.01, landmass_falloff_scale), 0.0, 1.0)
	var falloff := pow(scaled_distance, falloff_power) * falloff_strength
	var continent := _to_normalized(continent_noise.get_noise_2d(float(x), float(y)))
	var detail := _to_normalized(detail_noise.get_noise_2d(float(x), float(y)))
	var ridges := 1.0 - absf(ridge_noise.get_noise_2d(float(x), float(y)))
	var height := continent * 0.72 + detail * 0.18 + ridges * 0.1
	var archipelago := (_to_normalized(detail_noise.get_noise_2d(float(x) * 2.6, float(y) * 2.6)) - 0.5) * 0.12
	height += archipelago
	var continent_bias := _sample_continent_bias(x, y)
	height += continent_bias - falloff
	var coast_mask := 1.0 - clampf(absf(height - water_level) / 0.15, 0.0, 1.0)
	var coast_jag := detail_noise.get_noise_2d(float(x) * 5.1, float(y) * 5.1) * 0.06 * coast_mask
	return clampf(height + coast_jag, 0.0, 1.0)


func _sample_continent_bias(x: int, y: int) -> float:
	var denom_x := maxf(1.0, float(map_size.x - 1))
	var denom_y := maxf(1.0, float(map_size.y - 1))
	var nx := float(x) / denom_x
	var ny := float(y) / denom_y
	var mask_value := _sample_landmass_mask(nx, ny)
	var base_bias := (mask_value - 0.5) * landmass_mask_strength
	var ocean_weight := clampf(1.0 - mask_value * 1.25, 0.0, 1.0)
	var base_seed := map_seed + 0x6a09e667
	var fractal := (_value_noise(nx * 18.0 + 2.3, ny * 18.0 + 9.7, base_seed) - 0.5) * 0.18
	fractal += (_value_noise(nx * 42.0 + 13.1, ny * 42.0 + 5.4, base_seed + 0xbb67ae85) - 0.5) * 0.08
	var ocean_boost := fractal * ocean_weight
	return base_bias + ocean_boost


func _configure_landmass_centers(rng: RandomNumberGenerator) -> void:
	_landmass_centers.clear()
	var count := maxi(1, landmass_center_count)
	var margin := clampf(landmass_center_margin, 0.0, 0.45)
	for _i in range(count):
		var cx := rng.randf_range(-1.0 + margin, 1.0 - margin)
		var cy := rng.randf_range(-1.0 + margin, 1.0 - margin)
		_landmass_centers.append(Vector2(cx, cy))


func _distance_to_nearest_landmass_center(nx: float, ny: float) -> float:
	if _landmass_centers.is_empty():
		return Vector2(nx, ny).length()
	var sample_pos := Vector2(nx, ny)
	var min_distance := INF
	for center: Vector2 in _landmass_centers:
		min_distance = minf(min_distance, sample_pos.distance_to(center))
	return min_distance


func _smooth_height_map(height_map: Dictionary, passes: int, strength: float) -> void:
	for _pass_index in range(passes):
		var next_map := height_map.duplicate()
		for coord: Vector2i in height_map.keys():
			var current: float = height_map.get(coord, 0.0)
			var is_land := current >= water_level
			var accum := current
			var count := 1
			for offset: Vector2i in [
				Vector2i.LEFT,
				Vector2i.RIGHT,
				Vector2i.UP,
				Vector2i.DOWN,
				Vector2i(-1, -1),
				Vector2i(1, -1),
				Vector2i(-1, 1),
				Vector2i(1, 1)
			]:
				var neighbor := coord + offset
				var neighbor_height: float = height_map.get(neighbor, current)
				if is_land and neighbor_height < water_level:
					continue
				if not is_land and neighbor_height >= water_level:
					continue
				accum += neighbor_height
				count += 1
			var average := accum / float(count)
			next_map[coord] = lerpf(current, average, strength)
		height_map.clear()
		for coord: Vector2i in next_map.keys():
			height_map[coord] = next_map[coord]


func _sample_landmass_mask(nx: float, ny: float) -> float:
	var left := _ellipse_distance(nx, ny, MASK_TWIN_LEFT_CENTER, MASK_TWIN_RADIUS)
	var right := _ellipse_distance(nx, ny, MASK_TWIN_RIGHT_CENTER, MASK_TWIN_RADIUS)
	var value := 1.0 - minf(left, right)
	value = pow(clampf(value, 0.0, 1.0), landmass_mask_power)
	var saddle := cos((ny - 0.5) * PI * MASK_SADDLE_SCALE) * 0.05
	var base_seed := map_seed + 0x9e3779b
	var noise := (_value_noise(nx * 12.5 + 3.1, ny * 12.5 + 7.9, base_seed) - 0.5) * 0.12
	var detail := (_value_noise(nx * 34.2 + 11.3, ny * 34.2 + 4.6, base_seed + 0x85ebca6) - 0.5) * 0.06
	value += saddle + noise + detail
	return clampf(value, 0.0, 1.0)


func _ellipse_distance(nx: float, ny: float, center: Vector2, radius: Vector2) -> float:
	var dx := (nx - center.x) / maxf(0.001, radius.x)
	var dy := (ny - center.y) / maxf(0.001, radius.y)
	return sqrt(dx * dx + dy * dy)


func _value_noise(x: float, y: float, seed_value: int) -> float:
	var x0 := floori(x)
	var y0 := floori(y)
	var x1 := x0 + 1
	var y1 := y0 + 1
	var sx := _fade(x - float(x0))
	var sy := _fade(y - float(y0))
	var n00 := _hash_coords(x0, y0, seed_value)
	var n10 := _hash_coords(x1, y0, seed_value)
	var n01 := _hash_coords(x0, y1, seed_value)
	var n11 := _hash_coords(x1, y1, seed_value)
	var ix0 := lerpf(n00, n10, sx)
	var ix1 := lerpf(n01, n11, sx)
	return lerpf(ix0, ix1, sy)


func _hash_coords(x: int, y: int, seed_value: int) -> float:
	var h := (x * 374761393) ^ (y * 668265263) ^ seed_value
	h = int(h ^ (h >> 13)) * 1274126177
	h = h ^ (h >> 16)
	var unsigned := h & 0xffffffff
	return float(unsigned) / 4294967295.0


func _fade(t: float) -> float:
	return t * t * t * (t * (t * 6.0 - 15.0) + 10.0)


func _to_normalized(noise_sample: float) -> float:
	return clampf((noise_sample + 1.0) * 0.5, 0.0, 1.0)


func _sample_temperature(x: int, y: int, elevation: float) -> float:
	var latitude := absf((float(y) / maxf(1.0, float(map_size.y - 1))) * 2.0 - 1.0)
	var latitudinal_cold := pow(latitude, 1.4)
	var base_variation := _to_normalized(_temperature_noise.get_noise_2d(float(x), float(y)))
	var detail_variation := _to_normalized(_temperature_noise.get_noise_2d(float(x) * 2.1, float(y) * 2.1))
	var layered_noise := base_variation * 0.7 + detail_variation * 0.3
	var north_bias := pow(1.0 - (float(y) / maxf(1.0, float(map_size.y - 1))), 1.35) * 0.22
	var above_sea := maxf(0.0, elevation - water_level)
	var elevation_cooling := above_sea * 0.9
	return clampf((layered_noise * 0.55 + (1.0 - latitudinal_cold) * 0.45) - elevation_cooling - north_bias, 0.0, 1.0)


func _sample_rainfall(x: int, y: int, elevation: float) -> float:
	var humidity := _to_normalized(_rainfall_noise.get_noise_2d(float(x), float(y)))
	var orographic := maxf(0.0, mountain_level - elevation) * 0.25
	return clampf(humidity + orographic, 0.0, 1.0)


func _sample_moisture(x: int, y: int, elevation: float) -> float:
	var rainfall := _sample_rainfall(x, y, elevation)
	var drainage := clampf(1.0 - elevation, 0.0, 1.0)
	var noise_variation := _to_normalized(_rainfall_noise.get_noise_2d(float(x) * 1.9, float(y) * 1.9))
	return clampf(rainfall * 0.55 + drainage * 0.3 + noise_variation * 0.15, 0.0, 1.0)


func _sample_vegetation(x: int, y: int, elevation: float, moisture: float, temperature: float) -> float:
	if _vegetation_noise == null:
		return clampf(moisture, 0.0, 1.0)
	var noise_value := _to_normalized(_vegetation_noise.get_noise_2d(float(x), float(y)))
	var climate := clampf(moisture * 0.65 + temperature * 0.35, 0.0, 1.0)
	var elevation_limit := clampf(1.0 - maxf(0.0, elevation - hill_level) * 1.8, 0.0, 1.0)
	return clampf(noise_value * 0.55 + climate * 0.45, 0.0, 1.0) * elevation_limit


func _assign_base_biome(
	coord: Vector2i,
	height: float,
	temperature: float,
	moisture: float,
	height_map: Dictionary
) -> String:
	if height < water_level:
		return BIOME_WATER
	if temperature < tundra_threshold:
		return BIOME_TUNDRA
	if _is_marsh(coord, height, moisture, height_map):
		return BIOME_MARSH
	var desert_temp_cutoff := clampf(hot_threshold - desert_temperature_bias, 0.0, 1.0)
	var desert_moisture_cutoff := clampf(desert_threshold + desert_moisture_bias, 0.0, 1.0)
	if temperature >= desert_temp_cutoff && moisture <= desert_moisture_cutoff:
		return BIOME_DESERT
	if temperature >= warm_threshold && moisture <= badlands_threshold:
		return BIOME_BADLANDS
	return BIOME_GRASSLAND


func _tree_overlay_biome(temperature: float, moisture: float) -> String:
	if moisture >= jungle_threshold && temperature >= hot_threshold:
		return BIOME_JUNGLE
	if temperature < tundra_threshold:
		return BIOME_TUNDRA
	return BIOME_FOREST


func _build_highland_overlays(biome_map: Dictionary, height_map: Dictionary) -> Dictionary:
	var overlay_map: Dictionary = {}
	for coord: Vector2i in biome_map.keys():
		if biome_map[coord] == BIOME_WATER:
			continue
		var height: float = height_map.get(coord, 0.0)
		if height > mountain_level:
			overlay_map[coord] = BIOME_MOUNTAIN
		elif height > hill_level:
			overlay_map[coord] = BIOME_HILLS
	return overlay_map


func _apply_tree_overlays(
	biome_map: Dictionary,
	temperature_map: Dictionary,
	moisture_map: Dictionary,
	vegetation_map: Dictionary,
	height_map: Dictionary
) -> Dictionary:
	var tree_map: Dictionary = {}
	var next_map := biome_map.duplicate()
	var tree_source_map := biome_map
	var has_existing_trees := false
	var moisture_threshold := forest_threshold * 0.6
	var vegetation_threshold := 0.35
	for coord: Vector2i in biome_map.keys():
		if height_map.get(coord, 0.0) > mountain_level:
			continue
		if TREE_BIOMES.has(biome_map[coord]):
			has_existing_trees = true
			break
	if not has_existing_trees:
		var best_seeds: Array[Vector2i] = []
		var best_scores: Array[float] = []
		for coord: Vector2i in biome_map.keys():
			if height_map.get(coord, 0.0) > mountain_level:
				continue
			if not TREE_BASE_BIOMES.has(biome_map[coord]):
				continue
			var moisture: float = moisture_map.get(coord, 0.0)
			if moisture < moisture_threshold:
				continue
			var vegetation: float = vegetation_map.get(coord, 0.0)
			if vegetation < vegetation_threshold:
				continue
			var temperature: float = temperature_map.get(coord, 0.0)
			var seed_score := moisture + vegetation + temperature
			if best_scores.size() < 6:
				best_scores.append(seed_score)
				best_seeds.append(coord)
			else:
				var lowest_index := 0
				var lowest_score := best_scores[0]
				for index in range(1, best_scores.size()):
					if best_scores[index] < lowest_score:
						lowest_score = best_scores[index]
						lowest_index = index
				if seed_score > lowest_score:
					best_scores[lowest_index] = seed_score
					best_seeds[lowest_index] = coord
		if not best_seeds.is_empty():
			tree_source_map = biome_map.duplicate()
			for seed_coord: Vector2i in best_seeds:
				var seed_moisture: float = moisture_map.get(seed_coord, 0.0)
				var seed_temperature: float = temperature_map.get(seed_coord, 0.0)
				var seeded_biome := _tree_overlay_biome(seed_temperature, seed_moisture)
				tree_source_map[seed_coord] = seeded_biome
				next_map[seed_coord] = seeded_biome
				tree_map[seed_coord] = seeded_biome
	for _spread_pass in range(2):
		for coord: Vector2i in biome_map.keys():
			if height_map.get(coord, 0.0) > mountain_level:
				continue
			if not TREE_BASE_BIOMES.has(biome_map[coord]):
				continue
			var moisture: float = moisture_map.get(coord, 0.0)
			if moisture < moisture_threshold:
				continue
			var vegetation: float = vegetation_map.get(coord, 0.0)
			if vegetation < vegetation_threshold:
				continue
			if _has_tree_neighbor(coord, tree_source_map):
				var temperature: float = temperature_map.get(coord, 0.0)
				var tree_biome := _tree_overlay_biome(temperature, moisture)
				next_map[coord] = tree_biome
				tree_map[coord] = tree_biome
		tree_source_map = next_map.duplicate()
	biome_map.clear()
	for coord: Vector2i in next_map.keys():
		biome_map[coord] = next_map[coord]
	return tree_map


func _apply_tree_tiles(tree_map: Dictionary, base_biome_map: Dictionary) -> void:
	if map_layer == null or tree_layer == null:
		return
	for coord: Vector2i in tree_map.keys():
		if map_layer.get_cell_source_id(coord) == -1:
			var fallback_biome := base_biome_map.get(coord, BIOME_GRASSLAND) as String
			if fallback_biome == BIOME_GRASSLAND:
				map_layer.set_cell(coord, _atlas_source_id, GRASS_TILE)
			elif fallback_biome == BIOME_TUNDRA:
				map_layer.set_cell(coord, _atlas_source_id, SNOW_TILE)
			else:
				continue
		var base_tile := map_layer.get_cell_atlas_coords(coord)
		if base_tile != GRASS_TILE and base_tile != SNOW_TILE:
			continue
		var base_biome := base_biome_map.get(coord, BIOME_GRASSLAND) as String
		if base_biome != BIOME_GRASSLAND and base_biome != BIOME_TUNDRA:
			continue
		var tree_biome := tree_map.get(coord, BIOME_FOREST) as String
		var tile_coords := TREE_TILE
		if tree_biome == BIOME_JUNGLE:
			tile_coords = JUNGLE_TREE_TILE
		elif base_biome == BIOME_TUNDRA:
			tile_coords = TREE_SNOW_TILE
		tree_layer.set_cell(coord, _atlas_source_id, tile_coords)


func _has_tree_neighbor(coord: Vector2i, biome_map: Dictionary) -> bool:
	for offset: Vector2i in [
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(1, 1)
	]:
		var neighbor := coord + offset
		if TREE_BIOMES.has(biome_map.get(neighbor, "")):
			return true
	return false


func _is_marsh(coord: Vector2i, height: float, moisture: float, height_map: Dictionary) -> bool:
	if moisture < marsh_threshold:
		return false
	if height <= water_level + 0.08:
		return true
	for offset: Vector2i in [
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(1, 1)
	]:
		var neighbor := coord + offset
		var neighbor_height: float = height_map.get(neighbor, 1.0)
		if neighbor_height < water_level:
			return true
	return false


func _smooth_biomes(biome_map: Dictionary, passes: int) -> void:
	for pass_index in range(passes):
		var next_map := biome_map.duplicate()
		for coord: Vector2i in biome_map.keys():
			var current: String = biome_map.get(coord, BIOME_GRASSLAND)
			if current == BIOME_WATER || current == BIOME_MOUNTAIN:
				continue
			var neighbor_counts: Dictionary = {}
			for offset: Vector2i in [
				Vector2i.LEFT,
				Vector2i.RIGHT,
				Vector2i.UP,
				Vector2i.DOWN,
				Vector2i(-1, -1),
				Vector2i(1, -1),
				Vector2i(-1, 1),
				Vector2i(1, 1)
			]:
				var neighbor := coord + offset
				var neighbor_biome: String = biome_map.get(neighbor, current)
				if neighbor_biome == BIOME_WATER || neighbor_biome == BIOME_MOUNTAIN:
					continue
				neighbor_counts[neighbor_biome] = int(neighbor_counts.get(neighbor_biome, 0)) + 1
			var most_common: String = current
			var most_common_count := -1
			for biome: String in neighbor_counts.keys():
				var count: int = neighbor_counts[biome]
				if count > most_common_count:
					most_common = biome
					most_common_count = count
			if most_common != current and most_common_count >= 0:
				next_map[coord] = most_common
		biome_map.clear()
		for coord: Vector2i in next_map.keys():
			biome_map[coord] = next_map[coord]


func _count_biome(biome_map: Dictionary, biome: String) -> int:
	var count := 0
	for coord: Vector2i in biome_map.keys():
		if biome_map.get(coord, "") == biome:
			count += 1
	return count


func _seed_desert_biomes(
	biome_map: Dictionary,
	temperature_map: Dictionary,
	moisture_map: Dictionary,
	height_map: Dictionary
) -> void:
	var candidates: Array[Vector2i] = []
	for coord: Vector2i in biome_map.keys():
		if biome_map.get(coord, "") == BIOME_WATER:
			continue
		if height_map.get(coord, 0.0) < water_level:
			continue
		if temperature_map.get(coord, 0.0) < warm_threshold:
			continue
		candidates.append(coord)
	if candidates.is_empty():
		return
	candidates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return moisture_map.get(a, 1.0) < moisture_map.get(b, 1.0)
	)
	var target_count := maxi(1, int(round(float(candidates.size()) * 0.015)))
	for index in range(mini(target_count, candidates.size())):
		biome_map[candidates[index]] = BIOME_DESERT


func _biome_to_tile(biome: String) -> Vector2i:
	match biome:
		BIOME_WATER:
			return WATER_TILE
		BIOME_MOUNTAIN:
			return MOUNTAIN_TILE
		BIOME_HILLS:
			return HILLS_TILE
		BIOME_MARSH:
			return MARSH_TILE
		BIOME_TUNDRA:
			return SNOW_TILE
		BIOME_DESERT:
			return SAND_TILE
		BIOME_BADLANDS:
			return BADLANDS_TILE
		BIOME_FOREST:
			return TREE_TILE
		BIOME_JUNGLE:
			return JUNGLE_TREE_TILE
		_:
			return GRASS_TILE

func _place_icebergs(
	biome_map: Dictionary,
	temperature_map: Dictionary,
	height_map: Dictionary,
	rng: RandomNumberGenerator
) -> void:
	if iceberg_layer == null:
		return
	if map_layer != null:
		iceberg_layer.tile_set = map_layer.tile_set
	iceberg_layer.clear()
	var candidates: Array[Vector2i] = []
	var coldest_coord := Vector2i(-1, -1)
	var coldest_temp := 1.0
	for coord: Vector2i in biome_map.keys():
		if biome_map.get(coord, "") != BIOME_WATER:
			continue
		var temp := float(temperature_map.get(coord, 1.0))
		if temp < coldest_temp:
			coldest_temp = temp
			coldest_coord = coord
		if temp <= iceberg_temperature_threshold and _is_iceberg_candidate(coord, height_map):
			candidates.append(coord)
	var placed := 0
	for coord: Vector2i in candidates:
		if rng.randf() <= iceberg_density:
			var selected_iceberg_tile := _pick_iceberg_tile(rng)
			iceberg_layer.set_cell(coord, _atlas_source_id, selected_iceberg_tile)
			placed += 1
	if placed == 0 and coldest_coord != Vector2i(-1, -1):
		var fallback_iceberg_tile := _pick_iceberg_tile(rng)
		iceberg_layer.set_cell(coldest_coord, _atlas_source_id, fallback_iceberg_tile)

func _pick_iceberg_tile(rng: RandomNumberGenerator) -> Vector2i:
	if iceberg_tile_options.is_empty():
		return Vector2i(4, 3)
	return iceberg_tile_options[rng.randi_range(0, iceberg_tile_options.size() - 1)]

func _is_iceberg_candidate(coord: Vector2i, height_map: Dictionary) -> bool:
	for offset: Vector2i in [
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(-1, 1),
		Vector2i(1, 1)
	]:
		var neighbor := coord + offset
		var neighbor_height: float = height_map.get(neighbor, 1.0)
		if neighbor_height >= water_level:
			return false
	return true

func _place_settlements(biome_map: Dictionary, rng: RandomNumberGenerator) -> void:
	var settings := _world_settings
	var ratios: Dictionary = settings.get("settlement_ratios", {}) as Dictionary
	var settlements: Dictionary = settings.get("settlements", {}) as Dictionary
	var base_count: int = maxi(1, int(round(float(map_size.x * map_size.y) / 16384.0)))
	var occupied: Array[Vector2i] = []
	var candidates := _build_settlement_candidates(biome_map)
	var min_distance := 8.0

	for civilization: String in DWARFHOLD_LOGIC.SETTLEMENT_TYPES.keys():
		var settlement_type := String(DWARFHOLD_LOGIC.SETTLEMENT_TYPES[civilization])
		var ratio := -1.0
		if ratios.has(civilization):
			ratio = float(ratios.get(civilization, 0.0))
		elif settlements.has(civilization):
			var raw_value := float(settlements.get(civilization, 0.0))
			ratio = clampf(raw_value / 100.0, 0.0, 1.0)
		else:
			ratio = 0.5
		if ratio <= 0.0:
			continue
		var count: int = maxi(1, int(round(base_count * ratio)))
		for _i in range(count):
			var available := _filter_settlement_candidates(candidates, occupied, min_distance)
			if available.is_empty():
				break
			var chosen := DWARFHOLD_LOGIC.choose_tile_for_capital(settlement_type, available, rng)
			if chosen == Vector2i(-1, -1):
				break
			if _is_too_close(chosen, occupied, min_distance):
				occupied.append(chosen)
				continue
			occupied.append(chosen)
			var biome_label := _settlement_biome_label(biome_map.get(chosen, BIOME_GRASSLAND))
			var tile := _select_settlement_tile(settlement_type, biome_label, rng)
			if settlement_layer != null:
				settlement_layer.set_cell(chosen, _atlas_source_id, tile)
			else:
				map_layer.set_cell(chosen, _atlas_source_id, tile)
			var tile_info: Dictionary = {}
			if _tile_data.has(chosen):
				tile_info = _tile_data[chosen] as Dictionary
			var settlement_name: String = String(SETTLEMENT_NAMES.get(civilization, "Settlement"))
			if civilization == "dwarves" and not DWARFHOLD_NAMES.is_empty():
				settlement_name = DWARFHOLD_NAMES[rng.randi_range(0, DWARFHOLD_NAMES.size() - 1)]
			tile_info["region_name"] = settlement_name
			tile_info["major_population_groups"] = [civilization]
			tile_info["minor_population_groups"] = []
			tile_info["settlement_type"] = settlement_type
			_tile_data[chosen] = tile_info

func _build_settlement_candidates(biome_map: Dictionary) -> Array:
	var candidates: Array = []
	for coord: Vector2i in biome_map.keys():
		var biome := _settlement_biome_label(biome_map.get(coord, BIOME_GRASSLAND))
		var tree_overlay := Vector2i(-1, -1)
		if tree_layer != null:
			tree_overlay = tree_layer.get_cell_atlas_coords(coord)
		candidates.append({
			"coord": coord,
			"biome": biome,
			"tree_overlay": tree_overlay,
			"has_forest_tree_overlay": tree_overlay == TREE_TILE,
			"has_jungle_tree_overlay": tree_overlay == JUNGLE_TREE_TILE
		})
	return candidates

func _filter_settlement_candidates(
	candidates: Array,
	occupied: Array[Vector2i],
	min_distance: float
) -> Array:
	var filtered: Array = []
	for candidate: Dictionary in candidates:
		var coord: Vector2i = Vector2i(-1, -1)
		if candidate.has("coord"):
			coord = candidate["coord"] as Vector2i
		if coord == Vector2i(-1, -1):
			continue
		if _is_too_close(coord, occupied, min_distance):
			continue
		filtered.append(candidate)
	return filtered

func _is_too_close(coord: Vector2i, occupied: Array[Vector2i], min_distance: float) -> bool:
	for other: Vector2i in occupied:
		if coord.distance_to(other) < min_distance:
			return true
	return false

func _settlement_biome_label(biome: String) -> String:
	match biome:
		BIOME_MOUNTAIN:
			return "mountain"
		BIOME_HILLS:
			return "grass"
		BIOME_TUNDRA:
			return "snow"
		BIOME_DESERT:
			return "sand"
		BIOME_BADLANDS:
			return "badlands"
		BIOME_FOREST, BIOME_JUNGLE:
			return "forest"
		BIOME_MARSH:
			return "marsh"
		BIOME_WATER:
			return "water"
		_:
			return "grass"

func _select_settlement_tile(settlement_type: String, biome_label: String, rng: RandomNumberGenerator) -> Vector2i:
	match settlement_type:
		"town":
			if biome_label == "snow":
				return HAMLET_SNOW_TILE
			var options: Array = SETTLEMENT_TILES.get("town", [TOWN_TILE]) as Array
			return options[rng.randi_range(0, options.size() - 1)]
		"dwarfhold":
			var dwarf_tiles: Array = SETTLEMENT_TILES.get("dwarfhold", [DWARFHOLD_TILE]) as Array
			return dwarf_tiles[rng.randi_range(0, dwarf_tiles.size() - 1)]
		"woodElfGrove":
			var elf_tiles: Array = SETTLEMENT_TILES.get("woodElfGrove", [WOOD_ELF_GROVES_TILE]) as Array
			return elf_tiles[rng.randi_range(0, elf_tiles.size() - 1)]
		"lizardmenCity":
			return LIZARDMEN_CITY_TILE
		_:
			return TOWN_TILE

func _resources_for_biome(biome: String) -> Array[String]:
	match biome:
		BIOME_WATER:
			return ["fish", "salt"]
		BIOME_MOUNTAIN:
			return ["stone", "iron", "gems"]
		BIOME_HILLS:
			return ["stone", "game", "herbs"]
		BIOME_MARSH:
			return ["reeds", "peat", "herbs"]
		BIOME_TUNDRA:
			return ["fur", "ice", "hardwood"]
		BIOME_DESERT:
			return ["spice", "glass", "salt"]
		BIOME_BADLANDS:
			return ["clay", "copper", "scrub"]
		BIOME_FOREST:
			return ["timber", "game", "berries"]
		BIOME_JUNGLE:
			return ["exotic wood", "fruit", "spices"]
		_:
			return ["grain", "livestock", "herbs"]

func _describe_climate(temperature: float, moisture: float) -> String:
	var temp_label := "Mild"
	if temperature < 0.3:
		temp_label = "Cold"
	elif temperature < 0.55:
		temp_label = "Cool"
	elif temperature < 0.75:
		temp_label = "Warm"
	else:
		temp_label = "Hot"
	var moisture_label := "moderate rainfall"
	if moisture < 0.3:
		moisture_label = "low rainfall"
	elif moisture < 0.6:
		moisture_label = "moderate rainfall"
	else:
		moisture_label = "heavy rainfall"
	return "%s climate with %s" % [temp_label, moisture_label]

func _format_resource_list(resources: Array[String]) -> String:
	var items: Array[String] = []
	for entry: String in resources:
		items.append(String(entry))
	if items.is_empty():
		return "None"
	if items.size() == 1:
		return items[0]
	if items.size() == 2:
		return "%s and %s" % [items[0], items[1]]
	var combined := ""
	for index in range(items.size()):
		if index == items.size() - 1:
			combined += "and %s" % items[index]
		else:
			combined += "%s, " % items[index]
	return combined

func _humanize_biome(biome: String) -> String:
	if biome.is_empty():
		return ""
	var words := biome.replace("_", " ").split(" ", false)
	for index in range(words.size()):
		words[index] = String(words[index]).capitalize()
	return " ".join(words)

func _cache_map_layer_parent() -> void:
	if map_layer == null:
		return
	_map_layer_original_parent = map_layer.get_parent()
	if _map_layer_original_parent != null:
		_map_layer_original_index = map_layer.get_index()

func _cache_tree_layer_parent() -> void:
	if tree_layer == null:
		return
	_tree_layer_original_parent = tree_layer.get_parent()
	if _tree_layer_original_parent != null:
		_tree_layer_original_index = tree_layer.get_index()

func _cache_highland_layer_parent() -> void:
	if highland_layer == null:
		return
	_highland_layer_original_parent = highland_layer.get_parent()
	if _highland_layer_original_parent != null:
		_highland_layer_original_index = highland_layer.get_index()

func _cache_iceberg_layer_parent() -> void:
	if iceberg_layer == null:
		return
	_iceberg_layer_original_parent = iceberg_layer.get_parent()
	if _iceberg_layer_original_parent != null:
		_iceberg_layer_original_index = iceberg_layer.get_index()

func _cache_settlement_layer_parent() -> void:
	if settlement_layer == null:
		return
	_settlement_layer_original_parent = settlement_layer.get_parent()
	if _settlement_layer_original_parent != null:
		_settlement_layer_original_index = settlement_layer.get_index()

func _cache_overlay_parent() -> void:
	if map_overlays == null:
		return
	_overlays_original_parent = map_overlays.get_parent()
	if _overlays_original_parent != null:
		_overlays_original_index = map_overlays.get_index()

func _configure_globe_viewport() -> void:
	if map_viewport == null:
		return
	var viewport_size := Vector2i(map_size.x * tile_size, map_size.y * tile_size)
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		return
	map_viewport.size = viewport_size
	map_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

func _configure_overworld_camera_bounds() -> void:
	if overworld_camera == null:
		return
	var world_rect := _get_world_rect()
	overworld_camera.set_world_bounds(world_rect)

func _get_world_rect() -> Rect2:
	var world_width := maxf(0.0, float(map_size.x * tile_size))
	var world_height := maxf(0.0, float(map_size.y * tile_size))
	return Rect2(Vector2.ZERO, Vector2(world_width, world_height))

func _set_globe_view(enabled: bool) -> void:
	_is_globe_view = enabled
	if globe_view != null:
		globe_view.visible = enabled
	if overworld_camera != null:
		overworld_camera.enabled = not enabled
		if not enabled:
			overworld_camera.make_current()
	if globe_camera != null:
		globe_camera.current = enabled
	if enabled:
		_move_map_layer_to_viewport()
		_update_globe_texture()
	else:
		_restore_map_layer_parent()
	_update_elevation_overlay_visibility()
	_update_temperature_overlay_visibility()
	_update_moisture_overlay_visibility()
	_update_biome_overlay_visibility()
	if enabled:
		_hide_map_tooltip()

func _move_map_layer_to_viewport() -> void:
	if map_layer == null or map_viewport_root == null:
		return
	if map_layer.get_parent() == map_viewport_root:
		return
	map_layer.get_parent().remove_child(map_layer)
	map_viewport_root.add_child(map_layer)
	map_layer.position = Vector2.ZERO
	if tree_layer != null:
		if tree_layer.get_parent() != null:
			tree_layer.get_parent().remove_child(tree_layer)
		map_viewport_root.add_child(tree_layer)
		tree_layer.position = Vector2.ZERO
	if highland_layer != null:
		if highland_layer.get_parent() != null:
			highland_layer.get_parent().remove_child(highland_layer)
		map_viewport_root.add_child(highland_layer)
		highland_layer.position = Vector2.ZERO
	if iceberg_layer != null:
		if iceberg_layer.get_parent() != null:
			iceberg_layer.get_parent().remove_child(iceberg_layer)
		map_viewport_root.add_child(iceberg_layer)
		iceberg_layer.position = Vector2.ZERO
	if settlement_layer != null:
		if settlement_layer.get_parent() != null:
			settlement_layer.get_parent().remove_child(settlement_layer)
		map_viewport_root.add_child(settlement_layer)
		settlement_layer.position = Vector2.ZERO
	if map_overlays != null:
		if map_overlays.get_parent() != null:
			map_overlays.get_parent().remove_child(map_overlays)
		map_viewport_root.add_child(map_overlays)
		map_overlays.position = Vector2.ZERO

func _update_map_tooltip() -> void:
	if tooltip_panel == null or map_layer == null:
		return
	if _is_globe_view:
		_hide_map_tooltip()
		return
	var global_mouse := get_global_mouse_position()
	var local_mouse := map_layer.to_local(global_mouse)
	var coord := map_layer.local_to_map(local_mouse)
	if coord.x < 0 or coord.y < 0 or coord.x >= map_size.x or coord.y >= map_size.y:
		_hide_map_tooltip()
		return
	if not _tile_data.has(coord):
		_hide_map_tooltip()
		return
	if coord != _hovered_tile:
		_hovered_tile = coord
		_refresh_map_tooltip(coord)
	tooltip_panel.visible = true
	_position_map_tooltip()

func _refresh_map_tooltip(coord: Vector2i) -> void:
	if tooltip_panel == null:
		return
	var data: Dictionary = _tile_data.get(coord, {})
	var biome := String(data.get("biome_type", ""))
	var temperature := float(data.get("temperature", 0.0))
	var moisture := float(data.get("moisture", 0.0))
	var resources: Array[String] = []
	for entry: Variant in data.get("resources", []):
		resources.append(String(entry))
	var region_name := String(data.get("region_name", "")).strip_edges()
	var biome_label := _humanize_biome(biome)
	if region_name.is_empty():
		if biome_label.is_empty():
			region_name = "Unnamed Region"
		else:
			region_name = "Unnamed %s" % biome_label
	if tooltip_title != null:
		tooltip_title.text = region_name
	if tooltip_biome != null:
		tooltip_biome.text = "Biome: %s" % biome_label
	if tooltip_climate != null:
		tooltip_climate.text = "Climate: %s" % _describe_climate(temperature, moisture)
	if tooltip_resources != null:
		var resource_text := _format_resource_list(resources)
		tooltip_resources.text = "Resources: %s" % (resource_text if not resource_text.is_empty() else "None")
	tooltip_panel.size = tooltip_panel.get_combined_minimum_size()

func _position_map_tooltip() -> void:
	if tooltip_panel == null:
		return
	var viewport := get_viewport()
	if viewport == null:
		return
	var cursor_pos := viewport.get_mouse_position()
	var tooltip_size := tooltip_panel.get_combined_minimum_size()
	tooltip_panel.size = tooltip_size
	var offset := Vector2(16, 16)
	var viewport_size := viewport.get_visible_rect().size
	var max_pos := Vector2(
		maxf(0.0, viewport_size.x - tooltip_size.x),
		maxf(0.0, viewport_size.y - tooltip_size.y)
	)
	var target_pos := cursor_pos + offset
	target_pos.x = clampf(target_pos.x, 0.0, max_pos.x)
	target_pos.y = clampf(target_pos.y, 0.0, max_pos.y)
	tooltip_panel.position = target_pos

func _hide_map_tooltip() -> void:
	if tooltip_panel != null:
		tooltip_panel.visible = false
	_hovered_tile = Vector2i(-999, -999)

func _restore_map_layer_parent() -> void:
	if map_layer == null or _map_layer_original_parent == null:
		return
	if map_layer.get_parent() == _map_layer_original_parent:
		return
	map_layer.get_parent().remove_child(map_layer)
	if _map_layer_original_index >= 0:
		_map_layer_original_parent.add_child(map_layer)
		_map_layer_original_parent.move_child(map_layer, _map_layer_original_index)
	else:
		_map_layer_original_parent.add_child(map_layer)
	map_layer.position = Vector2.ZERO
	if tree_layer != null and _tree_layer_original_parent != null:
		if tree_layer.get_parent() != null:
			tree_layer.get_parent().remove_child(tree_layer)
		if _tree_layer_original_index >= 0:
			_tree_layer_original_parent.add_child(tree_layer)
			_tree_layer_original_parent.move_child(tree_layer, _tree_layer_original_index)
		else:
			_tree_layer_original_parent.add_child(tree_layer)
		tree_layer.position = Vector2.ZERO
	if highland_layer != null and _highland_layer_original_parent != null:
		if highland_layer.get_parent() != null:
			highland_layer.get_parent().remove_child(highland_layer)
		if _highland_layer_original_index >= 0:
			_highland_layer_original_parent.add_child(highland_layer)
			_highland_layer_original_parent.move_child(highland_layer, _highland_layer_original_index)
		else:
			_highland_layer_original_parent.add_child(highland_layer)
		highland_layer.position = Vector2.ZERO
	if iceberg_layer != null and _iceberg_layer_original_parent != null:
		if iceberg_layer.get_parent() != null:
			iceberg_layer.get_parent().remove_child(iceberg_layer)
		if _iceberg_layer_original_index >= 0:
			_iceberg_layer_original_parent.add_child(iceberg_layer)
			_iceberg_layer_original_parent.move_child(iceberg_layer, _iceberg_layer_original_index)
		else:
			_iceberg_layer_original_parent.add_child(iceberg_layer)
		iceberg_layer.position = Vector2.ZERO
	if settlement_layer != null and _settlement_layer_original_parent != null:
		if settlement_layer.get_parent() != null:
			settlement_layer.get_parent().remove_child(settlement_layer)
		if _settlement_layer_original_index >= 0:
			_settlement_layer_original_parent.add_child(settlement_layer)
			_settlement_layer_original_parent.move_child(settlement_layer, _settlement_layer_original_index)
		else:
			_settlement_layer_original_parent.add_child(settlement_layer)
		settlement_layer.position = Vector2.ZERO
	if map_overlays == null or _overlays_original_parent == null:
		return
	if map_overlays.get_parent() == _overlays_original_parent:
		return
	if map_overlays.get_parent() != null:
		map_overlays.get_parent().remove_child(map_overlays)
	if _overlays_original_index >= 0:
		_overlays_original_parent.add_child(map_overlays)
		_overlays_original_parent.move_child(map_overlays, _overlays_original_index)
	else:
		_overlays_original_parent.add_child(map_overlays)
	map_overlays.position = Vector2.ZERO

func _update_globe_texture() -> void:
	if globe_mesh == null or map_viewport == null:
		return
	var viewport_texture := map_viewport.get_texture()
	if viewport_texture == null:
		return
	var globe_material := globe_mesh.material_override as StandardMaterial3D
	if globe_material == null:
		globe_material = StandardMaterial3D.new()
		globe_material.roughness = 1.0
	globe_mesh.material_override = globe_material
	globe_material.albedo_texture = viewport_texture

func _rotate_globe(delta: float) -> void:
	if globe_mesh == null or globe_rotation_speed == 0.0:
		return
	globe_mesh.rotate_y(globe_rotation_speed * delta)

func _configure_tileset() -> void:
	var tile_set := TileSet.new()
	var overworld_atlas := TileSetAtlasSource.new()
	var atlas_texture := load(ATLAS_TEXTURE) as Texture2D
	if atlas_texture == null:
		push_error("Overworld atlas texture could not be loaded: %s" % ATLAS_TEXTURE)
		_atlas_source_id = -1
		if map_layer != null:
			map_layer.tile_set = tile_set
		if tree_layer != null:
			tree_layer.tile_set = tile_set
		if highland_layer != null:
			highland_layer.tile_set = tile_set
		if iceberg_layer != null:
			iceberg_layer.tile_set = tile_set
		if settlement_layer != null:
			settlement_layer.tile_set = tile_set
		return
	var texture_size := atlas_texture.get_size()
	var tile_coords_list: Array[Vector2i] = [
		SAND_TILE,
		GRASS_TILE,
		BADLANDS_TILE,
		MINE_TILE,
		MARSH_TILE,
		SNOW_TILE,
		TREE_TILE,
		TREE_LONE_TILE,
		TREE_SNOW_TILE,
		JUNGLE_TREE_TILE,
		CUT_TREES_TILE,
		AMBIENT_LUMBER_MILL_TILE,
		WATER_TILE,
		MOUNTAIN_TILE,
		MOUNTAIN_TOP_A_TILE,
		MOUNTAIN_TOP_B_TILE,
		MOUNTAIN_BOTTOM_A_TILE,
		MOUNTAIN_BOTTOM_B_TILE,
		DAM_TILE,
		MOUNTAIN_PEAK_TILE,
		STONE_TILE,
		DWARFHOLD_TILE,
		ABANDONED_DWARFHOLD_TILE,
		GREAT_DWARFHOLD_TILE,
		DARK_DWARFHOLD_TILE,
		HILLHOLD_TILE,
		CAVE_TILE,
		TOWER_TILE,
		EVIL_WIZARDS_TOWER_TILE,
		WOOD_ELF_GROVES_TILE,
		WOOD_ELF_GROVES_LARGE_TILE,
		WOOD_ELF_GROVES_GRAND_TILE,
		HILLS_TILE,
		HILLS_BADLANDS_TILE,
		HILLS_VARIANT_A_TILE,
		HILLS_VARIANT_B_TILE,
		HILLS_SNOW_TILE,
		TOWN_TILE,
		PORT_TOWN_TILE,
		CASTLE_TILE,
		ROADSIDE_TAVERN_TILE,
		HAMLET_TILE,
		ACTIVE_VOLCANO_TILE,
		VOLCANO_TILE,
		LAVA_TILE,
		OASIS_TILE,
		HAMLET_SNOW_TILE,
		AMBIENT_SLEEPING_DRAGON_TILE,
		AMBIENT_HUNTING_LODGE_TILE,
		AMBIENT_HOMESTEAD_TILE,
		AMBIENT_MOONWELL_TILE,
		AMBIENT_FARM_TILE,
		FARM_CROPS_TILE,
		AMBIENT_FARM_VARIANT_TILE,
		AMBIENT_GREAT_TREE_TILE,
		AMBIENT_GREAT_TREE_ALT_TILE,
		LIZARDMEN_CITY_TILE,
		SAINT_SHRINE_TILE,
		MONASTERY_TILE,
		ORC_CAMP_TILE,
		GNOLL_CAMP_TILE,
		TROLL_CAMP_TILE,
		OGRE_CAMP_TILE,
		BANDIT_CAMP_TILE,
		TRAVELERS_CAMP_TILE,
		DUNGEON_TILE,
		CENTAUR_ENCAMPMENT_TILE
	]
	for iceberg_tile_coord: Vector2i in iceberg_tile_options:
		tile_coords_list.append(iceberg_tile_coord)
	var max_tile := Vector2i(0, 0)
	for tile_coords: Vector2i in tile_coords_list:
		max_tile.x = max(max_tile.x, tile_coords.x)
		max_tile.y = max(max_tile.y, tile_coords.y)
	var required_columns := max_tile.x + 1
	var required_rows := max_tile.y + 1
	var atlas_tile_size := tile_size
	if required_columns > 0 and required_rows > 0:
		if int(texture_size.x) % required_columns == 0 and int(texture_size.y) % required_rows == 0:
			var derived_tile_size_x := int(texture_size.x / required_columns)
			var derived_tile_size_y := int(texture_size.y / required_rows)
			if derived_tile_size_x == derived_tile_size_y and derived_tile_size_x > 0:
				if derived_tile_size_x != tile_size:
					push_warning(
						"Overworld atlas tile size (%s) differs from configured tile_size (%s); using atlas-derived size." %
						[derived_tile_size_x, tile_size]
					)
					tile_size = derived_tile_size_x
				atlas_tile_size = derived_tile_size_x
			else:
				push_warning(
					"Overworld atlas texture size (%s) does not map cleanly to a square tile grid (%s x %s)." %
					[texture_size, required_columns, required_rows]
				)
	var max_columns := int(texture_size.x / atlas_tile_size)
	var max_rows := int(texture_size.y / atlas_tile_size)
	if max_columns <= 0 or max_rows <= 0:
		push_error("Overworld atlas texture has no valid tile regions: %s" % ATLAS_TEXTURE)
		_atlas_source_id = -1
		if map_layer != null:
			map_layer.tile_set = tile_set
		if tree_layer != null:
			tree_layer.tile_set = tile_set
		if highland_layer != null:
			highland_layer.tile_set = tile_set
		if iceberg_layer != null:
			iceberg_layer.tile_set = tile_set
		return
	if max_columns < required_columns or max_rows < required_rows:
		push_error(
			"Overworld atlas texture is too small for required tiles (%s x %s needed, got %s x %s)." %
			[required_columns, required_rows, max_columns, max_rows]
		)
	tile_set.tile_size = Vector2i(atlas_tile_size, atlas_tile_size)
	overworld_atlas.texture = atlas_texture
	overworld_atlas.texture_region_size = Vector2i(atlas_tile_size, atlas_tile_size)
	var seen_tiles: Dictionary = {}
	for tile_coords: Vector2i in tile_coords_list:
		if seen_tiles.has(tile_coords):
			continue
		seen_tiles[tile_coords] = true
		if tile_coords.x < 0 or tile_coords.y < 0 or tile_coords.x >= max_columns or tile_coords.y >= max_rows:
			push_warning(
				"Skipping overworld tile %s because it is outside the atlas bounds (%s x %s)." %
				[tile_coords, max_columns, max_rows]
			)
			continue
		overworld_atlas.create_tile(tile_coords)
	_atlas_source_id = tile_set.add_source(overworld_atlas)
	map_layer.tile_set = tile_set
	map_layer.position = Vector2.ZERO
	if tree_layer != null:
		tree_layer.tile_set = tile_set
		tree_layer.position = Vector2.ZERO
	if highland_layer != null:
		highland_layer.tile_set = tile_set
		highland_layer.position = Vector2.ZERO
	if iceberg_layer != null:
		iceberg_layer.tile_set = tile_set
		iceberg_layer.position = Vector2.ZERO
	if settlement_layer != null:
		settlement_layer.tile_set = tile_set
		settlement_layer.position = Vector2.ZERO

func _update_temperature_overlay() -> void:
	if temperature_overlay == null:
		return
	if _temperature_map.is_empty():
		temperature_overlay.texture = null
		return
	var image := Image.create(map_size.x, map_size.y, false, Image.FORMAT_RGBA8)
	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord := Vector2i(x, y)
			var temperature := float(_temperature_map.get(coord, 0.0))
			image.set_pixel(x, y, _temperature_to_color(temperature))
	var texture := ImageTexture.create_from_image(image)
	temperature_overlay.texture = texture
	temperature_overlay.centered = false
	temperature_overlay.scale = Vector2(tile_size, tile_size)
	temperature_overlay.position = Vector2.ZERO
	_update_temperature_overlay_visibility()

func _temperature_to_color(temperature: float) -> Color:
	var cold := Color(0.2, 0.45, 1.0, 0.45)
	var hot := Color(1.0, 0.25, 0.1, 0.45)
	return cold.lerp(hot, clampf(temperature, 0.0, 1.0))

func _update_temperature_overlay_visibility() -> void:
	if temperature_overlay == null:
		return
	temperature_overlay.visible = _temperature_overlay_enabled and not _is_globe_view

func _update_elevation_overlay() -> void:
	if elevation_overlay == null:
		return
	if _height_map.is_empty():
		elevation_overlay.texture = null
		return
	var image := Image.create(map_size.x, map_size.y, false, Image.FORMAT_RGBA8)
	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord := Vector2i(x, y)
			var height := float(_height_map.get(coord, 0.0))
			image.set_pixel(x, y, _elevation_to_color(height))
	var texture := ImageTexture.create_from_image(image)
	elevation_overlay.texture = texture
	elevation_overlay.centered = false
	elevation_overlay.scale = Vector2(tile_size, tile_size)
	elevation_overlay.position = Vector2.ZERO
	_update_elevation_overlay_visibility()

func _elevation_to_color(height: float) -> Color:
	var alpha := 0.45
	var deep_water := Color(0.0, 0.2, 0.55, alpha)
	var shallow_water := Color(0.1, 0.5, 0.85, alpha)
	var lowland := Color(0.2, 0.6, 0.35, alpha)
	var highland := Color(0.6, 0.5, 0.25, alpha)
	var snow := Color(0.92, 0.92, 0.96, alpha)
	if height < water_level:
		var water_ratio := clampf(height / maxf(water_level, 0.001), 0.0, 1.0)
		return deep_water.lerp(shallow_water, water_ratio)
	if height < mountain_level:
		var land_ratio := clampf(
			(height - water_level) / maxf(mountain_level - water_level, 0.001),
			0.0,
			1.0
		)
		return lowland.lerp(highland, land_ratio)
	var mountain_ratio := clampf(
		(height - mountain_level) / maxf(1.0 - mountain_level, 0.001),
		0.0,
		1.0
	)
	return highland.lerp(snow, mountain_ratio)

func _update_elevation_overlay_visibility() -> void:
	if elevation_overlay == null:
		return
	elevation_overlay.visible = _elevation_overlay_enabled and not _is_globe_view

func _update_moisture_overlay() -> void:
	if moisture_overlay == null:
		return
	if _moisture_map.is_empty():
		moisture_overlay.texture = null
		return
	var image := Image.create(map_size.x, map_size.y, false, Image.FORMAT_RGBA8)
	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord := Vector2i(x, y)
			var moisture := float(_moisture_map.get(coord, 0.0))
			image.set_pixel(x, y, _moisture_to_color(moisture))
	var texture := ImageTexture.create_from_image(image)
	moisture_overlay.texture = texture
	moisture_overlay.centered = false
	moisture_overlay.scale = Vector2(tile_size, tile_size)
	moisture_overlay.position = Vector2.ZERO
	_update_moisture_overlay_visibility()

func _moisture_to_color(moisture: float) -> Color:
	var dry := Color(0.55, 0.35, 0.18, 0.45)
	var wet := Color(0.15, 0.55, 0.9, 0.45)
	return dry.lerp(wet, clampf(moisture, 0.0, 1.0))

func _update_moisture_overlay_visibility() -> void:
	if moisture_overlay == null:
		return
	moisture_overlay.visible = _moisture_overlay_enabled and not _is_globe_view

func _update_biome_overlay() -> void:
	if biome_overlay == null:
		return
	if _biome_map.is_empty():
		biome_overlay.texture = null
		return
	var image := Image.create(map_size.x, map_size.y, false, Image.FORMAT_RGBA8)
	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord := Vector2i(x, y)
			var biome := _biome_map.get(coord, BIOME_GRASSLAND) as String
			image.set_pixel(x, y, _biome_to_overlay_color(biome))
	var texture := ImageTexture.create_from_image(image)
	biome_overlay.texture = texture
	biome_overlay.centered = false
	biome_overlay.scale = Vector2(tile_size, tile_size)
	biome_overlay.position = Vector2.ZERO
	_update_biome_overlay_visibility()

func _biome_to_overlay_color(biome: String) -> Color:
	var alpha := 0.45
	match biome:
		BIOME_WATER:
			return Color(0.1, 0.35, 0.75, alpha)
		BIOME_MOUNTAIN:
			return Color(0.55, 0.55, 0.6, alpha)
		BIOME_HILLS:
			return Color(0.6, 0.45, 0.25, alpha)
		BIOME_MARSH:
			return Color(0.2, 0.6, 0.45, alpha)
		BIOME_TUNDRA:
			return Color(0.75, 0.8, 0.9, alpha)
		BIOME_DESERT:
			return Color(0.9, 0.75, 0.35, alpha)
		BIOME_BADLANDS:
			return Color(0.7, 0.35, 0.25, alpha)
		BIOME_FOREST:
			return Color(0.2, 0.55, 0.25, alpha)
		BIOME_JUNGLE:
			return Color(0.15, 0.45, 0.2, alpha)
		BIOME_GRASSLAND:
			return Color(0.35, 0.7, 0.35, alpha)
	return Color(0.5, 0.5, 0.5, alpha)

func _update_biome_overlay_visibility() -> void:
	if biome_overlay == null:
		return
	biome_overlay.visible = _biome_overlay_enabled and not _is_globe_view

func _apply_cached_world_settings() -> void:
	var game_session := get_node_or_null("/root/GameSession")
	if game_session == null:
		return
	if game_session.has_method("get_world_settings"):
		var settings: Dictionary = game_session.call("get_world_settings")
		_world_settings = settings.duplicate(true)
		if settings.has("map_dimensions"):
			map_size = settings["map_dimensions"]
	_configure_globe_viewport()
	_update_globe_texture()
