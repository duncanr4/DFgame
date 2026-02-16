extends RefCounted

const FOREST_NAME_PREFIXES: Array[String] = [
	"Verdant", "Whispering", "Emerald", "Silver", "Shadow", "Golden", "Moonlit", "Ancient", "Wild", "Sunset"
]
const FOREST_NAME_SUFFIXES: Array[String] = [
	"Groves", "Woods", "Thicket", "Wilds", "Canopy", "Boughs", "Hollows", "Glade", "Expanse", "Reserve"
]
const FOREST_NAME_MOTIFS: Array[String] = [
	"Echoes", "Mists", "Cicadas", "Fables", "Starlight", "Owls", "Whispers", "Lanterns", "Spirits", "Willows"
]

const MOUNTAIN_NAME_PREFIXES: Array[String] = [
	"Stone", "Iron", "Storm", "Thunder", "Frost", "Dragon", "Obsidian", "Moon", "Sunspire", "Titan"
]
const MOUNTAIN_NAME_SUFFIXES: Array[String] = [
	"Peaks", "Range", "Highlands", "Crown", "Mountains", "Spines", "Escarpment", "Ridge", "Tor", "Bastions"
]
const MOUNTAIN_NAME_MOTIFS: Array[String] = [
	"Storms", "Giants", "Dawn", "Ash", "Echoes", "Legends", "Stars", "Anvils", "Dragons", "Auroras"
]

const DESERT_NAME_DESCRIPTORS: Array[String] = [
	"Shifting", "Burning", "Golden", "Silent", "Glass", "Crimson", "Howling", "Endless", "Scoured", "Sunken"
]
const DESERT_NAME_NOUNS: Array[String] = [
	"Dunes", "Waste", "Expanse", "Sea", "Desert", "Reach", "Barrens", "Quarter", "Wastes", "Sands"
]
const DESERT_NAME_MOTIFS: Array[String] = [
	"Mirages", "Ashes", "Suns", "Bones", "Scorpions", "Dust", "Secrets", "Hollows", "Echoes", "Zephyrs"
]

const TUNDRA_NAME_DESCRIPTORS: Array[String] = [
	"Frozen", "Ivory", "Bleak", "Glimmering", "Shivering", "Frostbound", "Auric", "Pale", "Windshorn", "Starlit"
]
const TUNDRA_NAME_NOUNS: Array[String] = [
	"Tundra", "Reach", "Steppes", "Barrens", "Fields", "Expanse", "Marches", "Plateau", "Glade", "March"
]
const TUNDRA_NAME_MOTIFS: Array[String] = [
	"Auroras", "Frost", "Comets", "Stars", "Echoes", "Drifts", "Owls", "Lights", "Mammoths", "Silence"
]

const GRASSLAND_NAME_DESCRIPTORS: Array[String] = [
	"Windward", "Emerald", "Golden", "Rolling", "Open", "Skylit", "Silver", "Gentle", "Breezy", "Sunlit"
]
const GRASSLAND_NAME_NOUNS: Array[String] = [
	"Plains", "Meadows", "Fields", "Prairies", "Steppes", "Expanse", "Downs", "Reach", "Hearth", "Lowlands"
]
const GRASSLAND_NAME_MOTIFS: Array[String] = [
	"Larks", "Horizon", "Harvests", "Echoes", "Sunsets", "Breezes", "Lanterns", "Auroras", "Stones", "Dreams"
]

const JUNGLE_NAME_DESCRIPTORS: Array[String] = [
	"Emerald", "Verdant", "Sun-dappled", "Obsidian", "Mist-shrouded", "Ancient", "Thundering", "Canopy", "Moonlit", "Serpent"
]
const JUNGLE_NAME_NOUNS: Array[String] = [
	"Jungle", "Wilds", "Canopy", "Rainforest", "Tangle", "Deepwood", "Labyrinth", "Greenway", "Expanse", "Verdure"
]
const JUNGLE_NAME_MOTIFS: Array[String] = [
	"Serpents", "Drums", "Monsoons", "Spirits", "Cenotes", "Orchids", "Tempests", "Roots", "Jaguar Spirits", "Emerald Dawn"
]

const MARSH_NAME_DESCRIPTORS: Array[String] = [
	"Glimmer", "Mire", "Gloom", "Low", "Sodden", "Willow", "Brackish", "Sable", "Sunken", "Twilight"
]
const MARSH_NAME_NOUNS: Array[String] = [
	"Bog", "Fen", "Morass", "Quagmire", "Wetlands", "Mires", "Marsh", "Reeds", "Pools", "Sinks"
]
const MARSH_NAME_MOTIFS: Array[String] = [
	"Fireflies", "Lilies", "Secrets", "Mist", "Echoes", "Cranes", "Reeds", "Moss", "Shadows", "Frogs"
]

const BADLANDS_NAME_DESCRIPTORS: Array[String] = [
	"Shattered", "Redstone", "Sundered", "Dustfallen", "Sunblasted", "Windswept", "Bleached", "Broken", "Scorched", "Cracked"
]
const BADLANDS_NAME_NOUNS: Array[String] = [
	"Badlands", "Wastes", "Breaks", "Barrens", "Tablelands", "Escarpment", "Canyons", "Bluffs", "Ridges", "Maze"
]
const BADLANDS_NAME_MOTIFS: Array[String] = [
	"Bones", "Dust", "Echoes", "Thunderheads", "Vultures", "Ash", "Mirages", "Sunstorms", "Ruins", "Storms"
]

const OCEAN_NAME_DESCRIPTORS: Array[String] = [
	"Sapphire", "Tempest", "Sunken", "Cerulean", "Midnight", "Gilded", "Storm", "Azure", "Silent", "Everdeep"
]
const OCEAN_NAME_NOUNS: Array[String] = [
	"Sea", "Ocean", "Gulf", "Sound", "Reach", "Current", "Depths", "Expanse", "Waters", "Strait"
]
const OCEAN_NAME_MOTIFS: Array[String] = [
	"Sirens", "Stars", "Moons", "Whales", "Voyagers", "Storms", "Legends", "Coral", "Mists", "Echoes"
]

const LAKE_NAME_DESCRIPTORS: Array[String] = [
	"Silver", "Crystal", "Mirror", "Still", "Glimmer", "Duskwater", "Bright", "Moon", "Amber", "Serene"
]
const LAKE_NAME_NOUNS: Array[String] = [
	"Lake", "Mere", "Loch", "Pond", "Basin", "Reservoir", "Waters", "Lagoon", "Pool", "Bay"
]
const LAKE_NAME_MOTIFS: Array[String] = [
	"Echoes", "Willows", "Lanterns", "Dreams", "Reflections", "Whispers", "Herons", "Lilies", "Dawn", "Stars"
]

static func generate_biome_region_name(biome: String, water_body_type: String, rng: RandomNumberGenerator, context_size: int) -> String:
	match biome:
		"forest": return _generate_forest_name(rng)
		"mountain", "hills": return _generate_mountain_name(rng)
		"desert": return _generate_desert_name(rng)
		"tundra": return _generate_tundra_name(rng)
		"grassland": return _generate_grassland_name(rng)
		"jungle": return _generate_jungle_name(rng)
		"marsh": return _generate_marsh_name(rng)
		"badlands": return _generate_badlands_name(rng)
		"water":
			if water_body_type == "lake":
				return _generate_lake_name(rng)
			return _generate_ocean_name(rng, context_size)
		_:
			return ""

static func _generate_forest_name(rng: RandomNumberGenerator) -> String:
	var prefix := _pick_random_entry(FOREST_NAME_PREFIXES, rng, "Verdant")
	var suffix := _pick_random_entry(FOREST_NAME_SUFFIXES, rng, "Woods")
	var motif := _pick_random_entry(FOREST_NAME_MOTIFS, rng)
	var roll := rng.randf()
	if roll < 0.34 and not motif.is_empty(): return "%s %s of the %s" % [prefix, suffix, motif]
	if roll < 0.67: return "The %s %s" % [prefix, suffix]
	return "%s %s" % [prefix, suffix]

static func _generate_mountain_name(rng: RandomNumberGenerator) -> String:
	var prefix := _pick_random_entry(MOUNTAIN_NAME_PREFIXES, rng, "Stone")
	var suffix := _pick_random_entry(MOUNTAIN_NAME_SUFFIXES, rng, "Peaks")
	var motif := _pick_random_entry(MOUNTAIN_NAME_MOTIFS, rng)
	if rng.randf() < 0.5 and not motif.is_empty(): return "%s %s of the %s" % [prefix, suffix, motif]
	return "The %s %s" % [prefix, suffix]

static func _generate_desert_name(rng: RandomNumberGenerator) -> String:
	var descriptor := _pick_random_entry(DESERT_NAME_DESCRIPTORS, rng, "Shifting")
	var noun := _pick_random_entry(DESERT_NAME_NOUNS, rng, "Dunes")
	var motif := _pick_random_entry(DESERT_NAME_MOTIFS, rng)
	if rng.randf() < 0.5 and not motif.is_empty(): return "%s of the %s" % [noun, motif]
	return "The %s %s" % [descriptor, noun]

static func _generate_tundra_name(rng: RandomNumberGenerator) -> String:
	var descriptor := _pick_random_entry(TUNDRA_NAME_DESCRIPTORS, rng, "Frozen")
	var noun := _pick_random_entry(TUNDRA_NAME_NOUNS, rng, "Tundra")
	var motif := _pick_random_entry(TUNDRA_NAME_MOTIFS, rng)
	if rng.randf() < 0.5 and not motif.is_empty(): return "%s of the %s" % [noun, motif]
	return "The %s %s" % [descriptor, noun]

static func _generate_grassland_name(rng: RandomNumberGenerator) -> String:
	var descriptor := _pick_random_entry(GRASSLAND_NAME_DESCRIPTORS, rng, "Windward")
	var noun := _pick_random_entry(GRASSLAND_NAME_NOUNS, rng, "Plains")
	var motif := _pick_random_entry(GRASSLAND_NAME_MOTIFS, rng)
	var roll := rng.randf()
	if roll < 0.34 and not motif.is_empty(): return "%s of the %s" % [noun, motif]
	if roll < 0.67: return "The %s %s" % [descriptor, noun]
	return "%s %s" % [descriptor, noun]

static func _generate_jungle_name(rng: RandomNumberGenerator) -> String:
	var descriptor := _pick_random_entry(JUNGLE_NAME_DESCRIPTORS, rng, "Emerald")
	var noun := _pick_random_entry(JUNGLE_NAME_NOUNS, rng, "Jungle")
	var motif := _pick_random_entry(JUNGLE_NAME_MOTIFS, rng)
	var roll := rng.randf()
	if roll < 0.34 and not motif.is_empty(): return "%s of the %s" % [noun, motif]
	if roll < 0.67: return "The %s %s" % [descriptor, noun]
	return "%s %s" % [descriptor, noun]

static func _generate_marsh_name(rng: RandomNumberGenerator) -> String:
	var descriptor := _pick_random_entry(MARSH_NAME_DESCRIPTORS, rng, "Glimmer")
	var noun := _pick_random_entry(MARSH_NAME_NOUNS, rng, "Bog")
	var motif := _pick_random_entry(MARSH_NAME_MOTIFS, rng)
	if rng.randf() < 0.5 and not motif.is_empty(): return "%s %s of the %s" % [descriptor, noun, motif]
	return "The %s %s" % [descriptor, noun]

static func _generate_badlands_name(rng: RandomNumberGenerator) -> String:
	var descriptor := _pick_random_entry(BADLANDS_NAME_DESCRIPTORS, rng, "Shattered")
	var noun := _pick_random_entry(BADLANDS_NAME_NOUNS, rng, "Badlands")
	var motif := _pick_random_entry(BADLANDS_NAME_MOTIFS, rng)
	var roll := rng.randf()
	if roll < 0.34 and not motif.is_empty(): return "%s of the %s" % [noun, motif]
	if roll < 0.67: return "The %s %s" % [descriptor, noun]
	return "%s %s" % [descriptor, noun]

static func _generate_ocean_name(rng: RandomNumberGenerator, context_size: int) -> String:
	var descriptor := _pick_random_entry(OCEAN_NAME_DESCRIPTORS, rng, "Sapphire")
	var noun := _pick_random_entry(OCEAN_NAME_NOUNS, rng, "Sea")
	var motif := _pick_random_entry(OCEAN_NAME_MOTIFS, rng)
	if context_size < 120 and noun == "Ocean": noun = "Sea"
	if rng.randf() < 0.5 and not motif.is_empty(): return "%s of the %s" % [noun, motif]
	return "The %s %s" % [descriptor, noun]

static func _generate_lake_name(rng: RandomNumberGenerator) -> String:
	var descriptor := _pick_random_entry(LAKE_NAME_DESCRIPTORS, rng, "Silver")
	var noun := _pick_random_entry(LAKE_NAME_NOUNS, rng, "Lake")
	var motif := _pick_random_entry(LAKE_NAME_MOTIFS, rng)
	var lower_noun := noun.to_lower()
	var use_motif := rng.randf() < 0.5
	if lower_noun == "lake" or lower_noun == "loch":
		if use_motif and not motif.is_empty(): return "%s %s" % [noun, motif]
		return "%s %s" % [noun, descriptor]
	if use_motif and not motif.is_empty(): return "The %s %s of the %s" % [descriptor, noun, motif]
	return "The %s %s" % [descriptor, noun]

static func _pick_random_entry(options: Array[String], rng: RandomNumberGenerator, fallback: String = "") -> String:
	if options.is_empty(): return fallback
	return options[rng.randi_range(0, options.size() - 1)]
