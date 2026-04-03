extends RefCounted

const ATLAS_TEXTURE := "res://resources/images/overworld/atlas/overworld.png"
const SAND_TILE := Vector2i(0, 0)
const GRASS_TILE := Vector2i(1, 0)
const BADLANDS_TILE := Vector2i(2, 1)
const MINE_TILE := Vector2i(3, 1)
const MARSH_TILE := Vector2i(2, 2)
const SNOW_TILE := Vector2i(3, 2)
const TREE_TILE := Vector2i(0, 1)
const TREE_LONE_TILE := Vector2i(0, 2)
const JUNGLE_TREE_TILE := Vector2i(0, 3)
const CUT_TREES_TILE := Vector2i(1, 5)
const AMBIENT_LUMBER_MILL_TILE := Vector2i(0, 6)
const WATER_TILE := Vector2i(4, 1)
const RIVER_TILES := {
	"RIVER_NS": Vector2i(0, 4),
	"RIVER_WE": Vector2i(1, 4),
	"RIVER_SE": Vector2i(2, 4),
	"RIVER_SW": Vector2i(3, 4),
	"RIVER_NE": Vector2i(4, 4),
	"RIVER_NW": Vector2i(5, 4),
	"RIVER_NSE": Vector2i(6, 4),
	"RIVER_SWE": Vector2i(7, 4),
	"RIVER_NWE": Vector2i(8, 4),
	"RIVER_NSW": Vector2i(9, 4),
	"RIVER_NSWE": Vector2i(10, 4),
	"RIVER_0": Vector2i(11, 4),
	"RIVER_N": Vector2i(12, 4),
	"RIVER_S": Vector2i(13, 4),
	"RIVER_W": Vector2i(14, 4),
	"RIVER_E": Vector2i(15, 4),
	"RIVER_MAJOR_NS": Vector2i(0, 5),
	"RIVER_MAJOR_WE": Vector2i(1, 5),
	"RIVER_MAJOR_SE": Vector2i(2, 5),
	"RIVER_MAJOR_SW": Vector2i(3, 5),
	"RIVER_MAJOR_NE": Vector2i(4, 5),
	"RIVER_MAJOR_NW": Vector2i(5, 5),
	"RIVER_MAJOR_NSE": Vector2i(6, 5),
	"RIVER_MAJOR_SWE": Vector2i(7, 5),
	"RIVER_MAJOR_NWE": Vector2i(8, 5),
	"RIVER_MAJOR_NSW": Vector2i(9, 5),
	"RIVER_MAJOR_NSWE": Vector2i(10, 5),
	"RIVER_MAJOR_0": Vector2i(11, 5),
	"RIVER_MAJOR_N": Vector2i(12, 5),
	"RIVER_MAJOR_S": Vector2i(13, 5),
	"RIVER_MAJOR_W": Vector2i(14, 5),
	"RIVER_MAJOR_E": Vector2i(15, 5),
	"RIVER_MOUTH_NARROW_N": Vector2i(12, 7),
	"RIVER_MOUTH_NARROW_S": Vector2i(13, 7),
	"RIVER_MOUTH_NARROW_W": Vector2i(14, 7),
	"RIVER_MOUTH_NARROW_E": Vector2i(15, 7),
	"RIVER_MAJOR_MOUTH_NARROW_N": Vector2i(12, 8),
	"RIVER_MAJOR_MOUTH_NARROW_S": Vector2i(13, 8),
	"RIVER_MAJOR_MOUTH_NARROW_W": Vector2i(14, 8),
	"RIVER_MAJOR_MOUTH_NARROW_E": Vector2i(15, 8)
}
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
const HILLS_VARIANT_B_TILE := Vector2i(9, 3)
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
const AMBIENT_MOONWELL_TILE := Vector2i(10, 3)
const AMBIENT_FARM_TILE := Vector2i(15, 1)
const FARM_CROPS_TILE := Vector2i(15, 0)
const AMBIENT_FARM_VARIANT_TILE := Vector2i(16, 2)
const AMBIENT_GREAT_TREE_TILE := Vector2i(14, 1)
const AMBIENT_GREAT_TREE_ALT_TILE := Vector2i(15, 2)
const LIZARDMEN_CITY_TILE := Vector2i(11, 2)
const SAINT_SHRINE_TILE := Vector2i(11, 1)
const MONASTERY_TILE := Vector2i(2, 2)
const ORC_CAMP_TILE := Vector2i(11, 3)
const GNOLL_CAMP_TILE := Vector2i(11, 0)
const TROLL_CAMP_TILE := Vector2i(9, 0)
const OGRE_CAMP_TILE := Vector2i(9, 1)
const BANDIT_CAMP_TILE := Vector2i(10, 1)
const TRAVELERS_CAMP_TILE := Vector2i(7, 1)
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

const TREE_BIOMES: Array[String] = [BIOME_FOREST, BIOME_JUNGLE, BIOME_TUNDRA]
const TREE_BASE_BIOMES: Array[String] = [BIOME_GRASSLAND, BIOME_TUNDRA]
const TREE_VARIANT_FOREST_LONE := "forest_lone"
const TREE_VARIANT_TUNDRA_LONE := "tundra_lone"
