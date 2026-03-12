extends RefCounted

const SETTLEMENT_NAMES := {
	"dwarves": "Dwarven Hold",
	"humans": "Town",
	"wood_elves": "Grove",
	"lizardmen": "Lizard City"
}

const LIZARDMEN_CITY_NAME_PREFIXES: Array[String] = ["Ix", "Zan", "Tla", "Chal", "Maz", "Quet", "Ssz", "Olo", "Yax", "Huac"]
const LIZARDMEN_CITY_NAME_SUFFIXES: Array[String] = ["atl", "tlan", "co", "maz", "naka", "zotl", "chan", "poc", "quil", "pan"]
const LIZARDMEN_CITY_NAME_SEPARATORS: Array[String] = ["'", "-"]
const LIZARDMEN_CITY_EXTRA_SUFFIX_CHANCE := 0.25

const SETTLEMENT_HISTORY_EVENT_POOL := {
	"human": [
		"the entire town militia was conscripted by the Crown to fight in the Goblin Wars.",
		"townsfolk dragged a corrupt guard captain from office and reclaimed the watch.",
		"a major famine left nearly half the town dead or gone.",
		"orc raiders burned the western quarter before the watch rallied.",
		"merchants brokered a charter guaranteeing grain tithes from the riverlands.",
		"the Night of Lanterns was first celebrated with bonfires on the green.",
		"a shrine to Saint Lyra was dedicated, drawing pilgrims from afar.",
		"the local guild council seized control of civic trade for a generation."
	],
	"dwarven": [
		"an orc war-host lay siege to the gates, but the defenders held firm.",
		"the dragon Kharazhul scorched the upper terraces before being driven into the deeps.",
		"Stonebeard Reserve was first brewed in the hold's brass halls.",
		"stonewrights completed the Deepgate Bastion.",
		"miners breached an ancient vault filled with glimmering mithril.",
		"the Ironwrights forged a new charter beneath the basalt vaults.",
		"the Embervein Clan rose to become the largest clan in the hold."
	],
	"dwarven_variant_abandoned": [
		"the last thane sealed the gates and led the clans to safer halls.",
		"cataclysmic quakes shattered the underways and toppled the great halls."
	],
	"wood_elf": [
		"the Circle of the Silver Bough sealed a rift to the Feywild.",
		"wardens drove back ironwood poachers from the sacred trees.",
		"Rite of the Whispered Glade was first danced beneath the luminous canopy.",
		"a comet painted the canopy in emerald light.",
		"dwarven emissaries were welcomed into the grove for counsel.",
		"the sworn wardens renewed their oath to guard the Heartroot."
	],
	"lizardmen": [
		"the oracles proclaimed the eclipse of twin suns, reshaping temple rites.",
		"scale-priests led the War of Emerald Spears, sending legions into the jungles.",
		"pyramid terraces were carved to honor the gods.",
		"saurus cohorts swore fealty to the ruling temple.",
		"the temple order warded the vaults against serpent cultists."
	],
	"generic": [
		"an uncanny aurora shimmered overhead for seven nights.",
		"a council of elders forged new laws to guide the settlement.",
		"travelers from distant realms brought tales and rare curiosities.",
		"mysterious lights danced above the hills.",
		"craftsfolk raised a hall that became the heart of the community."
	]
}

static func resolve_history_event_pool(history_kind: String) -> Array[String]:
	var fallback_events: Variant = SETTLEMENT_HISTORY_EVENT_POOL.get("generic", [])
	var selected_events: Variant = SETTLEMENT_HISTORY_EVENT_POOL.get(history_kind, fallback_events)
	var source: Variant = selected_events if selected_events is Array else fallback_events
	var event_pool: Array[String] = []
	if source is Array:
		for entry: Variant in source:
			var text := String(entry).strip_edges()
			if not text.is_empty():
				event_pool.append(text)
	return event_pool

static func generate_lizardmen_city_name(rng: RandomNumberGenerator) -> String:
	var prefix := pick_random_entry(LIZARDMEN_CITY_NAME_PREFIXES, rng, "Ix")
	var suffix := pick_random_entry(LIZARDMEN_CITY_NAME_SUFFIXES, rng, "atl")
	var city_name := "%s%s" % [prefix, suffix]
	if rng.randf() < 0.5:
		var separator := pick_random_entry(LIZARDMEN_CITY_NAME_SEPARATORS, rng, "")
		city_name = "%s%s%s" % [prefix, separator, suffix]
	if rng.randf() < LIZARDMEN_CITY_EXTRA_SUFFIX_CHANCE:
		var extra_suffix := pick_random_entry(LIZARDMEN_CITY_NAME_SUFFIXES, rng, "pan")
		city_name += extra_suffix
	return city_name

static func pick_random_entry(options: Array[String], rng: RandomNumberGenerator, fallback: String = "") -> String:
	if options.is_empty():
		return fallback
	return options[rng.randi_range(0, options.size() - 1)]
