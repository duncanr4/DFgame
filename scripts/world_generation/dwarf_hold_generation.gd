extends Control

const CELL_ROCK := 0
const CELL_HALL := 1
const CELL_HOUSE := 2
const CELL_BUILDING := 3

@export var hall_zone_count_range := Vector2i(14, 22)
@export var housing_zone_count_range := Vector2i(80, 140)
@export var civic_building_zone_count_range := Vector2i(45, 95)
@export var tile_size := Vector2i(32, 32)
@export var tilesheet_path := "res://resources/images/dwarfhold/map.png"
@export var structure_fallback_max_extra_radius := 240

const TILE_ATLAS := {
	"dirt": Vector2i(0, 2),
	"workbench": Vector2i(0, 3),
	"shelf": Vector2i(0, 4),
	"winepress": Vector2i(0, 5),
	"grain_bag": Vector2i(0, 6),
	"wall_right": Vector2i(1, 1),
	"bed": Vector2i(1, 3),
	"butcher_table": Vector2i(1, 3),
	"chest": Vector2i(1, 5),
	"flour": Vector2i(1, 5),
	"sign": Vector2i(1, 7),
	"stone": Vector2i(2, 1),
	"wall_top": Vector2i(2, 2),
	"wall_bottom": Vector2i(2, 0),
	"mushroom_crops": Vector2i(2, 3),
	"wardrobe": Vector2i(2, 5),
	"floor": Vector2i(2, 6),
	"armor_stand": Vector2i(2, 7),
	"wall_left": Vector2i(3, 1),
	"table": Vector2i(3, 3),
	"mug": Vector2i(3, 4),
	"mushroom_crop_wild": Vector2i(3, 5),
	"water_bucket": Vector2i(3, 6),
	"stool": Vector2i(4, 2),
	"table_alt": Vector2i(5, 2),
	"door": Vector2i(4, 3),
	"desk": Vector2i(4, 4),
	"mushroom_wild": Vector2i(4, 5),
	"keg": Vector2i(5, 5),
	"target": Vector2i(6, 3),
	"anvil": Vector2i(6, 4)
}

const EXPECTED_TILE_COORDS := {
	"dirt": Vector2i(0, 2),
	"workbench": Vector2i(0, 3),
	"shelf": Vector2i(0, 4),
	"winepress": Vector2i(0, 5),
	"grain_bag": Vector2i(0, 6),
	"wall_right": Vector2i(1, 1),
	"bed": Vector2i(1, 3),
	"butcher_table": Vector2i(1, 3),
	"chest": Vector2i(1, 5),
	"flour": Vector2i(1, 5),
	"sign": Vector2i(1, 7),
	"stone": Vector2i(2, 1),
	"wall_top": Vector2i(2, 2),
	"wall_bottom": Vector2i(2, 0),
	"mushroom_crops": Vector2i(2, 3),
	"wardrobe": Vector2i(2, 5),
	"floor": Vector2i(2, 6),
	"armor_stand": Vector2i(2, 7),
	"wall_left": Vector2i(3, 1),
	"table": Vector2i(3, 3),
	"mug": Vector2i(3, 4),
	"mushroom_crop_wild": Vector2i(3, 5),
	"water_bucket": Vector2i(3, 6),
	"stool": Vector2i(4, 2),
	"table_alt": Vector2i(5, 2),
	"door": Vector2i(4, 3),
	"desk": Vector2i(4, 4),
	"mushroom_wild": Vector2i(4, 5),
	"keg": Vector2i(5, 5),
	"target": Vector2i(6, 3),
	"anvil": Vector2i(6, 4)
}

@onready var seed_input: LineEdit = %SeedInput
@onready var generate_button: Button = %GenerateButton
@onready var overlay_toggle: CheckButton = %OverlayToggle
@onready var city_summary: Label = %CitySummary
@onready var city_panel: PanelContainer = %CityPanel
@onready var city_layer: TileMapLayer = %CityTileLayer
@onready var decor_layer: TileMapLayer = %DecorTileLayer
@onready var zone_overlay: Control = %ZoneOverlay
@onready var zone_legend: RichTextLabel = %ZoneLegend
@onready var tile_hover_tooltip: PanelContainer = %TileHoverTooltip
@onready var tile_hover_label: Label = %TileHoverLabel

var _rng := RandomNumberGenerator.new()
var _is_panning := false
var _zoom_level := 1.0
var _pan_offset := Vector2.ZERO
var _map_origin_offset := Vector2.ZERO
var _door_cells: Dictionary = {}
var _latest_grid: Dictionary = {}
var _latest_civic_buildings_by_id: Dictionary = {}
var _latest_civic_building_type_map: Dictionary = {}
var _show_zone_overlay := false
var _latest_zone_counts := {
	"halls": 0,
	"houses": 0,
	"buildings": 0
}
var _latest_requested_zone_counts := {
	"halls": 0,
	"houses": 0,
	"buildings": 0
}

const ZONE_OVERLAY_COLORS := {
	CELL_HALL: Color(0.27, 0.58, 0.90, 0.35),
	CELL_HOUSE: Color(0.84, 0.72, 0.24, 0.35),
	CELL_BUILDING: Color(0.61, 0.35, 0.88, 0.35)
}

const ZONE_LEGEND_ORDER := [
	{"tile": CELL_HALL, "name": "Hall"},
	{"tile": CELL_HOUSE, "name": "House"},
	{"tile": CELL_BUILDING, "name": "Building"}
]

const BUILDING_SUBTYPE_LEGEND_COLORS := {
	"forge": Color(0.93, 0.52, 0.35, 0.45),
	"brewery": Color(0.89, 0.68, 0.29, 0.45),
	"armory": Color(0.63, 0.65, 0.81, 0.45),
	"workshop": Color(0.56, 0.79, 0.67, 0.45)
}

const BUILDING_SUBTYPE_FLAVOR := {
	"forge": "The air rings with hammer blows and quenched steel.",
	"brewery": "Warm casks and sour mash scent the stone halls.",
	"armory": "Weapon racks and sparring marks line the walls.",
	"granary": "Stores of grain and flour are stacked for lean winters.",
	"mushroom_farm": "Low beds of mushrooms thrive in cool, damp soil.",
	"archives": "Tablet shelves and ledgers preserve clan memory."
}

const MIN_ZOOM := 0.1
const MAX_ZOOM := 2.5
const ZOOM_STEP := 0.1

const CIVIC_BUILDING_TYPES := {
	"forge": {
		"placement_weight": 1.25,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(4, 3),
		"decor_tile_pool": PackedStringArray(["anvil", "workbench", "armor_stand", "water_bucket"]),
		"adjacency_preferences": {
			"prefers_hall_arteries": true,
			"hall_artery_bonus_weight": 0.7
		}
	},
	"brewery": {
		"placement_weight": 1.05,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(4, 3),
		"decor_tile_pool": PackedStringArray(["keg", "winepress", "mug", "table_alt"]),
		"adjacency_preferences": {}
	},
	"granary": {
		"placement_weight": 0.95,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(3, 3),
		"decor_tile_pool": PackedStringArray(["grain_bag", "flour", "shelf", "table"]),
		"adjacency_preferences": {}
	},
	"armory": {
		"placement_weight": 0.9,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(4, 3),
		"decor_tile_pool": PackedStringArray(["armor_stand", "target", "anvil", "workbench"]),
		"adjacency_preferences": {
			"prefers_hall_arteries": true,
			"hall_artery_bonus_weight": 0.45
		}
	},
	"workshop": {
		"placement_weight": 1.1,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(4, 3),
		"decor_tile_pool": PackedStringArray(["workbench", "desk", "shelf", "butcher_table"]),
		"adjacency_preferences": {}
	},
	"kitchen": {
		"placement_weight": 0.85,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(3, 3),
		"decor_tile_pool": PackedStringArray(["butcher_table", "table", "stool", "water_bucket"]),
		"adjacency_preferences": {}
	},
	"barracks": {
		"placement_weight": 0.8,
		"preferred_footprint_min": Vector2i(3, 2),
		"preferred_footprint_max": Vector2i(5, 3),
		"decor_tile_pool": PackedStringArray(["bed", "chest", "armor_stand", "target"]),
		"adjacency_preferences": {
			"prefers_hall_arteries": true,
			"hall_artery_bonus_weight": 0.35
		}
	},
	"temple": {
		"placement_weight": 0.65,
		"preferred_footprint_min": Vector2i(3, 2),
		"preferred_footprint_max": Vector2i(4, 3),
		"decor_tile_pool": PackedStringArray(["table_alt", "sign", "mug", "stool"]),
		"adjacency_preferences": {
			"prefers_hall_arteries": true,
			"hall_artery_bonus_weight": 0.2
		}
	},
	"mushroom_farm": {
		"placement_weight": 0.7,
		"preferred_footprint_min": Vector2i(3, 3),
		"preferred_footprint_max": Vector2i(5, 4),
		"decor_tile_pool": PackedStringArray(["mushroom_crops", "mushroom_crop_wild", "grain_bag", "water_bucket"]),
		"adjacency_preferences": {}
	},
	"archives": {
		"placement_weight": 0.55,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(4, 3),
		"decor_tile_pool": PackedStringArray(["shelf", "desk", "sign", "chest"]),
		"adjacency_preferences": {}
	},
	"infirmary": {
		"placement_weight": 0.6,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(3, 3),
		"decor_tile_pool": PackedStringArray(["bed", "table", "water_bucket", "chest"]),
		"adjacency_preferences": {
			"prefers_hall_arteries": true,
			"hall_artery_bonus_weight": 0.25
		}
	},
	"miners_guild": {
		"placement_weight": 0.75,
		"preferred_footprint_min": Vector2i(3, 2),
		"preferred_footprint_max": Vector2i(5, 3),
		"decor_tile_pool": PackedStringArray(["stone", "target", "workbench", "chest"]),
		"adjacency_preferences": {
			"prefers_hall_arteries": true,
			"hall_artery_bonus_weight": 0.3
		}
	},
	"mason_lodge": {
		"placement_weight": 0.7,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(4, 3),
		"decor_tile_pool": PackedStringArray(["stone", "table", "desk", "workbench"]),
		"adjacency_preferences": {}
	},
	"engineers_foundry": {
		"placement_weight": 0.65,
		"preferred_footprint_min": Vector2i(3, 2),
		"preferred_footprint_max": Vector2i(4, 3),
		"decor_tile_pool": PackedStringArray(["anvil", "workbench", "desk", "water_bucket"]),
		"adjacency_preferences": {
			"prefers_hall_arteries": true,
			"hall_artery_bonus_weight": 0.4
		}
	},
	"gemcutters_studio": {
		"placement_weight": 0.6,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(3, 3),
		"decor_tile_pool": PackedStringArray(["table_alt", "chest", "sign", "desk"]),
		"adjacency_preferences": {}
	},
	"runesmith_sanctum": {
		"placement_weight": 0.5,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(4, 3),
		"decor_tile_pool": PackedStringArray(["anvil", "sign", "shelf", "desk"]),
		"adjacency_preferences": {
			"prefers_hall_arteries": true,
			"hall_artery_bonus_weight": 0.2
		}
	},
	"smeltery": {
		"placement_weight": 0.7,
		"preferred_footprint_min": Vector2i(3, 2),
		"preferred_footprint_max": Vector2i(5, 3),
		"decor_tile_pool": PackedStringArray(["anvil", "water_bucket", "stone", "workbench"]),
		"adjacency_preferences": {
			"prefers_hall_arteries": true,
			"hall_artery_bonus_weight": 0.5
		}
	},
	"cartographers_office": {
		"placement_weight": 0.45,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(3, 3),
		"decor_tile_pool": PackedStringArray(["desk", "sign", "table", "shelf"]),
		"adjacency_preferences": {}
	},
	"explorers_guild": {
		"placement_weight": 0.55,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(4, 3),
		"decor_tile_pool": PackedStringArray(["target", "table", "chest", "water_bucket"]),
		"adjacency_preferences": {
			"prefers_hall_arteries": true,
			"hall_artery_bonus_weight": 0.15
		}
	},
	"merchants_counting_house": {
		"placement_weight": 0.55,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(4, 3),
		"decor_tile_pool": PackedStringArray(["desk", "chest", "table_alt", "shelf"]),
		"adjacency_preferences": {}
	},
	"butchery": {
		"placement_weight": 0.75,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(3, 3),
		"decor_tile_pool": PackedStringArray(["butcher_table", "table", "water_bucket", "chest"]),
		"adjacency_preferences": {}
	},
	"bakery": {
		"placement_weight": 0.7,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(3, 3),
		"decor_tile_pool": PackedStringArray(["table_alt", "flour", "grain_bag", "stool"]),
		"adjacency_preferences": {}
	},
	"cooperage": {
		"placement_weight": 0.6,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(4, 3),
		"decor_tile_pool": PackedStringArray(["keg", "workbench", "chest", "table"]),
		"adjacency_preferences": {}
	},
	"tannery": {
		"placement_weight": 0.55,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(4, 3),
		"decor_tile_pool": PackedStringArray(["water_bucket", "workbench", "chest", "table_alt"]),
		"adjacency_preferences": {}
	},
	"millhouse": {
		"placement_weight": 0.65,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(4, 3),
		"decor_tile_pool": PackedStringArray(["flour", "grain_bag", "table", "shelf"]),
		"adjacency_preferences": {}
	},
	"cobblers_shop": {
		"placement_weight": 0.45,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(3, 3),
		"decor_tile_pool": PackedStringArray(["stool", "chest", "table", "desk"]),
		"adjacency_preferences": {}
	},
	"ropemakers_hall": {
		"placement_weight": 0.45,
		"preferred_footprint_min": Vector2i(2, 2),
		"preferred_footprint_max": Vector2i(3, 3),
		"decor_tile_pool": PackedStringArray(["table", "workbench", "chest", "stool"]),
		"adjacency_preferences": {}
	}
}

func _ready() -> void:
	_configure_tile_layer()
	generate_button.pressed.connect(_on_generate_pressed)
	overlay_toggle.toggled.connect(_on_overlay_toggle_toggled)
	city_panel.gui_input.connect(_on_city_panel_gui_input)
	seed_input.text_submitted.connect(func(_text: String) -> void:
		_generate_city()
	)
	_update_zone_legend()
	_generate_city()

func _update_zone_legend() -> void:
	var lines: PackedStringArray = ["[b]Zone Overlay Legend[/b]"]
	for entry: Dictionary in ZONE_LEGEND_ORDER:
		var tile := int(entry["tile"])
		var zone_name := String(entry["name"])
		var color := Color(ZONE_OVERLAY_COLORS[tile])
		var color_hex := color.to_html(false)
		lines.append("[color=#%s]■[/color] %s" % [color_hex, zone_name])

	lines.append("")
	lines.append("[b]Building Subtype Keys[/b]")
	for subtype: String in BUILDING_SUBTYPE_LEGEND_COLORS.keys():
		var subtype_color := Color(BUILDING_SUBTYPE_LEGEND_COLORS[subtype])
		lines.append("[color=#%s]■[/color] %s" % [subtype_color.to_html(false), _display_name_for_building_type(subtype)])
	zone_legend.text = "\n".join(lines)

func _configure_tile_layer() -> void:
	if not _validate_tile_mapping():
		return
	if not FileAccess.file_exists(tilesheet_path):
		push_error("Missing dwarf hold tilesheet at %s" % tilesheet_path)
		return
	var texture := load(tilesheet_path) as Texture2D
	if texture == null:
		push_error("Unable to load dwarf hold tilesheet texture at %s" % tilesheet_path)
		return

	var atlas := TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = tile_size
	var unique_atlas_coords: Dictionary = {}
	for atlas_coords: Vector2i in TILE_ATLAS.values():
		unique_atlas_coords[atlas_coords] = true
	for atlas_coords: Vector2i in unique_atlas_coords.keys():
		atlas.create_tile(atlas_coords)

	var tile_set := TileSet.new()
	tile_set.tile_size = tile_size
	tile_set.add_source(atlas, 0)
	city_layer.tile_set = tile_set
	decor_layer.tile_set = tile_set

func _validate_tile_mapping() -> bool:
	for tile_key: String in EXPECTED_TILE_COORDS.keys():
		if not TILE_ATLAS.has(tile_key):
			push_error("Tile mapping missing required key: %s" % tile_key)
			return false
		var expected_coords: Vector2i = EXPECTED_TILE_COORDS[tile_key]
		var actual_coords: Vector2i = TILE_ATLAS[tile_key]
		if actual_coords != expected_coords:
			push_error("Tile mapping mismatch for %s. Expected %s but found %s" % [tile_key, expected_coords, actual_coords])
			return false
	return true

func _on_generate_pressed() -> void:
	_generate_city()

func _generate_city() -> void:
	var seed_text := seed_input.text.strip_edges()
	if seed_text.is_empty():
		_rng.randomize()
		seed_text = str(_rng.randi())
		seed_input.text = seed_text
	_rng.seed = hash(seed_text)

	var requested_hall_count := _pick_seeded_zone_target(hall_zone_count_range)
	var requested_house_count := _pick_seeded_zone_target(housing_zone_count_range)
	var requested_building_count := _pick_seeded_zone_target(civic_building_zone_count_range)
	_latest_requested_zone_counts = {
		"halls": requested_hall_count,
		"houses": requested_house_count,
		"buildings": requested_building_count
	}

	var grid: Dictionary = {}
	_latest_civic_buildings_by_id = {}
	_latest_civic_building_type_map = {}
	var seed_hall_center := Vector2i.ZERO
	var seed_hall_size := Vector2i(18, 14)
	_dig_rect(grid, seed_hall_center - seed_hall_size / 2, seed_hall_center + seed_hall_size / 2, CELL_HALL)

	var hubs: Array[Vector2i] = [seed_hall_center]

	for i in requested_hall_count:
		var anchor := hubs[_rng.randi_range(0, hubs.size() - 1)]
		var horizontal := _rng.randf() < 0.5
		var direction := 1 if _rng.randf() < 0.5 else -1
		var hall_length := _rng.randi_range(12, 34)
		var hall_half_width := _rng.randi_range(1, 2)
		var end := anchor + (Vector2i(direction, 0) if horizontal else Vector2i(0, direction)) * hall_length
		var from_cell := Vector2i(mini(anchor.x, end.x), mini(anchor.y, end.y))
		var to_cell := Vector2i(maxi(anchor.x, end.x), maxi(anchor.y, end.y))
		if horizontal:
			from_cell.y -= hall_half_width
			to_cell.y += hall_half_width
		else:
			from_cell.x -= hall_half_width
			to_cell.x += hall_half_width
		_dig_rect(grid, from_cell, to_cell, CELL_HALL)
		hubs.append(end)

	for i in requested_house_count:
		var house_footprint := (func() -> Vector2i:
			var home_size_min := Vector2i(2, 2)
			var home_size_max := Vector2i(6, 5)
			var home_size_x := maxi(_rng.randi_range(home_size_min.x, home_size_max.x), _rng.randi_range(home_size_min.x, home_size_max.x))
			var home_size_y := maxi(_rng.randi_range(home_size_min.y, home_size_max.y), _rng.randi_range(home_size_min.y, home_size_max.y))
			return Vector2i(home_size_x, home_size_y)
		).call() as Vector2i
		if _place_structure_along_halls(grid, CELL_HOUSE, house_footprint):
			continue
		_place_structure_zone(
			grid,
			hubs,
			CELL_HOUSE,
			func() -> Vector2i:
				return Vector2i(_rng.randi_range(-14, 14), _rng.randi_range(-9, 9)),
			func() -> Vector2i:
				return house_footprint
		)

	for i in requested_building_count:
		var civic_type := _pick_civic_building_type()
		var civic_definition := CIVIC_BUILDING_TYPES[civic_type] as Dictionary
		var civic_footprint := _roll_civic_footprint(civic_definition)
		var prefers_hall_arteries := _civic_prefers_hall_arteries(civic_definition)
		if prefers_hall_arteries and _place_structure_along_halls(grid, CELL_BUILDING, civic_footprint, civic_type):
			continue
		var civic_size_generator := func() -> Vector2i:
			return civic_footprint
		var placed := _place_structure_zone(
			grid,
			hubs,
			CELL_BUILDING,
			func() -> Vector2i:
				return Vector2i(_rng.randi_range(-15, 15), _rng.randi_range(-10, 10)),
			civic_size_generator,
			civic_type
		)
		if not placed and not prefers_hall_arteries:
			_place_structure_along_halls(grid, CELL_BUILDING, civic_footprint, civic_type)

	_door_cells = _compute_single_doors(grid)
	_latest_grid = grid
	_latest_civic_buildings_by_id = _compute_civic_buildings_by_id(grid)
	_latest_civic_building_type_map = _build_civic_building_type_lookup(_latest_civic_buildings_by_id)
	_latest_zone_counts = _count_zone_components(grid)

	_render_city(grid)
	_update_summary(grid, seed_text)
	_update_zone_overlay()


func _pick_seeded_zone_target(count_range: Vector2i) -> int:
	var minimum := mini(count_range.x, count_range.y)
	var maximum := maxi(count_range.x, count_range.y)
	return _rng.randi_range(minimum, maximum)

func _pick_civic_building_type() -> String:
	var total_weight := 0.0
	for type_name: String in CIVIC_BUILDING_TYPES.keys():
		var definition := CIVIC_BUILDING_TYPES[type_name] as Dictionary
		total_weight += float(definition.get("placement_weight", 1.0))
	if total_weight <= 0.0:
		return "workshop"

	var cursor := _rng.randf() * total_weight
	for type_name: String in CIVIC_BUILDING_TYPES.keys():
		var definition := CIVIC_BUILDING_TYPES[type_name] as Dictionary
		cursor -= float(definition.get("placement_weight", 1.0))
		if cursor <= 0.0:
			return type_name
	return String(CIVIC_BUILDING_TYPES.keys()[0])

func _roll_civic_footprint(civic_definition: Dictionary) -> Vector2i:
	var minimum := civic_definition.get("preferred_footprint_min", Vector2i(2, 2)) as Vector2i
	var maximum := civic_definition.get("preferred_footprint_max", Vector2i(4, 3)) as Vector2i
	return Vector2i(
		_rng.randi_range(mini(minimum.x, maximum.x), maxi(minimum.x, maximum.x)),
		_rng.randi_range(mini(minimum.y, maximum.y), maxi(minimum.y, maximum.y))
	)

func _civic_prefers_hall_arteries(civic_definition: Dictionary) -> bool:
	var adjacency := civic_definition.get("adjacency_preferences", {}) as Dictionary
	return bool(adjacency.get("prefers_hall_arteries", false))

func _place_structure_zone(
	grid: Dictionary,
	hubs: Array[Vector2i],
	structure_tile: int,
	offset_generator: Callable,
	size_generator: Callable,
	building_type: String = ""
) -> bool:
	var max_search_rings := 16
	for ring in range(max_search_rings):
		var expansion := ring * 4
		var attempts := 48
		for _attempt in attempts:
			var anchor := hubs[_rng.randi_range(0, hubs.size() - 1)]
			var offset := offset_generator.call() as Vector2i
			var center := anchor + offset
			if ring > 0:
				center += Vector2i(_rng.randi_range(-expansion, expansion), _rng.randi_range(-expansion, expansion))
			var footprint := size_generator.call() as Vector2i
			if _try_place_structure_with_single_door(grid, center, footprint, structure_tile, anchor):
				_register_building_type_metadata(center, footprint, structure_tile, building_type)
				return true

	var fallback_anchor := hubs[_rng.randi_range(0, hubs.size() - 1)]
	var fallback_footprint := size_generator.call() as Vector2i
	return _place_structure_in_open_space(grid, structure_tile, fallback_anchor, fallback_footprint, building_type)

func _place_structure_along_halls(grid: Dictionary, structure_tile: int, footprint: Vector2i, building_type: String = "") -> bool:
	var hall_edge_candidates := _collect_hall_edge_candidates(grid)
	if hall_edge_candidates.is_empty():
		return false
	for _attempt in 140:
		var candidate: Dictionary = hall_edge_candidates[_rng.randi_range(0, hall_edge_candidates.size() - 1)]
		var hall_cell := candidate["hall"] as Vector2i
		var side_dir := candidate["side"] as Vector2i
		var structural_radius := footprint.x if side_dir.x != 0 else footprint.y
		var standoff := structural_radius + _rng.randi_range(1, 3)
		var center := hall_cell + side_dir * standoff
		if not _can_place_structure(grid, center, footprint):
			continue
		_dig_structure_with_room(grid, center, footprint, structure_tile)
		_register_building_type_metadata(center, footprint, structure_tile, building_type)
		var doorway := _pick_side_center_door_cell_facing(center, footprint, -side_dir)
		var exterior := doorway + _outward_direction_for_door(center, footprint, doorway)
		_connect_points(grid, exterior, hall_cell, CELL_HALL)
		return true
	return false

func _collect_hall_edge_candidates(grid: Dictionary) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	for key: Variant in grid.keys():
		var hall_cell := key as Vector2i
		if _cell_at(grid, hall_cell.x, hall_cell.y) != CELL_HALL:
			continue
		for side_dir: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var side_cell := hall_cell + side_dir
			if _cell_at(grid, side_cell.x, side_cell.y) != CELL_ROCK:
				continue
			candidates.append({"hall": hall_cell, "side": side_dir})
	return candidates

func _place_structure_in_open_space(grid: Dictionary, structure_tile: int, anchor: Vector2i, footprint: Vector2i, building_type: String = "") -> bool:
	var start_radius := maxi(footprint.x, footprint.y) + 8
	var max_radius := start_radius + maxi(structure_fallback_max_extra_radius, 0)
	for radius in range(start_radius, max_radius + 1, 8):
		var candidate_centers := [
			Vector2i(anchor.x + radius, anchor.y),
			Vector2i(anchor.x - radius, anchor.y),
			Vector2i(anchor.x, anchor.y + radius),
			Vector2i(anchor.x, anchor.y - radius),
			Vector2i(anchor.x + radius, anchor.y + radius),
			Vector2i(anchor.x - radius, anchor.y + radius),
			Vector2i(anchor.x + radius, anchor.y - radius),
			Vector2i(anchor.x - radius, anchor.y - radius)
		]
		for center: Vector2i in candidate_centers:
			if _try_place_structure_with_single_door(grid, center, footprint, structure_tile, anchor):
				_register_building_type_metadata(center, footprint, structure_tile, building_type)
				return true
	return false


func _register_building_type_metadata(center: Vector2i, footprint: Vector2i, structure_tile: int, building_type: String) -> void:
	if structure_tile != CELL_BUILDING:
		return
	if building_type.is_empty():
		return
	for y in range(center.y - footprint.y, center.y + footprint.y + 1):
		for x in range(center.x - footprint.x, center.x + footprint.x + 1):
			_latest_civic_building_type_map[Vector2i(x, y)] = building_type

func _compute_civic_buildings_by_id(grid: Dictionary) -> Dictionary:
	var visited: Dictionary = {}
	var by_id: Dictionary = {}
	for key: Variant in grid.keys():
		var start_cell := key as Vector2i
		if visited.has(start_cell):
			continue
		if _cell_at(grid, start_cell.x, start_cell.y) != CELL_BUILDING:
			continue
		var queue: Array[Vector2i] = [start_cell]
		visited[start_cell] = true
		var component: Array[Vector2i] = []
		while not queue.is_empty():
			var current: Vector2i = queue.pop_front()
			component.append(current)
			for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var neighbor := current + direction
				if visited.has(neighbor):
					continue
				if _cell_at(grid, neighbor.x, neighbor.y) != CELL_BUILDING:
					continue
				visited[neighbor] = true
				queue.append(neighbor)
		if component.is_empty():
			continue
		var anchor := _stable_component_anchor(component)
		var building_id := "%d:%d" % [anchor.x, anchor.y]
		var building_type := String(_latest_civic_building_type_map.get(anchor, "workshop"))
		by_id[building_id] = {"anchor": anchor, "type": building_type, "cells": component}
	return by_id

func _stable_component_anchor(component: Array[Vector2i]) -> Vector2i:
	var anchor := component[0]
	for cell: Vector2i in component:
		if cell.x < anchor.x or (cell.x == anchor.x and cell.y < anchor.y):
			anchor = cell
	return anchor

func _build_civic_building_type_lookup(buildings_by_id: Dictionary) -> Dictionary:
	var lookup: Dictionary = {}
	for building_id: String in buildings_by_id.keys():
		var payload := buildings_by_id[building_id] as Dictionary
		var building_type := String(payload.get("type", "workshop"))
		var cells := payload.get("cells", []) as Array
		for cell_variant: Variant in cells:
			lookup[cell_variant as Vector2i] = building_type
	return lookup

func _count_zone_components(grid: Dictionary) -> Dictionary:
	return {
		"halls": _count_components_for_tile(grid, CELL_HALL),
		"houses": _count_components_for_tile(grid, CELL_HOUSE),
		"buildings": _count_components_for_tile(grid, CELL_BUILDING)
	}

func _count_components_for_tile(grid: Dictionary, tile_type: int) -> int:
	var visited: Dictionary = {}
	var component_count := 0
	for key: Variant in grid.keys():
		var start_cell := key as Vector2i
		if visited.has(start_cell):
			continue
		if _cell_at(grid, start_cell.x, start_cell.y) != tile_type:
			continue

		component_count += 1
		var queue: Array[Vector2i] = [start_cell]
		visited[start_cell] = true
		while not queue.is_empty():
			var current: Vector2i = queue.pop_front()
			for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var neighbor := current + direction
				if visited.has(neighbor):
					continue
				if _cell_at(grid, neighbor.x, neighbor.y) != tile_type:
					continue
				visited[neighbor] = true
				queue.append(neighbor)

	return component_count

func _on_overlay_toggle_toggled(toggled_on: bool) -> void:
	_show_zone_overlay = toggled_on
	_update_zone_overlay()

func _update_zone_overlay() -> void:
	if zone_overlay.has_method("set_overlay_state"):
		zone_overlay.call("set_overlay_state", _latest_grid, tile_size, _zoom_level, city_layer.position, ZONE_OVERLAY_COLORS, _show_zone_overlay)

func _dig_structure_with_room(grid: Dictionary, center: Vector2i, footprint: Vector2i, structure_tile: int) -> void:
	var from_cell := center - footprint
	var to_cell := center + footprint
	_dig_rect(grid, from_cell, to_cell, structure_tile)

func _try_place_structure_with_single_door(grid: Dictionary, center: Vector2i, footprint: Vector2i, structure_tile: int, anchor: Vector2i) -> bool:
	if not _can_place_structure(grid, center, footprint):
		return false
	_dig_structure_with_room(grid, center, footprint, structure_tile)
	var outward_dir := _major_axis_direction_toward_target(center, anchor)
	var doorway := _pick_side_center_door_cell_facing(center, footprint, outward_dir)
	var exterior := doorway + _outward_direction_for_door(center, footprint, doorway)
	_connect_points(grid, exterior, anchor, CELL_HALL)
	return true

func _can_place_structure(grid: Dictionary, center: Vector2i, footprint: Vector2i) -> bool:
	var from_cell := center - footprint
	var to_cell := center + footprint
	for y in range(from_cell.y - 1, to_cell.y + 2):
		for x in range(from_cell.x - 1, to_cell.x + 2):
			var tile := _cell_at(grid, x, y)
			if tile == CELL_HOUSE or tile == CELL_BUILDING:
				return false
			if (x == from_cell.x - 1 or x == to_cell.x + 1 or y == from_cell.y - 1 or y == to_cell.y + 1) and _is_corridor_cell(tile):
				return false
	return true

func _pick_structure_door_cell(center: Vector2i, footprint: Vector2i) -> Vector2i:
	var from_cell := center - footprint
	var to_cell := center + footprint
	var side := _rng.randi_range(0, 3)
	match side:
		0:
			var top_x := center.x if from_cell.x + 1 > to_cell.x - 1 else _rng.randi_range(from_cell.x + 1, to_cell.x - 1)
			return Vector2i(top_x, from_cell.y)
		1:
			var bottom_x := center.x if from_cell.x + 1 > to_cell.x - 1 else _rng.randi_range(from_cell.x + 1, to_cell.x - 1)
			return Vector2i(bottom_x, to_cell.y)
		2:
			var left_y := center.y if from_cell.y + 1 > to_cell.y - 1 else _rng.randi_range(from_cell.y + 1, to_cell.y - 1)
			return Vector2i(from_cell.x, left_y)
		_:
			var right_y := center.y if from_cell.y + 1 > to_cell.y - 1 else _rng.randi_range(from_cell.y + 1, to_cell.y - 1)
			return Vector2i(to_cell.x, right_y)

func _pick_structure_door_cell_facing(center: Vector2i, footprint: Vector2i, outward_dir: Vector2i) -> Vector2i:
	var from_cell := center - footprint
	var to_cell := center + footprint
	if outward_dir == Vector2i.UP:
		var top_x := center.x if from_cell.x + 1 > to_cell.x - 1 else _rng.randi_range(from_cell.x + 1, to_cell.x - 1)
		return Vector2i(top_x, from_cell.y)
	if outward_dir == Vector2i.DOWN:
		var bottom_x := center.x if from_cell.x + 1 > to_cell.x - 1 else _rng.randi_range(from_cell.x + 1, to_cell.x - 1)
		return Vector2i(bottom_x, to_cell.y)
	if outward_dir == Vector2i.LEFT:
		var left_y := center.y if from_cell.y + 1 > to_cell.y - 1 else _rng.randi_range(from_cell.y + 1, to_cell.y - 1)
		return Vector2i(from_cell.x, left_y)
	var right_y := center.y if from_cell.y + 1 > to_cell.y - 1 else _rng.randi_range(from_cell.y + 1, to_cell.y - 1)
	return Vector2i(to_cell.x, right_y)

func _pick_side_center_door_cell_facing(center: Vector2i, footprint: Vector2i, outward_dir: Vector2i) -> Vector2i:
	var from_cell := center - footprint
	var to_cell := center + footprint
	if outward_dir == Vector2i.UP:
		return Vector2i(center.x, from_cell.y)
	if outward_dir == Vector2i.DOWN:
		return Vector2i(center.x, to_cell.y)
	if outward_dir == Vector2i.LEFT:
		return Vector2i(from_cell.x, center.y)
	return Vector2i(to_cell.x, center.y)

func _major_axis_direction_toward_target(origin: Vector2i, target: Vector2i) -> Vector2i:
	var delta := target - origin
	if abs(delta.x) >= abs(delta.y):
		return Vector2i.RIGHT if delta.x >= 0 else Vector2i.LEFT
	return Vector2i.DOWN if delta.y >= 0 else Vector2i.UP

func _outward_direction_for_door(center: Vector2i, footprint: Vector2i, door: Vector2i) -> Vector2i:
	var from_cell := center - footprint
	var to_cell := center + footprint
	if door.y == from_cell.y:
		return Vector2i.UP
	if door.y == to_cell.y:
		return Vector2i.DOWN
	if door.x == from_cell.x:
		return Vector2i.LEFT
	return Vector2i.RIGHT

func _compute_single_doors(grid: Dictionary) -> Dictionary:
	var visited: Dictionary = {}
	var chosen_doors: Dictionary = {}

	for key: Variant in grid.keys():
		var start_cell := key as Vector2i
		var tile := _cell_at(grid, start_cell.x, start_cell.y)
		if tile != CELL_HOUSE and tile != CELL_BUILDING:
			continue
		if visited.has(start_cell):
			continue

		var queue: Array[Vector2i] = [start_cell]
		visited[start_cell] = true
		var component_cells: Array[Vector2i] = []
		while not queue.is_empty():
			var current: Vector2i = queue.pop_front()
			component_cells.append(current)
			for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var neighbor: Vector2i = current + direction
				if visited.has(neighbor):
					continue
				if _cell_at(grid, neighbor.x, neighbor.y) != tile:
					continue
				visited[neighbor] = true
				queue.append(neighbor)

		var component_lookup: Dictionary = {}
		for component_cell: Vector2i in component_cells:
			component_lookup[component_cell] = true

		var candidates: Array[Vector2i] = []
		for component_cell: Vector2i in component_cells:
			if _is_component_corner_cell(component_cell, component_lookup):
				continue
			for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var corridor_neighbor := component_cell + direction
				if _is_corridor_cell(_cell_at(grid, corridor_neighbor.x, corridor_neighbor.y)):
					candidates.append(component_cell)
					break

		if candidates.is_empty():
			continue
		var selected := candidates[_rng.randi_range(0, candidates.size() - 1)] as Vector2i
		chosen_doors[selected] = true

	return chosen_doors

func _is_component_corner_cell(cell: Vector2i, component_lookup: Dictionary) -> bool:
	var has_left := component_lookup.has(cell + Vector2i.LEFT)
	var has_right := component_lookup.has(cell + Vector2i.RIGHT)
	var has_up := component_lookup.has(cell + Vector2i.UP)
	var has_down := component_lookup.has(cell + Vector2i.DOWN)
	if (not has_left and not has_up) or (not has_left and not has_down):
		return true
	if (not has_right and not has_up) or (not has_right and not has_down):
		return true
	return false

func _dig_rect(grid: Dictionary, from_cell: Vector2i, to_cell: Vector2i, tile: int) -> void:
	for y in range(from_cell.y, to_cell.y + 1):
		for x in range(from_cell.x, to_cell.x + 1):
			_set_cell(grid, Vector2i(x, y), tile)

func _dig_ellipse(grid: Dictionary, center: Vector2i, radius: Vector2i, tile: int) -> void:
	for y in range(center.y - radius.y, center.y + radius.y + 1):
		for x in range(center.x - radius.x, center.x + radius.x + 1):
			var normalized_x := float(x - center.x) / maxf(float(radius.x), 1.0)
			var normalized_y := float(y - center.y) / maxf(float(radius.y), 1.0)
			if normalized_x * normalized_x + normalized_y * normalized_y <= 1.0:
				_set_cell(grid, Vector2i(x, y), tile)

func _connect_points(grid: Dictionary, start: Vector2i, finish: Vector2i, tile: int) -> void:
	var corridor_width := _rng.randi_range(2, 5)
	var cursor := start
	while cursor.x != finish.x:
		_dig_corridor_at(grid, cursor, tile, true, corridor_width)
		cursor.x += 1 if finish.x > cursor.x else -1
	while cursor.y != finish.y:
		_dig_corridor_at(grid, cursor, tile, false, corridor_width)
		cursor.y += 1 if finish.y > cursor.y else -1
	_dig_corridor_at(grid, finish, tile, true, corridor_width)
	_dig_corridor_at(grid, finish, tile, false, corridor_width)

func _dig_corridor_at(grid: Dictionary, origin: Vector2i, tile: int, horizontal: bool, width: int) -> void:
	var start_offset := -int(width / 2)
	for i in width:
		var offset := start_offset + i
		if horizontal:
			_set_cell(grid, Vector2i(origin.x, origin.y + offset), tile)
		else:
			_set_cell(grid, Vector2i(origin.x + offset, origin.y), tile)

func _nearest_point(target: Vector2i, points: Array[Vector2i]) -> Vector2i:
	var nearest := points[0]
	var nearest_distance := target.distance_squared_to(nearest)
	for point in points:
		var candidate := target.distance_squared_to(point)
		if candidate < nearest_distance:
			nearest = point
			nearest_distance = candidate
	return nearest

func _set_cell(grid: Dictionary, cell: Vector2i, tile: int) -> void:
	var existing := _cell_at(grid, cell.x, cell.y)
	if _is_corridor_cell(tile) and _is_structural_cell(existing):
		return
	grid[cell] = tile

func _cell_at(grid: Dictionary, x: int, y: int) -> int:
	return int(grid.get(Vector2i(x, y), CELL_ROCK))

func _is_structural_cell(cell: int) -> bool:
	return cell == CELL_HOUSE or cell == CELL_BUILDING

func _is_corridor_cell(cell: int) -> bool:
	return cell == CELL_HALL

func _find_bounds(grid: Dictionary) -> Rect2i:
	if grid.is_empty():
		return Rect2i(Vector2i.ZERO, Vector2i.ONE)
	var min_x := 2147483647
	var min_y := 2147483647
	var max_x := -2147483648
	var max_y := -2147483648
	for key: Variant in grid.keys():
		var cell := key as Vector2i
		min_x = mini(min_x, cell.x)
		min_y = mini(min_y, cell.y)
		max_x = maxi(max_x, cell.x)
		max_y = maxi(max_y, cell.y)
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)

func _render_city(grid: Dictionary) -> void:
	if city_layer.tile_set == null:
		return
	city_layer.clear()
	decor_layer.clear()
	var bounds := _find_bounds(grid).grow(1)
	var house_decor_overrides := _build_house_decor_layouts(grid)
	for y in range(bounds.position.y, bounds.end.y):
		for x in range(bounds.position.x, bounds.end.x):
			var cell := _cell_at(grid, x, y)
			if cell == CELL_ROCK and not _is_hall_border_rock_cell(grid, x, y):
				continue
			var base_tile := _pick_base_tile(grid, x, y, cell)
			_place_tile(city_layer, Vector2i(x, y), base_tile)
			var decor_tile := _pick_decor_tile(grid, x, y, cell, base_tile, house_decor_overrides)
			if not decor_tile.is_empty():
				_place_tile(decor_layer, Vector2i(x, y), decor_tile)
	_reset_view(bounds)

func _build_house_decor_layouts(grid: Dictionary) -> Dictionary:
	var visited: Dictionary = {}
	var overrides: Dictionary = {}
	for key: Variant in grid.keys():
		var start_cell := key as Vector2i
		if _cell_at(grid, start_cell.x, start_cell.y) != CELL_HOUSE:
			continue
		if visited.has(start_cell):
			continue

		var queue: Array[Vector2i] = [start_cell]
		var component: Array[Vector2i] = []
		visited[start_cell] = true
		while not queue.is_empty():
			var current: Vector2i = queue.pop_front()
			component.append(current)
			for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var neighbor: Vector2i = current + direction
				if visited.has(neighbor):
					continue
				if _cell_at(grid, neighbor.x, neighbor.y) != CELL_HOUSE:
					continue
				visited[neighbor] = true
				queue.append(neighbor)

		if component.is_empty():
			continue
		_place_house_decor_template(component, overrides)

	return overrides

func _place_house_decor_template(component: Array[Vector2i], overrides: Dictionary) -> void:
	var occupied: Dictionary = {}
	for cell: Vector2i in component:
		occupied[cell] = true

	var min_x := component[0].x
	var max_x := component[0].x
	var min_y := component[0].y
	var max_y := component[0].y
	for cell: Vector2i in component:
		min_x = mini(min_x, cell.x)
		max_x = maxi(max_x, cell.x)
		min_y = mini(min_y, cell.y)
		max_y = maxi(max_y, cell.y)

	var top_left_chest := Vector2i(min_x + 1, min_y + 1)
	var top_left_bed := Vector2i(min_x + 2, min_y + 1)
	var top_right_wardrobe := _find_wall_adjacent_cell(component, occupied, overrides, Vector2i(max_x - 1, min_y + 1))
	var center_table := Vector2i((min_x + max_x) / 2, (min_y + max_y) / 2)
	var stool_a := center_table + Vector2i(-1, 0)
	var stool_b := center_table + Vector2i(0, -1)

	_try_assign_house_decor(overrides, occupied, top_left_chest, "chest")
	_try_assign_house_decor(overrides, occupied, top_left_bed, "bed")
	_try_assign_house_decor(overrides, occupied, top_right_wardrobe, "wardrobe")
	_try_assign_house_decor(overrides, occupied, center_table, "table")
	_try_assign_house_decor(overrides, occupied, stool_a, "stool")
	_try_assign_house_decor(overrides, occupied, stool_b, "stool")
	_ensure_house_has_bed(component, overrides)

func _ensure_house_has_bed(component: Array[Vector2i], overrides: Dictionary) -> void:
	for cell: Vector2i in component:
		if overrides.get(cell, "") == "bed":
			return

	var fallback_bed_cell := component[0]
	for cell: Vector2i in component:
		if not overrides.has(cell):
			fallback_bed_cell = cell
			break
	overrides[fallback_bed_cell] = "bed"

func _try_assign_house_decor(overrides: Dictionary, occupied: Dictionary, cell: Vector2i, tile_key: String) -> void:
	if not occupied.has(cell):
		return
	overrides[cell] = tile_key

func _find_wall_adjacent_cell(component: Array[Vector2i], occupied: Dictionary, overrides: Dictionary, preferred_cell: Vector2i) -> Vector2i:
	if occupied.has(preferred_cell) and not overrides.has(preferred_cell) and _is_component_wall_adjacent(preferred_cell, occupied):
		return preferred_cell
	for cell: Vector2i in component:
		if overrides.has(cell):
			continue
		if _is_component_wall_adjacent(cell, occupied):
			return cell
	return preferred_cell

func _is_component_wall_adjacent(cell: Vector2i, occupied: Dictionary) -> bool:
	for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		if not occupied.has(cell + direction):
			return true
	return false

func _on_city_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_MIDDLE or mouse_button.button_index == MOUSE_BUTTON_RIGHT:
			_is_panning = mouse_button.pressed
		if mouse_button.pressed:
			if mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP:
				_apply_zoom(ZOOM_STEP, mouse_button.position)
			elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_apply_zoom(-ZOOM_STEP, mouse_button.position)
	if event is InputEventMouseMotion and _is_panning:
		var motion := event as InputEventMouseMotion
		_pan_offset += motion.relative
		_update_city_layer_transform()
	if event is InputEventMouse:
		_update_hover_tooltip((event as InputEventMouse).position)

func _apply_zoom(zoom_delta: float, focus_position: Vector2) -> void:
	var previous_zoom := _zoom_level
	_zoom_level = clampf(_zoom_level + zoom_delta, MIN_ZOOM, MAX_ZOOM)
	if is_equal_approx(previous_zoom, _zoom_level):
		return
	var zoom_ratio := _zoom_level / previous_zoom
	_pan_offset = focus_position - ((focus_position - _pan_offset) * zoom_ratio)
	_update_city_layer_transform()

func _reset_view(bounds: Rect2i) -> void:
	var panel_size := city_panel.size
	if panel_size.x <= 0.0 or panel_size.y <= 0.0:
		return
	var map_size := Vector2(bounds.size * tile_size)
	_map_origin_offset = -Vector2(bounds.position * tile_size)
	var fit_zoom := minf(
		panel_size.x / maxf(map_size.x + 32.0, 1.0),
		panel_size.y / maxf(map_size.y + 32.0, 1.0)
	)
	_zoom_level = clampf(fit_zoom, MIN_ZOOM, 1.0)
	var scaled_map_size := map_size * _zoom_level
	_pan_offset = (panel_size - scaled_map_size) * 0.5
	_update_city_layer_transform()

func _update_city_layer_transform() -> void:
	city_layer.scale = Vector2.ONE * _zoom_level
	city_layer.position = _pan_offset + (_map_origin_offset * _zoom_level)
	decor_layer.scale = city_layer.scale
	decor_layer.position = city_layer.position
	if tile_hover_tooltip.visible:
		tile_hover_tooltip.position = _clamp_tooltip_position(tile_hover_tooltip.position)
	_update_zone_overlay()

func _place_tile(target_layer: TileMapLayer, cell: Vector2i, tile_key: String) -> void:
	var atlas_coords: Vector2i = TILE_ATLAS.get(tile_key, Vector2i(-1, -1))
	if atlas_coords.x < 0:
		return
	target_layer.set_cell(cell, 0, atlas_coords, 0)

func _pick_base_tile(grid: Dictionary, x: int, y: int, cell: int) -> String:
	if _is_structural_cell(cell):
		return _wall_or_floor_tile(grid, x, y, cell)
	match cell:
		CELL_HALL:
			return "floor"
		CELL_ROCK:
			if _is_hall_border_rock_cell(grid, x, y):
				return "stone"
			return ""
		CELL_HOUSE, CELL_BUILDING:
			return _wall_or_floor_tile(grid, x, y, cell)
		_:
			return "stone"

func _is_hall_border_rock_cell(grid: Dictionary, x: int, y: int) -> bool:
	if _cell_at(grid, x, y) != CELL_ROCK:
		return false
	for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var neighbor := Vector2i(x, y) + direction
		if _is_corridor_cell(_cell_at(grid, neighbor.x, neighbor.y)):
			return true
	return false

func _wall_or_floor_tile(grid: Dictionary, x: int, y: int, cell: int) -> String:
	var current_cell := Vector2i(x, y)
	if _door_cells.has(current_cell):
		return "door"

	var left_cell := _cell_at(grid, x - 1, y)
	var right_cell := _cell_at(grid, x + 1, y)
	var top_cell := _cell_at(grid, x, y - 1)
	var bottom_cell := _cell_at(grid, x, y + 1)
	var left_open := _is_corridor_cell(left_cell)
	var right_open := _is_corridor_cell(right_cell)
	var top_open := _is_corridor_cell(top_cell)
	var bottom_open := _is_corridor_cell(bottom_cell)
	var left_same := left_cell == cell
	var right_same := right_cell == cell
	var top_same := top_cell == cell
	var bottom_same := bottom_cell == cell

	if left_open:
		return "stone"
	if right_open:
		return "stone"
	if top_open or not top_same:
		return "stone"
	if bottom_open or not bottom_same:
		return "stone"
	if not left_same:
		return "stone"
	if not right_same:
		return "stone"

	return "floor"

func _is_furniture_tile(tile_key: String) -> bool:
	return tile_key in [
		"bed", "chest", "wardrobe", "stool", "mug",
		"workbench", "desk", "anvil", "shelf", "armor_stand", "winepress", "butcher_table", "flour",
		"table", "table_alt", "keg", "target", "water_bucket", "grain_bag"
	]

func _building_type_for_cell(cell: Vector2i) -> String:
	return String(_latest_civic_building_type_map.get(cell, "workshop"))

func _pick_civic_building_decor_tile(cell: Vector2i) -> String:
	var building_type := _building_type_for_cell(cell)
	var civic_definition := CIVIC_BUILDING_TYPES.get(building_type, CIVIC_BUILDING_TYPES["workshop"]) as Dictionary
	var decor_pool := civic_definition.get("decor_tile_pool", PackedStringArray(["workbench", "desk", "anvil"])) as PackedStringArray
	if decor_pool.is_empty():
		return ""
	return String(decor_pool[_rng.randi_range(0, decor_pool.size() - 1)])

func _pick_decor_tile(grid: Dictionary, x: int, y: int, cell: int, base_tile: String, house_decor_overrides: Dictionary) -> String:
	var key := Vector2i(x, y)
	if house_decor_overrides.has(key):
		var house_tile := String(house_decor_overrides[key])
		if _is_furniture_tile(house_tile) and base_tile != "floor":
			return ""
		if (house_tile == "wardrobe" or house_tile == "shelf") and not _is_adjacent_to_stone_or_wall(grid, x, y):
			return ""
		return house_tile

	if _is_corridor_cell(cell):
		if _rng.randf() < 0.015:
			var corridor_tile: String = String(["target", "sign", "keg", "water_bucket"][_rng.randi_range(0, 3)])
			if _is_furniture_tile(corridor_tile) and base_tile != "floor":
				return ""
			return corridor_tile
		return ""
	if _is_structural_cell(cell):
		if _is_corridor_cell(_cell_at(grid, x - 1, y)) or _is_corridor_cell(_cell_at(grid, x + 1, y)) or _is_corridor_cell(_cell_at(grid, x, y - 1)) or _is_corridor_cell(_cell_at(grid, x, y + 1)):
			return ""
		if _rng.randf() > 0.09:
			return ""
		if cell == CELL_HOUSE:
			var house_random_tile: String = String(["bed", "chest", "wardrobe", "stool", "mug"][_rng.randi_range(0, 4)])
			if _is_furniture_tile(house_random_tile) and base_tile != "floor":
				return ""
			if house_random_tile == "wardrobe" and not _is_adjacent_to_stone_or_wall(grid, x, y):
				return ""
			return house_random_tile
		if cell == CELL_BUILDING:
			var building_tile := _pick_civic_building_decor_tile(Vector2i(x, y))
			if _is_furniture_tile(building_tile) and base_tile != "floor":
				return ""
			if building_tile == "shelf" and not _is_adjacent_to_stone_or_wall(grid, x, y):
				return ""
			return building_tile
		var default_tile: String = String(["table", "mug", "water_bucket"][_rng.randi_range(0, 2)])
		if _is_furniture_tile(default_tile) and base_tile != "floor":
			return ""
		return default_tile
	return ""

func _is_adjacent_to_stone_or_wall(grid: Dictionary, x: int, y: int) -> bool:
	for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var neighbor := Vector2i(x, y) + direction
		var neighbor_cell := _cell_at(grid, neighbor.x, neighbor.y)
		if neighbor_cell == CELL_ROCK:
			return true
		if _is_structural_cell(neighbor_cell) and _wall_or_floor_tile(grid, neighbor.x, neighbor.y, neighbor_cell) == "stone":
			return true
	return false

func _update_summary(grid: Dictionary, seed_text: String) -> void:
	var bounds := _find_bounds(grid)
	var hall_zones := int(_latest_zone_counts.get("halls", 0))
	var house_zones := int(_latest_zone_counts.get("houses", 0))
	var building_zones := int(_latest_zone_counts.get("buildings", 0))
	var requested_halls := int(_latest_requested_zone_counts.get("halls", 0))
	var requested_houses := int(_latest_requested_zone_counts.get("houses", 0))
	var requested_buildings := int(_latest_requested_zone_counts.get("buildings", 0))

	var building_subtype_summary := _building_subtype_summary_text()
	city_summary.text = "Seed %s\nBounds: %dx%d (origin %d, %d)\nHalls: %d/%d | Houses: %d/%d | Buildings: %d/%d" % [
		seed_text,
		bounds.size.x,
		bounds.size.y,
		bounds.position.x,
		bounds.position.y,
		hall_zones,
		requested_halls,
		house_zones,
		requested_houses,
		building_zones,
		requested_buildings
	]
	if not building_subtype_summary.is_empty():
		city_summary.text += "\nBuilding Types: %s" % building_subtype_summary

func _update_hover_tooltip(mouse_position: Vector2) -> void:
	if city_layer.tile_set == null:
		_hide_hover_tooltip()
		return

	var local_position := (mouse_position - city_layer.position) / _zoom_level
	var hovered_cell := city_layer.local_to_map(local_position)
	var hovered_layer := decor_layer
	if decor_layer.get_cell_source_id(hovered_cell) < 0:
		hovered_layer = city_layer
	if hovered_layer.get_cell_source_id(hovered_cell) < 0:
		_hide_hover_tooltip()
		return

	var atlas_coords := hovered_layer.get_cell_atlas_coords(hovered_cell)
	var tile_name := _tile_name_from_atlas(atlas_coords)
	var zone_name := _zone_name_for_cell(hovered_cell)
	var tooltip_lines: PackedStringArray = ["Tile: %s" % tile_name, "Zone: %s" % zone_name]
	var subtype := _building_type_for_cell_or_empty(hovered_cell)
	if not subtype.is_empty():
		tooltip_lines.append("Subtype: %s" % _display_name_for_building_type(subtype))
		var flavor := String(BUILDING_SUBTYPE_FLAVOR.get(subtype, ""))
		if not flavor.is_empty():
			tooltip_lines.append(flavor)
	tile_hover_label.text = "\n".join(tooltip_lines)
	tile_hover_tooltip.visible = true
	tile_hover_tooltip.reset_size()
	tile_hover_tooltip.position = _clamp_tooltip_position(mouse_position + Vector2(14, 14))

func _hide_hover_tooltip() -> void:
	tile_hover_tooltip.visible = false

func _tile_name_from_atlas(atlas_coords: Vector2i) -> String:
	for tile_key: String in TILE_ATLAS.keys():
		if TILE_ATLAS[tile_key] == atlas_coords:
			return tile_key.replace("_", " ").capitalize()
	return "Unknown"

func _zone_name_for_cell(cell: Vector2i) -> String:
	if _latest_grid.is_empty():
		return "Unknown"

	var zone := _cell_at(_latest_grid, cell.x, cell.y)
	match zone:
		CELL_HALL:
			return "Hall"
		CELL_HOUSE:
			return "House"
		CELL_BUILDING:
			var subtype := _building_type_for_cell_or_empty(cell)
			if subtype.is_empty():
				return "Building"
			return "Building (%s)" % _display_name_for_building_type(subtype)
		_:
			return "Rock"

func _building_type_for_cell_or_empty(cell: Vector2i) -> String:
	if not _latest_civic_building_type_map.has(cell):
		return ""
	return String(_latest_civic_building_type_map[cell])

func _display_name_for_building_type(building_type: String) -> String:
	var words := building_type.split("_", false)
	for i in range(words.size()):
		words[i] = String(words[i]).capitalize()
	return " ".join(words)

func _building_subtype_summary_text() -> String:
	if _latest_civic_buildings_by_id.is_empty():
		return ""

	var subtype_counts: Dictionary = {}
	for building_id: String in _latest_civic_buildings_by_id.keys():
		var payload := _latest_civic_buildings_by_id[building_id] as Dictionary
		var subtype := String(payload.get("type", "workshop"))
		subtype_counts[subtype] = int(subtype_counts.get(subtype, 0)) + 1

	var sorted_subtypes := subtype_counts.keys()
	sorted_subtypes.sort_custom(func(a: Variant, b: Variant) -> bool:
		return String(a) < String(b)
	)

	var entries: PackedStringArray = []
	for subtype_variant: Variant in sorted_subtypes:
		var subtype := String(subtype_variant)
		entries.append("%s: %d" % [_display_name_for_building_type(subtype), int(subtype_counts[subtype])])
	return ", ".join(entries)

func _clamp_tooltip_position(desired_position: Vector2) -> Vector2:
	var tooltip_size := tile_hover_tooltip.size
	var panel_size := city_panel.size
	return Vector2(
		clampf(desired_position.x, 0.0, maxf(panel_size.x - tooltip_size.x, 0.0)),
		clampf(desired_position.y, 0.0, maxf(panel_size.y - tooltip_size.y, 0.0))
	)
