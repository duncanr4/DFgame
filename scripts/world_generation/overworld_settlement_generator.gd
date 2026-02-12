class_name OverworldSettlementGenerator
extends RefCounted

func place(host: Node, biome_map: Dictionary, rng: RandomNumberGenerator) -> void:
	host._place_settlements(biome_map, rng)
