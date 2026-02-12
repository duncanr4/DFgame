class_name OverworldCultureGenerator
extends RefCounted

func apply(host: Node, biome_map: Dictionary, terrain_maps: Dictionary, rng: RandomNumberGenerator) -> void:
	host._assign_cultural_groups(
		biome_map,
		terrain_maps["temperature_map"],
		terrain_maps["moisture_map"],
		terrain_maps["height_map"],
		rng
	)
