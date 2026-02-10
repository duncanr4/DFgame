extends Node2D

@export var map_size: Vector2i = Vector2i(256, 256)
@export var water_level: float = 0.45
@export var falloff_strength: float = 0.0
@export var falloff_power: float = 2.4
@export var noise_frequency: float = 2.0
@export var noise_octaves: int = 4
@export var hill_level: float = 0.72
@export var mountain_level: float = 0.82
@export var landmass_center_count: int = 4
@export var landmass_center_margin: float = 0.12
@export var landmass_falloff_scale: float = 1.35
@export var landmass_mask_strength: float = 0.0
@export var landmass_mask_power: float = 0.82
@export_range(0.0, 0.5, 0.01) var edge_ocean_strength: float = 0.2
@export_range(0.05, 1.0, 0.01) var edge_ocean_falloff: float = 0.32
@export_range(0.5, 4.0, 0.1) var edge_ocean_curve: float = 1.6
@export var temperature_frequency: float = 1.2
@export var rainfall_frequency: float = 1.7
@export var map_seed: int = 0
@export var tile_size: int = 32
@export var globe_rotation_speed: float = 0.0625
@export var globe_drag_sensitivity: float = 0.008
@export var globe_zoom_step: float = 0.35
@export var globe_min_camera_distance: float = 2.4
@export var globe_max_camera_distance: float = 8.0
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

const FOREST_NAME_PREFIXES: Array[String] = [
	"Verdant",
	"Whispering",
	"Emerald",
	"Silver",
	"Shadow",
	"Golden",
	"Moonlit",
	"Ancient",
	"Wild",
	"Sunset"
]
const FOREST_NAME_SUFFIXES: Array[String] = [
	"Groves",
	"Woods",
	"Thicket",
	"Wilds",
	"Canopy",
	"Boughs",
	"Hollows",
	"Glade",
	"Expanse",
	"Reserve"
]
const FOREST_NAME_MOTIFS: Array[String] = [
	"Echoes",
	"Mists",
	"Cicadas",
	"Fables",
	"Starlight",
	"Owls",
	"Whispers",
	"Lanterns",
	"Spirits",
	"Willows"
]

const MOUNTAIN_NAME_PREFIXES: Array[String] = [
	"Stone",
	"Iron",
	"Storm",
	"Thunder",
	"Frost",
	"Dragon",
	"Obsidian",
	"Moon",
	"Sunspire",
	"Titan"
]
const MOUNTAIN_NAME_SUFFIXES: Array[String] = [
	"Peaks",
	"Range",
	"Highlands",
	"Crown",
	"Mountains",
	"Spines",
	"Escarpment",
	"Ridge",
	"Tor",
	"Bastions"
]
const MOUNTAIN_NAME_MOTIFS: Array[String] = [
	"Storms",
	"Giants",
	"Dawn",
	"Ash",
	"Echoes",
	"Legends",
	"Stars",
	"Anvils",
	"Dragons",
	"Auroras"
]

const DESERT_NAME_DESCRIPTORS: Array[String] = [
	"Shifting",
	"Burning",
	"Golden",
	"Silent",
	"Glass",
	"Crimson",
	"Howling",
	"Endless",
	"Scoured",
	"Sunken"
]
const DESERT_NAME_NOUNS: Array[String] = [
	"Dunes",
	"Waste",
	"Expanse",
	"Sea",
	"Desert",
	"Reach",
	"Barrens",
	"Quarter",
	"Wastes",
	"Sands"
]
const DESERT_NAME_MOTIFS: Array[String] = [
	"Mirages",
	"Ashes",
	"Suns",
	"Bones",
	"Scorpions",
	"Dust",
	"Secrets",
	"Hollows",
	"Echoes",
	"Zephyrs"
]

const TUNDRA_NAME_DESCRIPTORS: Array[String] = [
	"Frozen",
	"Ivory",
	"Bleak",
	"Glimmering",
	"Shivering",
	"Frostbound",
	"Auric",
	"Pale",
	"Windshorn",
	"Starlit"
]
const TUNDRA_NAME_NOUNS: Array[String] = [
	"Tundra",
	"Reach",
	"Steppes",
	"Barrens",
	"Fields",
	"Expanse",
	"Marches",
	"Plateau",
	"Glade",
	"March"
]
const TUNDRA_NAME_MOTIFS: Array[String] = [
	"Auroras",
	"Frost",
	"Comets",
	"Stars",
	"Echoes",
	"Drifts",
	"Owls",
	"Lights",
	"Mammoths",
	"Silence"
]

const GRASSLAND_NAME_DESCRIPTORS: Array[String] = [
	"Windward",
	"Emerald",
	"Golden",
	"Rolling",
	"Open",
	"Skylit",
	"Silver",
	"Gentle",
	"Breezy",
	"Sunlit"
]
const GRASSLAND_NAME_NOUNS: Array[String] = [
	"Plains",
	"Meadows",
	"Fields",
	"Prairies",
	"Steppes",
	"Expanse",
	"Downs",
	"Reach",
	"Hearth",
	"Lowlands"
]
const GRASSLAND_NAME_MOTIFS: Array[String] = [
	"Larks",
	"Horizon",
	"Harvests",
	"Echoes",
	"Sunsets",
	"Breezes",
	"Lanterns",
	"Auroras",
	"Stones",
	"Dreams"
]

const JUNGLE_NAME_DESCRIPTORS: Array[String] = [
	"Emerald",
	"Verdant",
	"Sun-dappled",
	"Obsidian",
	"Mist-shrouded",
	"Ancient",
	"Thundering",
	"Canopy",
	"Moonlit",
	"Serpent"
]
const JUNGLE_NAME_NOUNS: Array[String] = [
	"Jungle",
	"Wilds",
	"Canopy",
	"Rainforest",
	"Tangle",
	"Deepwood",
	"Labyrinth",
	"Greenway",
	"Expanse",
	"Verdure"
]
const JUNGLE_NAME_MOTIFS: Array[String] = [
	"Serpents",
	"Drums",
	"Monsoons",
	"Spirits",
	"Cenotes",
	"Orchids",
	"Tempests",
	"Roots",
	"Jaguar Spirits",
	"Emerald Dawn"
]

const MARSH_NAME_DESCRIPTORS: Array[String] = [
	"Glimmer",
	"Mire",
	"Gloom",
	"Low",
	"Sodden",
	"Willow",
	"Brackish",
	"Sable",
	"Sunken",
	"Twilight"
]
const MARSH_NAME_NOUNS: Array[String] = [
	"Bog",
	"Fen",
	"Morass",
	"Quagmire",
	"Wetlands",
	"Mires",
	"Marsh",
	"Reeds",
	"Pools",
	"Sinks"
]
const MARSH_NAME_MOTIFS: Array[String] = [
	"Fireflies",
	"Lilies",
	"Secrets",
	"Mist",
	"Echoes",
	"Cranes",
	"Reeds",
	"Moss",
	"Shadows",
	"Frogs"
]

const BADLANDS_NAME_DESCRIPTORS: Array[String] = [
	"Shattered",
	"Redstone",
	"Sundered",
	"Dustfallen",
	"Sunblasted",
	"Windswept",
	"Bleached",
	"Broken",
	"Scorched",
	"Cracked"
]
const BADLANDS_NAME_NOUNS: Array[String] = [
	"Badlands",
	"Wastes",
	"Breaks",
	"Barrens",
	"Tablelands",
	"Escarpment",
	"Canyons",
	"Bluffs",
	"Ridges",
	"Maze"
]
const BADLANDS_NAME_MOTIFS: Array[String] = [
	"Bones",
	"Dust",
	"Echoes",
	"Thunderheads",
	"Vultures",
	"Ash",
	"Mirages",
	"Sunstorms",
	"Ruins",
	"Storms"
]

const OCEAN_NAME_DESCRIPTORS: Array[String] = [
	"Sapphire",
	"Tempest",
	"Sunken",
	"Cerulean",
	"Midnight",
	"Gilded",
	"Storm",
	"Azure",
	"Silent",
	"Everdeep"
]
const OCEAN_NAME_NOUNS: Array[String] = [
	"Sea",
	"Ocean",
	"Gulf",
	"Sound",
	"Reach",
	"Current",
	"Depths",
	"Expanse",
	"Waters",
	"Strait"
]
const OCEAN_NAME_MOTIFS: Array[String] = [
	"Sirens",
	"Stars",
	"Moons",
	"Whales",
	"Voyagers",
	"Storms",
	"Legends",
	"Coral",
	"Mists",
	"Echoes"
]

const LAKE_NAME_DESCRIPTORS: Array[String] = [
	"Silver",
	"Crystal",
	"Mirror",
	"Still",
	"Glimmer",
	"Duskwater",
	"Bright",
	"Moon",
	"Amber",
	"Serene"
]
const LAKE_NAME_NOUNS: Array[String] = [
	"Lake",
	"Mere",
	"Loch",
	"Pond",
	"Basin",
	"Reservoir",
	"Waters",
	"Lagoon",
	"Pool",
	"Bay"
]
const LAKE_NAME_MOTIFS: Array[String] = [
	"Echoes",
	"Willows",
	"Lanterns",
	"Dreams",
	"Reflections",
	"Whispers",
	"Herons",
	"Lilies",
	"Dawn",
	"Stars"
]

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
const DWARFHOLD_NEARBY_TOWN_RADIUS := 12.0
const DWARFHOLD_POPULATION_RACE_OPTIONS := [
	{"key": "dwarves", "label": "Dwarves", "color": Color("#f4c069")},
	{"key": "humans", "label": "Humans", "color": Color("#9bb6d8")},
	{"key": "halflings", "label": "Halflings", "color": Color("#f7a072")},
	{"key": "gnomes", "label": "Gnomes", "color": Color("#c9a3e6")},
	{"key": "goblins", "label": "Goblins", "color": Color("#7f8c4d")},
	{"key": "kobolds", "label": "Kobolds", "color": Color("#b1c8ff")},
	{"key": "others", "label": "Others", "color": Color("#9e9e9e")}
]
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
const DWARFHOLD_CLANS: Array[String] = [
	"Stonebeard",
	"Ironfist",
	"Deepdelve",
	"Bronzeborn",
	"Hammerfall",
	"Oakenshield",
	"Flintforge",
	"Granitejaw",
	"Runebinder",
	"Grimhelm",
	"Goldvein",
	"Frostmantle",
	"Fireforge",
	"Emberbrand",
	"Blackhammer"
]
const DWARFHOLD_RULER_TITLES: Array[String] = [
	"Thane",
	"High Thane",
	"Forge-Lord",
	"Shieldthane",
	"Deepwarden",
	"Runesmith",
	"Iron Regent"
]
const DARK_DWARFHOLD_RULER_TITLES: Array[String] = [
	"Sorcerer-Prophet",
	"Ash Lord",
	"Obsidian Warden",
	"Flame Regent",
	"Deep Ember"
]
const DWARFHOLD_RULER_NAMES: Array[String] = [
	"Urist",
	"Thrain",
	"Borin",
	"Durin",
	"Gimli",
	"Khazad",
	"Rurik",
	"Dwalin",
	"Oin",
	"Fundin",
	"Balin",
	"Kili",
	"Thorin",
	"Nori"
]
const DWARFHOLD_GUILDS: Array[String] = [
	"Miners Guild",
	"Smiths Guild",
	"Stonewright Circle",
	"Runecarver Lodge",
	"Brewers Consortium",
	"Machinists Union",
	"Cartographers Hall"
]
const DWARFHOLD_EXPORTS: Array[String] = [
	"Iron ingots",
	"Steel tools",
	"Gemstones",
	"Runed stone",
	"Fine ale",
	"Machined gears",
	"Obsidian glass",
	"Granite blocks"
]
const DWARFHOLD_HALLMARKS: Array[String] = [
	"Renowned for its rune-forges and unbroken gates.",
	"Known for echoing halls lined with gilded reliefs.",
	"Famous for masterwork arms traded across the realm.",
	"Guarded by a renowned shieldwall of veteran thanes.",
	"Caravans arrive daily with ore from the lower delves."
]
const DWARFHOLD_ABANDONED_HALLMARKS: Array[String] = [
	"Silent halls lie sealed behind collapsed tunnels.",
	"Only the rumble of distant stonefall breaks the quiet.",
	"Old banners hang tattered above shuttered gates.",
	"Echoes of abandoned forges linger in the dust."
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
@onready var terrain_shading_overlay: Sprite2D = get_node_or_null("MapOverlays/TerrainShadingOverlay")
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
@onready var tooltip_biome: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipGrid/TooltipBiome")
@onready var tooltip_climate: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipGrid/TooltipClimate")
@onready var tooltip_resources: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipGrid/TooltipResources")
@onready var tooltip_settlement: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipGrid/TooltipSettlement")
@onready var tooltip_population: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipGrid/TooltipPopulation")
@onready var tooltip_ruler: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipGrid/TooltipRuler")
@onready var tooltip_founded: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipGrid/TooltipFounded")
@onready var tooltip_prominent_clan: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipGrid/TooltipProminentClan")
@onready var tooltip_major_clans: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipGrid/TooltipMajorClans")
@onready var tooltip_major_guilds: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipGrid/TooltipMajorGuilds")
@onready var tooltip_major_exports: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipGrid/TooltipMajorExports")
@onready var tooltip_hallmark: Label = get_node_or_null("MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipGrid/TooltipHallmark")
@onready var tooltip_population_breakdown_section: Control = get_node_or_null(
	"MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipPopulationBreakdown"
)
@onready var tooltip_population_breakdown_list: VBoxContainer = get_node_or_null(
	"MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipPopulationBreakdown/PopulationBreakdownContent/PopulationBreakdownList"
)
@onready var tooltip_population_pie_chart: Control = get_node_or_null(
	"MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipPopulationBreakdown/PopulationBreakdownContent/PopulationPieChart"
)
@onready var tooltip_population_history_section: Control = get_node_or_null(
	"MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipPopulationHistory"
)
@onready var tooltip_population_history_chart: Control = get_node_or_null(
	"MapUi/MapTooltip/TooltipMargin/TooltipVBox/TooltipPopulationHistory/PopulationHistoryChart"
)

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
var _is_dragging_globe := false
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
	if _is_globe_view and _handle_globe_input(event):
		return
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
	var name_rng := RandomNumberGenerator.new()
	if map_seed == 0:
		rng.randomize()
		map_seed = rng.randi()
	else:
		rng.seed = map_seed
	name_rng.seed = map_seed + 911
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
	_apply_overlays_and_metadata(
		base_biome_map,
		biome_map,
		highland_map,
		height_map,
		temperature_map,
		moisture_map,
		name_rng
	)
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
	_update_terrain_shading_overlay(base_biome_map)
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
	height_map: Dictionary,
	temperature_map: Dictionary,
	moisture_map: Dictionary,
	name_rng: RandomNumberGenerator
) -> void:
	var coast_proximity_map := _build_proximity_map(base_biome_map, [BIOME_WATER], 8)
	var marsh_proximity_map := _build_proximity_map(base_biome_map, [BIOME_MARSH], 7)
	var desert_proximity_map := _build_proximity_map(base_biome_map, [BIOME_DESERT, BIOME_BADLANDS], 8)
	var forest_proximity_map := _build_proximity_map(base_biome_map, [BIOME_FOREST, BIOME_JUNGLE], 6)
	var context_size := maxi(map_size.x, map_size.y)
	var region_names := _build_region_name_map(biome_map, name_rng, context_size)
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
			var region_name := String(region_names.get(coord, ""))
			_tile_data[coord] = {
				"biome_type": biome,
				"base_biome": base_biome,
				"surface_variation": _surface_variation_for_coord(coord, base_biome),
				"water_depth": _water_depth_for_coord(coord, base_biome, height_map),
				"coast_proximity": float(coast_proximity_map.get(coord, 0.0)),
				"marsh_proximity": float(marsh_proximity_map.get(coord, 0.0)),
				"desert_proximity": float(desert_proximity_map.get(coord, 0.0)),
				"forest_canopy_density": float(forest_proximity_map.get(coord, 0.0)),
				"temperature": temperature_map.get(coord, 0.0),
				"moisture": moisture_map.get(coord, 0.0),
				"resources": _resources_for_biome(biome),
				"region_name": region_name
			}


func _build_proximity_map(biome_map: Dictionary, target_biomes: Array[String], max_distance: int) -> Dictionary:
	var proximity_map: Dictionary = {}
	if max_distance <= 0 or target_biomes.is_empty():
		return proximity_map
	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord := Vector2i(x, y)
			var nearest := max_distance + 1
			for oy in range(-max_distance, max_distance + 1):
				var ny := y + oy
				if ny < 0 or ny >= map_size.y:
					continue
				for ox in range(-max_distance, max_distance + 1):
					var nx := x + ox
					if nx < 0 or nx >= map_size.x:
						continue
					var sample_coord := Vector2i(nx, ny)
					if not target_biomes.has(String(biome_map.get(sample_coord, BIOME_GRASSLAND))):
						continue
					var distance := maxi(absi(ox), absi(oy))
					if distance < nearest:
						nearest = distance
						if nearest == 0:
							break
				if nearest == 0:
					break
			if nearest > max_distance:
				proximity_map[coord] = 0.0
			else:
				proximity_map[coord] = clampf(1.0 - float(nearest) / float(max_distance), 0.0, 1.0)
	return proximity_map


func _surface_variation_for_coord(coord: Vector2i, base_biome: String) -> float:
	if base_biome != BIOME_TUNDRA and base_biome != BIOME_DESERT and base_biome != BIOME_BADLANDS:
		return 0.0
	var coarse := _to_normalized(_rainfall_noise.get_noise_2d(float(coord.x) * 0.8, float(coord.y) * 0.8))
	var detail := _to_normalized(_temperature_noise.get_noise_2d(float(coord.x) * 2.3, float(coord.y) * 2.3))
	return clampf((coarse * 0.65 + detail * 0.35 - 0.5) * 1.6, -1.0, 1.0)


func _water_depth_for_coord(coord: Vector2i, base_biome: String, height_map: Dictionary) -> float:
	if base_biome != BIOME_WATER:
		return 0.0
	var height := float(height_map.get(coord, water_level))
	if water_level <= 0.001:
		return 0.0
	return clampf((water_level - height) / water_level, 0.0, 1.0)


func _update_terrain_shading_overlay(base_biome_map: Dictionary) -> void:
	if terrain_shading_overlay == null:
		return
	var shading_image := Image.create(map_size.x, map_size.y, false, Image.FORMAT_RGBA8)
	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord := Vector2i(x, y)
			var tile_meta := _tile_data.get(coord, {}) as Dictionary
			var base_biome := String(tile_meta.get("base_biome", base_biome_map.get(coord, BIOME_GRASSLAND)))
			var color := Color(0, 0, 0, 0)
			color = _apply_surface_noise_shading_to_color(color, base_biome, float(tile_meta.get("surface_variation", 0.0)))
			color = _apply_coastal_shading_to_color(color, base_biome, String(tile_meta.get("biome_type", base_biome)), tile_meta)
			shading_image.set_pixel(x, y, color)
	var shading_texture := ImageTexture.create_from_image(shading_image)
	terrain_shading_overlay.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	terrain_shading_overlay.centered = false
	terrain_shading_overlay.position = Vector2.ZERO
	terrain_shading_overlay.scale = Vector2(float(tile_size), float(tile_size))
	terrain_shading_overlay.texture = shading_texture


func _apply_surface_noise_shading_to_color(base_color: Color, base_biome: String, variation: float) -> Color:
	if base_biome != BIOME_TUNDRA and base_biome != BIOME_DESERT and base_biome != BIOME_BADLANDS:
		return base_color
	var v := clampf(variation, -1.0, 1.0)
	if absf(v) < 0.01:
		return base_color
	var lighten := v > 0.0
	var intensity := absf(v)
	if base_biome == BIOME_TUNDRA:
		if lighten:
			return _blend_overlay_color(base_color, Color8(255, 255, 255), clampf(0.1 + intensity * 0.28, 0.0, 0.55))
		return _blend_overlay_color(base_color, Color8(120, 146, 182), clampf(0.08 + intensity * 0.26, 0.0, 0.55))
	if base_biome == BIOME_DESERT:
		if lighten:
			return _blend_overlay_color(base_color, Color8(255, 236, 192), clampf(0.08 + intensity * 0.24, 0.0, 0.55))
		return _blend_overlay_color(base_color, Color8(184, 140, 78), clampf(0.08 + intensity * 0.22, 0.0, 0.55))
	if lighten:
		return _blend_overlay_color(base_color, Color8(235, 206, 168), clampf(0.08 + intensity * 0.22, 0.0, 0.55))
	return _blend_overlay_color(base_color, Color8(143, 102, 66), clampf(0.08 + intensity * 0.24, 0.0, 0.55))


func _apply_coastal_shading_to_color(base_color: Color, base_biome: String, biome_type: String, tile_meta: Dictionary) -> Color:
	var color := base_color
	if base_biome == BIOME_WATER:
		var shallow_factor := clampf(1.0 - float(tile_meta.get("water_depth", 0.0)), 0.0, 1.0)
		if shallow_factor > 0.01:
			color = _blend_overlay_color(color, Color8(88, 164, 218), shallow_factor * 0.32)
		return color
	if base_biome != BIOME_GRASSLAND:
		return color
	var coast_proximity := clampf(float(tile_meta.get("coast_proximity", 0.0)), 0.0, 1.0)
	if coast_proximity > 0.01:
		color = _blend_overlay_color(color, Color8(148, 205, 184), coast_proximity * 0.32)
	var marsh_proximity := clampf(float(tile_meta.get("marsh_proximity", 0.0)), 0.0, 1.0)
	if marsh_proximity > 0.01:
		color = _blend_overlay_color(color, Color8(82, 64, 40), marsh_proximity * 0.55)
	var forest_density := clampf(float(tile_meta.get("forest_canopy_density", 0.0)), 0.0, 1.0)
	if biome_type == BIOME_FOREST and forest_density > 0.01:
		color = _blend_overlay_color(color, Color8(26, 74, 36), forest_density * 0.55)
	var desert_proximity := clampf(float(tile_meta.get("desert_proximity", 0.0)), 0.0, 1.0)
	if desert_proximity > 0.01:
		color = _blend_overlay_color(color, Color8(228, 202, 146), desert_proximity * 0.4)
	return color


func _blend_overlay_color(base_color: Color, tint_color: Color, alpha: float) -> Color:
	var overlay_alpha := clampf(alpha, 0.0, 1.0)
	if overlay_alpha <= 0.0:
		return base_color
	var out_alpha := overlay_alpha + base_color.a * (1.0 - overlay_alpha)
	if out_alpha <= 0.0001:
		return Color(0, 0, 0, 0)
	var out_r := (tint_color.r * overlay_alpha + base_color.r * base_color.a * (1.0 - overlay_alpha)) / out_alpha
	var out_g := (tint_color.g * overlay_alpha + base_color.g * base_color.a * (1.0 - overlay_alpha)) / out_alpha
	var out_b := (tint_color.b * overlay_alpha + base_color.b * base_color.a * (1.0 - overlay_alpha)) / out_alpha
	return Color(out_r, out_g, out_b, out_alpha)

func _build_region_name_map(
	biome_map: Dictionary,
	rng: RandomNumberGenerator,
	context_size: int
) -> Dictionary:
	var region_names := {}
	for y in range(map_size.y):
		for x in range(map_size.x):
			var start := Vector2i(x, y)
			if region_names.has(start):
				continue
			var biome := String(biome_map.get(start, BIOME_GRASSLAND))
			var water_body_type := ""
			if biome == BIOME_WATER:
				water_body_type = _water_region_type(start, biome_map)
			var region_name := _generate_biome_region_name(biome, water_body_type, rng, context_size)
			var frontier: Array[Vector2i] = [start]
			while not frontier.is_empty():
				var coord: Vector2i = frontier.pop_back()
				if region_names.has(coord):
					continue
				if String(biome_map.get(coord, BIOME_GRASSLAND)) != biome:
					continue
				region_names[coord] = region_name
				for offset: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
					var neighbor: Vector2i = coord + offset
					if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= map_size.x or neighbor.y >= map_size.y:
						continue
					if region_names.has(neighbor):
						continue
					if String(biome_map.get(neighbor, BIOME_GRASSLAND)) == biome:
						frontier.append(neighbor)
	return region_names

func _water_region_type(start_coord: Vector2i, biome_map: Dictionary) -> String:
	var frontier: Array[Vector2i] = [start_coord]
	var visited := {}
	while not frontier.is_empty():
		var coord: Vector2i = frontier.pop_back()
		if visited.has(coord):
			continue
		if String(biome_map.get(coord, BIOME_GRASSLAND)) != BIOME_WATER:
			continue
		visited[coord] = true
		if coord.x == 0 or coord.y == 0 or coord.x == map_size.x - 1 or coord.y == map_size.y - 1:
			return "ocean"
		for offset: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var neighbor: Vector2i = coord + offset
			if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= map_size.x or neighbor.y >= map_size.y:
				continue
			if visited.has(neighbor):
				continue
			if String(biome_map.get(neighbor, BIOME_GRASSLAND)) == BIOME_WATER:
				frontier.append(neighbor)
	return "lake"

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
	var continent := _to_normalized(continent_noise.get_noise_2d(float(x), float(y)))
	var detail := _to_normalized(detail_noise.get_noise_2d(float(x), float(y)))
	var ridges := 1.0 - absf(ridge_noise.get_noise_2d(float(x), float(y)))
	var height := continent * 0.72 + detail * 0.18 + ridges * 0.1
	var archipelago := (_to_normalized(detail_noise.get_noise_2d(float(x) * 2.6, float(y) * 2.6)) - 0.5) * 0.12
	height += archipelago
	var continent_bias := _sample_continent_bias(x, y)
	height += continent_bias
	var coast_mask := 1.0 - clampf(absf(height - water_level) / 0.15, 0.0, 1.0)
	var coast_jag := detail_noise.get_noise_2d(float(x) * 5.1, float(y) * 5.1) * 0.06 * coast_mask
	return clampf(height + coast_jag, 0.0, 1.0)


func _sample_continent_bias(x: int, y: int) -> float:
	var denom_x := maxf(1.0, float(map_size.x - 1))
	var denom_y := maxf(1.0, float(map_size.y - 1))
	var nx := float(x) / denom_x
	var ny := float(y) / denom_y
	var base_seed := map_seed + 0x6a09e667
	var fractal := (_value_noise(nx * 18.0 + 2.3, ny * 18.0 + 9.7, base_seed) - 0.5) * 0.1
	fractal += (_value_noise(nx * 42.0 + 13.1, ny * 42.0 + 5.4, base_seed + 0xbb67ae85) - 0.5) * 0.05
	return fractal + _sample_edge_ocean_bias(x, y)


func _sample_edge_ocean_bias(x: int, y: int) -> float:
	var max_x := maxf(1.0, float(map_size.x - 1))
	var max_y := maxf(1.0, float(map_size.y - 1))
	var edge_distance := minf(minf(float(x), max_x - float(x)), minf(float(y), max_y - float(y)))
	var half_span := minf(max_x, max_y) * 0.5
	var edge_normalized := clampf(edge_distance / maxf(half_span, 1.0), 0.0, 1.0)
	var edge_ratio := clampf(edge_normalized / maxf(edge_ocean_falloff, 0.01), 0.0, 1.0)
	var edge_ocean := 1.0 - pow(edge_ratio, edge_ocean_curve)
	var interior_support := pow(clampf(edge_normalized, 0.0, 1.0), 2.2) * (edge_ocean_strength * 0.28)
	return interior_support - edge_ocean * edge_ocean_strength


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
			if settlement_type == "dwarfhold":
				tile_info.merge(_generate_dwarfhold_details(settlement_name, chosen, tile, rng), true)
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

func _generate_biome_region_name(
	biome: String,
	water_body_type: String,
	rng: RandomNumberGenerator,
	context_size: int
) -> String:
	match biome:
		BIOME_FOREST:
			return _generate_forest_name(rng)
		BIOME_MOUNTAIN, BIOME_HILLS:
			return _generate_mountain_name(rng)
		BIOME_DESERT:
			return _generate_desert_name(rng)
		BIOME_TUNDRA:
			return _generate_tundra_name(rng)
		BIOME_GRASSLAND:
			return _generate_grassland_name(rng)
		BIOME_JUNGLE:
			return _generate_jungle_name(rng)
		BIOME_MARSH:
			return _generate_marsh_name(rng)
		BIOME_BADLANDS:
			return _generate_badlands_name(rng)
		BIOME_WATER:
			if water_body_type == "lake":
				return _generate_lake_name(rng)
			return _generate_ocean_name(rng, context_size)
		_:
			return ""

func _generate_forest_name(rng: RandomNumberGenerator) -> String:
	var prefix := _pick_random_entry(FOREST_NAME_PREFIXES, rng, "Verdant")
	var suffix := _pick_random_entry(FOREST_NAME_SUFFIXES, rng, "Woods")
	var motif := _pick_random_entry(FOREST_NAME_MOTIFS, rng)
	var roll := rng.randf()
	if roll < 0.34 and not motif.is_empty():
		return "%s %s of the %s" % [prefix, suffix, motif]
	if roll < 0.67:
		return "The %s %s" % [prefix, suffix]
	return "%s %s" % [prefix, suffix]

func _generate_mountain_name(rng: RandomNumberGenerator) -> String:
	var prefix := _pick_random_entry(MOUNTAIN_NAME_PREFIXES, rng, "Stone")
	var suffix := _pick_random_entry(MOUNTAIN_NAME_SUFFIXES, rng, "Peaks")
	var motif := _pick_random_entry(MOUNTAIN_NAME_MOTIFS, rng)
	var use_motif := rng.randf() < 0.5
	if use_motif and not motif.is_empty():
		return "%s %s of the %s" % [prefix, suffix, motif]
	return "The %s %s" % [prefix, suffix]

func _generate_desert_name(rng: RandomNumberGenerator) -> String:
	var descriptor := _pick_random_entry(DESERT_NAME_DESCRIPTORS, rng, "Shifting")
	var noun := _pick_random_entry(DESERT_NAME_NOUNS, rng, "Dunes")
	var motif := _pick_random_entry(DESERT_NAME_MOTIFS, rng)
	var use_motif := rng.randf() < 0.5
	if use_motif and not motif.is_empty():
		return "%s of the %s" % [noun, motif]
	return "The %s %s" % [descriptor, noun]

func _generate_tundra_name(rng: RandomNumberGenerator) -> String:
	var descriptor := _pick_random_entry(TUNDRA_NAME_DESCRIPTORS, rng, "Frozen")
	var noun := _pick_random_entry(TUNDRA_NAME_NOUNS, rng, "Tundra")
	var motif := _pick_random_entry(TUNDRA_NAME_MOTIFS, rng)
	var use_motif := rng.randf() < 0.5
	if use_motif and not motif.is_empty():
		return "%s of the %s" % [noun, motif]
	return "The %s %s" % [descriptor, noun]

func _generate_grassland_name(rng: RandomNumberGenerator) -> String:
	var descriptor := _pick_random_entry(GRASSLAND_NAME_DESCRIPTORS, rng, "Windward")
	var noun := _pick_random_entry(GRASSLAND_NAME_NOUNS, rng, "Plains")
	var motif := _pick_random_entry(GRASSLAND_NAME_MOTIFS, rng)
	var roll := rng.randf()
	if roll < 0.34 and not motif.is_empty():
		return "%s of the %s" % [noun, motif]
	if roll < 0.67:
		return "The %s %s" % [descriptor, noun]
	return "%s %s" % [descriptor, noun]

func _generate_jungle_name(rng: RandomNumberGenerator) -> String:
	var descriptor := _pick_random_entry(JUNGLE_NAME_DESCRIPTORS, rng, "Emerald")
	var noun := _pick_random_entry(JUNGLE_NAME_NOUNS, rng, "Jungle")
	var motif := _pick_random_entry(JUNGLE_NAME_MOTIFS, rng)
	var roll := rng.randf()
	if roll < 0.34 and not motif.is_empty():
		return "%s of the %s" % [noun, motif]
	if roll < 0.67:
		return "The %s %s" % [descriptor, noun]
	return "%s %s" % [descriptor, noun]

func _generate_marsh_name(rng: RandomNumberGenerator) -> String:
	var descriptor := _pick_random_entry(MARSH_NAME_DESCRIPTORS, rng, "Glimmer")
	var noun := _pick_random_entry(MARSH_NAME_NOUNS, rng, "Bog")
	var motif := _pick_random_entry(MARSH_NAME_MOTIFS, rng)
	var use_motif := rng.randf() < 0.5
	if use_motif and not motif.is_empty():
		return "%s %s of the %s" % [descriptor, noun, motif]
	return "The %s %s" % [descriptor, noun]

func _generate_badlands_name(rng: RandomNumberGenerator) -> String:
	var descriptor := _pick_random_entry(BADLANDS_NAME_DESCRIPTORS, rng, "Shattered")
	var noun := _pick_random_entry(BADLANDS_NAME_NOUNS, rng, "Badlands")
	var motif := _pick_random_entry(BADLANDS_NAME_MOTIFS, rng)
	var roll := rng.randf()
	if roll < 0.34 and not motif.is_empty():
		return "%s of the %s" % [noun, motif]
	if roll < 0.67:
		return "The %s %s" % [descriptor, noun]
	return "%s %s" % [descriptor, noun]

func _generate_ocean_name(rng: RandomNumberGenerator, context_size: int) -> String:
	var descriptor := _pick_random_entry(OCEAN_NAME_DESCRIPTORS, rng, "Sapphire")
	var noun := _pick_random_entry(OCEAN_NAME_NOUNS, rng, "Sea")
	var motif := _pick_random_entry(OCEAN_NAME_MOTIFS, rng)
	if context_size < 120 and noun == "Ocean":
		noun = "Sea"
	var use_motif := rng.randf() < 0.5
	if use_motif and not motif.is_empty():
		return "%s of the %s" % [noun, motif]
	return "The %s %s" % [descriptor, noun]

func _generate_lake_name(rng: RandomNumberGenerator) -> String:
	var descriptor := _pick_random_entry(LAKE_NAME_DESCRIPTORS, rng, "Silver")
	var noun := _pick_random_entry(LAKE_NAME_NOUNS, rng, "Lake")
	var motif := _pick_random_entry(LAKE_NAME_MOTIFS, rng)
	var lower_noun := noun.to_lower()
	var use_motif := rng.randf() < 0.5
	if lower_noun == "lake" or lower_noun == "loch":
		if use_motif and not motif.is_empty():
			return "%s %s" % [noun, motif]
		return "%s %s" % [noun, descriptor]
	if use_motif and not motif.is_empty():
		return "The %s %s of the %s" % [descriptor, noun, motif]
	return "The %s %s" % [descriptor, noun]

func _pick_random_entry(options: Array[String], rng: RandomNumberGenerator, fallback: String = "") -> String:
	if options.is_empty():
		return fallback
	return options[rng.randi_range(0, options.size() - 1)]

func _pick_unique_entries(
	options: Array[String],
	rng: RandomNumberGenerator,
	count: int,
	guaranteed: String = ""
) -> Array[String]:
	var pool: Array[String] = options.duplicate()
	var chosen: Array[String] = []
	if not guaranteed.is_empty():
		if pool.has(guaranteed):
			pool.erase(guaranteed)
		chosen.append(guaranteed)
	while chosen.size() < count and not pool.is_empty():
		var index := rng.randi_range(0, pool.size() - 1)
		chosen.append(pool[index])
		pool.remove_at(index)
	return chosen

func _has_nearby_settlement_type(
	coord: Vector2i,
	settlement_type: String,
	search_radius: float
) -> bool:
	if search_radius <= 0.0:
		return false
	for tile_coord: Vector2i in _tile_data.keys():
		var details: Dictionary = _tile_data.get(tile_coord, {}) as Dictionary
		if String(details.get("settlement_type", "")) != settlement_type:
			continue
		if coord.distance_to(tile_coord) <= search_radius:
			return true
	return false

func _sort_fraction_desc(a: Dictionary, b: Dictionary) -> bool:
	return float(a.get("fraction", 0.0)) > float(b.get("fraction", 0.0))

func _generate_dwarfhold_population_breakdown(
	population: int,
	has_nearby_human_settlement: bool,
	rng: RandomNumberGenerator
) -> Array[Dictionary]:
	if DWARFHOLD_POPULATION_RACE_OPTIONS.is_empty():
		return []

	var config_map := {}
	for option: Dictionary in DWARFHOLD_POPULATION_RACE_OPTIONS:
		var key := String(option.get("key", ""))
		if not key.is_empty():
			config_map[key] = option

	var dwarf_config: Dictionary = config_map.get("dwarves", {}) as Dictionary
	if dwarf_config.is_empty():
		return []

	var resolved_population := maxi(0, population)
	var majority_range := Vector2(0.9, 0.96)
	if has_nearby_human_settlement:
		majority_range = Vector2(0.85, 0.93)
	var dwarf_share := clampf(
		lerpf(majority_range.x, majority_range.y, rng.randf()),
		0.0,
		1.0
	)
	var shares: Array[Dictionary] = [{"config": dwarf_config, "share": dwarf_share}]
	var remainder_share := maxf(0.0, 1.0 - dwarf_share)

	var weight_plans := []
	if has_nearby_human_settlement:
		weight_plans = [
			{"key": "humans", "min": 0.9, "max": 1.6},
			{"key": "halflings", "min": 0.7, "max": 1.2},
			{"key": "gnomes", "min": 0.15, "max": 0.4},
			{"key": "goblins", "min": 0.12, "max": 0.35},
			{"key": "kobolds", "min": 0.12, "max": 0.35},
			{"key": "others", "min": 0.0, "max": 0.2}
		]
	else:
		weight_plans = [
			{"key": "gnomes", "min": 0.8, "max": 1.4},
			{"key": "goblins", "min": 0.9, "max": 1.5},
			{"key": "kobolds", "min": 0.7, "max": 1.2},
			{"key": "others", "min": 0.0, "max": 0.25}
		]

	var weight_entries: Array[Dictionary] = []
	for plan: Dictionary in weight_plans:
		var config: Dictionary = config_map.get(String(plan.get("key", "")), {}) as Dictionary
		if config.is_empty():
			continue
		var min_weight := maxf(0.0, float(plan.get("min", 0.0)))
		var max_weight := maxf(min_weight, float(plan.get("max", min_weight)))
		if max_weight <= 0.0:
			continue
		var weight := min_weight + rng.randf() * (max_weight - min_weight)
		if weight <= 0.0:
			continue
		weight_entries.append({"config": config, "weight": weight})

	var weight_sum := 0.0
	for entry: Dictionary in weight_entries:
		weight_sum += float(entry.get("weight", 0.0))

	if remainder_share > 0.0 and weight_sum > 0.0:
		for entry: Dictionary in weight_entries:
			var share := (float(entry.get("weight", 0.0)) / weight_sum) * remainder_share
			shares.append({"config": entry.get("config", {}), "share": share})

	var total_share := 0.0
	for entry: Dictionary in shares:
		total_share += float(entry.get("share", 0.0))
	var safe_total := total_share if total_share > 0.0 else 1.0

	var normalized_shares: Array[Dictionary] = []
	for entry: Dictionary in shares:
		var share := clampf(float(entry.get("share", 0.0)) / safe_total, 0.0, 1.0)
		normalized_shares.append({"config": entry.get("config", {}), "share": share})

	var percentage_decimals := 2
	var percentage_scale := int(pow(10, percentage_decimals))
	var total_units := 100 * percentage_scale

	var scaled_entries: Array[Dictionary] = []
	for entry: Dictionary in normalized_shares:
		var safe_share := clampf(float(entry.get("share", 0.0)), 0.0, 1.0)
		var raw_percentage := safe_share * 100.0
		var scaled_raw := raw_percentage * float(percentage_scale)
		var base_unit := int(floor(scaled_raw))
		var fraction := clampf(scaled_raw - float(base_unit), 0.0, 1.0)
		scaled_entries.append({
			"config": entry.get("config", {}),
			"base_unit": base_unit,
			"fraction": fraction
		})

	var base_units: Array[int] = []
	for entry: Dictionary in scaled_entries:
		base_units.append(int(entry.get("base_unit", 0)))
	var remainder_units := total_units
	for value: int in base_units:
		remainder_units -= value

	var fractional_order: Array[Dictionary] = []
	for index in range(scaled_entries.size()):
		fractional_order.append({"index": index, "fraction": float(scaled_entries[index].get("fraction", 0.0))})
	fractional_order.sort_custom(Callable(self, "_sort_fraction_desc"))

	if not fractional_order.is_empty():
		var increment_index := 0
		while remainder_units > 0:
			var target: Dictionary = fractional_order[increment_index % fractional_order.size()]
			var target_index := int(target.get("index", 0))
			base_units[target_index] += 1
			remainder_units -= 1
			increment_index += 1

		var ascending := fractional_order.duplicate()
		ascending.reverse()
		var decrement_index := 0
		while remainder_units < 0 and not ascending.is_empty():
			var target: Dictionary = ascending[decrement_index % ascending.size()]
			var target_index := int(target.get("index", 0))
			if base_units[target_index] > 0:
				base_units[target_index] -= 1
				remainder_units += 1
			decrement_index += 1

	if remainder_units != 0 and not base_units.is_empty():
		var last_index := base_units.size() - 1
		var adjusted := clampi(base_units[last_index] + remainder_units, 0, total_units)
		remainder_units -= adjusted - base_units[last_index]
		base_units[last_index] = adjusted

	var results: Array[Dictionary] = []
	for index in range(scaled_entries.size()):
		var config: Dictionary = scaled_entries[index].get("config", {}) as Dictionary
		var percentage := clampf(float(base_units[index]) / float(percentage_scale), 0.0, 100.0)
		var count := int(round(float(resolved_population) * percentage / 100.0))
		results.append({
			"key": String(config.get("key", "")),
			"label": String(config.get("label", "")),
			"color": config.get("color", Color.GRAY),
			"percentage": percentage,
			"population": count
		})
	return results

func _generate_population_timeline(
	population: int,
	rng: RandomNumberGenerator,
	founded_years_ago: int
) -> Array[Dictionary]:
	var resolved_population := maxi(0, population)
	if resolved_population <= 0:
		return []

	var points: Array[Dictionary] = []
	var steps := 5
	var base_start := maxf(30.0, float(resolved_population) * (0.35 + rng.randf() * 0.25))
	var current_value := base_start
	var labels := ["Founding", "Expansion", "Conflict", "Recovery", "Current"]
	var years_step := float(maxi(1, founded_years_ago)) / float(maxi(1, steps - 1))

	for index in range(steps):
		if index == steps - 1:
			current_value = float(resolved_population)
		else:
			var variance := rng.randf_range(-0.25, 0.25)
			current_value = clampf(
				current_value * (1.0 + variance),
				20.0,
				float(resolved_population) * 1.5
			)
		var years_ago := int(round(float(founded_years_ago) - years_step * float(index)))
		points.append({
			"label": labels[index],
			"population": int(round(current_value)),
			"years_ago": max(0, years_ago)
		})

	if points.size() > 1:
		points[points.size() - 1]["population"] = resolved_population
	return points

func _dwarfhold_classification_for_tile(tile: Vector2i) -> Dictionary:
	if tile == GREAT_DWARFHOLD_TILE:
		return {
			"key": "great",
			"label": "Great Dwarfhold",
			"population_range": Vector2i(4800, 12000)
		}
	if tile == DARK_DWARFHOLD_TILE:
		return {
			"key": "dark",
			"label": "Dark Dwarfhold",
			"population_range": Vector2i(1800, 7000)
		}
	if tile == ABANDONED_DWARFHOLD_TILE:
		return {
			"key": "abandoned",
			"label": "Abandoned Dwarfhold",
			"population_range": Vector2i(0, 0)
		}
	return {
		"key": "standard",
		"label": "Dwarfhold",
		"population_range": Vector2i(900, 4800)
	}

func _generate_dwarfhold_details(
	settlement_name: String,
	settlement_coord: Vector2i,
	settlement_tile: Vector2i,
	rng: RandomNumberGenerator
) -> Dictionary:
	var classification := _dwarfhold_classification_for_tile(settlement_tile)
	var classification_key := String(classification.get("key", ""))
	var details := {
		"settlement_classification": classification["label"],
		"population_label": "Population",
		"population_descriptor": "residents"
	}
	if classification_key == "abandoned":
		details["population"] = 0
		details["ruler_title"] = ""
		details["ruler_name"] = ""
		details["founded_years_ago"] = rng.randi_range(120, 3800)
		details["prominent_clan"] = ""
		details["major_clans"] = []
		details["major_guilds"] = []
		details["major_exports"] = []
		details["hallmark"] = _pick_random_entry(
			DWARFHOLD_ABANDONED_HALLMARKS,
			rng,
			"Silent halls lie sealed behind collapsed tunnels."
		)
		details["description"] = "Dust and silence fill the abandoned chambers."
		return details

	var population_range: Vector2i = classification["population_range"]
	var population := rng.randi_range(population_range.x, population_range.y)
	var has_nearby_human_settlement := _has_nearby_settlement_type(
		settlement_coord,
		"town",
		DWARFHOLD_NEARBY_TOWN_RADIUS
	)
	var clan := _pick_random_entry(DWARFHOLD_CLANS, rng, "Stonebeard")
	var ruler_first := _pick_random_entry(DWARFHOLD_RULER_NAMES, rng, "Urist")
	var is_dark: bool = classification_key == "dark"
	var ruler_title := (
		_pick_random_entry(DARK_DWARFHOLD_RULER_TITLES, rng, "Sorcerer-Prophet")
		if is_dark
		else _pick_random_entry(DWARFHOLD_RULER_TITLES, rng, "Thane")
	)
	details["population"] = population
	details["ruler_title"] = ruler_title
	details["ruler_name"] = "%s %s" % [ruler_first, clan]
	details["founded_years_ago"] = rng.randi_range(60, 3200)
	details["prominent_clan"] = clan
	var major_clan_count := rng.randi_range(2, 4)
	details["major_clans"] = _pick_unique_entries(DWARFHOLD_CLANS, rng, major_clan_count, clan)
	var guild_count := rng.randi_range(2, 3)
	var guilds := _pick_unique_entries(DWARFHOLD_GUILDS, rng, guild_count)
	if is_dark and not guilds.has("Ashforged Covenant"):
		guilds.append("Ashforged Covenant")
	details["major_guilds"] = guilds
	var export_count := rng.randi_range(2, 3)
	var exports := _pick_unique_entries(DWARFHOLD_EXPORTS, rng, export_count)
	if is_dark:
		exports.append("Obsidian ingots")
	details["major_exports"] = exports
	var hallmark := _pick_random_entry(
		DWARFHOLD_HALLMARKS,
		rng,
		"Renowned for its rune-forges and unbroken gates."
	)
	if is_dark:
		hallmark = "%s Magma channels keep the forges blazing." % hallmark
	details["hallmark"] = hallmark
	details["description"] = "The hold of %s anchors nearby trade routes." % settlement_name
	var population_breakdown := _generate_dwarfhold_population_breakdown(
		population,
		has_nearby_human_settlement,
		rng
	)
	var founded_years_ago := int(details.get("founded_years_ago", 0))
	var population_timeline := _generate_population_timeline(population, rng, founded_years_ago)
	if is_dark:
		for entry in population_breakdown:
			if String(entry.get("key", "")) == "dwarves":
				entry["label"] = "Dark Dwarves"
				entry["color"] = Color("#3b2a3d")
	details["population_breakdown"] = population_breakdown
	details["population_timeline"] = population_timeline
	return details

func _set_tooltip_label(label: Label, text: String, should_show: bool) -> void:
	if label == null:
		return
	label.visible = should_show
	if should_show:
		label.text = text
	var key_label: Label = null
	var parent := label.get_parent()
	if parent != null:
		var previous_index := label.get_index() - 1
		if previous_index >= 0 and previous_index < parent.get_child_count():
			key_label = parent.get_child(previous_index) as Label
	if key_label != null:
		key_label.visible = should_show

func _set_tooltip_section_visible(node: CanvasItem, should_show: bool) -> void:
	if node == null:
		return
	node.visible = should_show

func _format_population_breakdown_entry(entry: Dictionary) -> String:
	var label := String(entry.get("label", "")).strip_edges()
	var percentage := float(entry.get("percentage", 0.0))
	var population := int(entry.get("population", 0))
	var parts: Array[String] = []
	if not label.is_empty():
		parts.append(label)
	if percentage > 0.0:
		parts.append("%0.2f%%" % percentage)
	if population > 0:
		parts.append("(%s)" % str(population))
	return " ".join(parts)

func _populate_population_breakdown_list(breakdown: Array) -> void:
	if tooltip_population_breakdown_list == null:
		return
	for child in tooltip_population_breakdown_list.get_children():
		child.queue_free()
	var sorted_breakdown := breakdown.duplicate()
	sorted_breakdown.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return int(b.get("population", 0)) < int(a.get("population", 0))
	)
	for entry: Dictionary in sorted_breakdown:
		if float(entry.get("percentage", 0.0)) <= 0.0:
			continue
		if int(entry.get("population", 0)) <= 0:
			continue
		var label := Label.new()
		label.text = _format_population_breakdown_entry(entry)
		label.add_theme_font_size_override("font_size", 10)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tooltip_population_breakdown_list.add_child(label)

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
	if not enabled:
		_is_dragging_globe = false
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
		tooltip_biome.text = biome_label
	if tooltip_climate != null:
		tooltip_climate.text = _describe_climate(temperature, moisture)
	if tooltip_resources != null:
		var resource_text := _format_resource_list(resources)
		tooltip_resources.text = resource_text if not resource_text.is_empty() else "None"

	var settlement_type := String(data.get("settlement_type", ""))
	var is_dwarfhold := settlement_type == "dwarfhold"
	if is_dwarfhold:
		var classification_label := String(data.get("settlement_classification", "Dwarfhold"))
		_set_tooltip_label(tooltip_settlement, classification_label, true)

		var population_value: Variant = data.get("population", null)
		var population_text := ""
		if typeof(population_value) == TYPE_INT or typeof(population_value) == TYPE_FLOAT:
			var population_int := maxi(0, int(round(float(population_value))))
			var population_descriptor := String(data.get("population_descriptor", "residents")).strip_edges()
			population_text = str(population_int)
			if not population_descriptor.is_empty():
				population_text = "%s %s" % [population_text, population_descriptor]
		_set_tooltip_label(
			tooltip_population,
			population_text if not population_text.is_empty() else "Unknown",
			true
		)

		var ruler_title := String(data.get("ruler_title", "")).strip_edges()
		var ruler_name := String(data.get("ruler_name", "")).strip_edges()
		var ruler_text := "%s %s" % [ruler_title, ruler_name]
		ruler_text = ruler_text.strip_edges()
		_set_tooltip_label(tooltip_ruler, ruler_text if not ruler_text.is_empty() else "Unknown", true)

		var founded_value: Variant = data.get("founded_years_ago", null)
		var founded_text := ""
		if typeof(founded_value) == TYPE_INT or typeof(founded_value) == TYPE_FLOAT:
			founded_text = "%s years ago" % str(maxi(1, int(round(float(founded_value)))))
		_set_tooltip_label(
			tooltip_founded,
			founded_text if not founded_text.is_empty() else "Unknown",
			true
		)

		var prominent_clan := String(data.get("prominent_clan", "")).strip_edges()
		_set_tooltip_label(
			tooltip_prominent_clan,
			prominent_clan if not prominent_clan.is_empty() else "Unknown",
			true
		)

		var major_clans: Array[String] = []
		for entry: Variant in data.get("major_clans", []):
			major_clans.append(String(entry))
		_set_tooltip_label(
			tooltip_major_clans,
			_format_resource_list(major_clans),
			not major_clans.is_empty()
		)

		var major_guilds: Array[String] = []
		for entry: Variant in data.get("major_guilds", []):
			major_guilds.append(String(entry))
		_set_tooltip_label(
			tooltip_major_guilds,
			_format_resource_list(major_guilds),
			not major_guilds.is_empty()
		)

		var major_exports: Array[String] = []
		for entry: Variant in data.get("major_exports", []):
			major_exports.append(String(entry))
		_set_tooltip_label(
			tooltip_major_exports,
			_format_resource_list(major_exports),
			not major_exports.is_empty()
		)

		var hallmark := String(data.get("hallmark", "")).strip_edges()
		_set_tooltip_label(
			tooltip_hallmark,
			hallmark,
			not hallmark.is_empty()
		)

		var population_breakdown: Array = []
		for entry: Variant in data.get("population_breakdown", []):
			if entry is Dictionary:
				population_breakdown.append(entry)
		var has_breakdown := not population_breakdown.is_empty()
		_set_tooltip_section_visible(tooltip_population_breakdown_section, has_breakdown)
		if has_breakdown:
			_populate_population_breakdown_list(population_breakdown)
			if tooltip_population_pie_chart != null and tooltip_population_pie_chart.has_method("set_slices"):
				tooltip_population_pie_chart.call("set_slices", population_breakdown)
		elif tooltip_population_pie_chart != null and tooltip_population_pie_chart.has_method("set_slices"):
			tooltip_population_pie_chart.call("set_slices", [])

		var population_timeline: Array = []
		for entry: Variant in data.get("population_timeline", []):
			if entry is Dictionary:
				population_timeline.append(entry)
		var has_timeline := not population_timeline.is_empty()
		_set_tooltip_section_visible(tooltip_population_history_section, has_timeline)
		if tooltip_population_history_chart != null and tooltip_population_history_chart.has_method("set_points"):
			tooltip_population_history_chart.call("set_points", population_timeline)
	else:
		_set_tooltip_label(tooltip_settlement, "", false)
		_set_tooltip_label(tooltip_population, "", false)
		_set_tooltip_label(tooltip_ruler, "", false)
		_set_tooltip_label(tooltip_founded, "", false)
		_set_tooltip_label(tooltip_prominent_clan, "", false)
		_set_tooltip_label(tooltip_major_clans, "", false)
		_set_tooltip_label(tooltip_major_guilds, "", false)
		_set_tooltip_label(tooltip_major_exports, "", false)
		_set_tooltip_label(tooltip_hallmark, "", false)
		_set_tooltip_section_visible(tooltip_population_breakdown_section, false)
		_set_tooltip_section_visible(tooltip_population_history_section, false)
		if tooltip_population_pie_chart != null and tooltip_population_pie_chart.has_method("set_slices"):
			tooltip_population_pie_chart.call("set_slices", [])
		if tooltip_population_history_chart != null and tooltip_population_history_chart.has_method("set_points"):
			tooltip_population_history_chart.call("set_points", [])
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

func _handle_globe_input(event: InputEvent) -> bool:
	var mouse_button_event := event as InputEventMouseButton
	if mouse_button_event != null:
		if mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging_globe = mouse_button_event.pressed
			return true
		if mouse_button_event.pressed:
			if mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_globe_camera(-globe_zoom_step)
				return true
			if mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_globe_camera(globe_zoom_step)
				return true
	var mouse_motion_event := event as InputEventMouseMotion
	if mouse_motion_event != null and _is_dragging_globe:
		_rotate_globe_from_drag(mouse_motion_event.relative)
		return true
	return false

func _rotate_globe_from_drag(relative_motion: Vector2) -> void:
	if globe_mesh == null:
		return
	globe_mesh.rotate_y(-relative_motion.x * globe_drag_sensitivity)
	globe_mesh.rotate_object_local(Vector3.RIGHT, -relative_motion.y * globe_drag_sensitivity)

func _zoom_globe_camera(distance_delta: float) -> void:
	if globe_camera == null:
		return
	var camera_origin := globe_camera.transform.origin
	var current_distance := camera_origin.length()
	if current_distance <= 0.0001:
		return
	var target_distance := clampf(current_distance + distance_delta, globe_min_camera_distance, globe_max_camera_distance)
	if is_equal_approx(target_distance, current_distance):
		return
	globe_camera.transform.origin = camera_origin.normalized() * target_distance

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
	if globe_mesh == null or globe_rotation_speed == 0.0 or _is_dragging_globe:
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
