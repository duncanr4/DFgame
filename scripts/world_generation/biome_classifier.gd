extends RefCounted

static func assign_base_biome(coord: Vector2i, height: float, temperature: float, moisture: float, height_map: Dictionary, thresholds: Dictionary, biomes: Dictionary) -> String:
	if height < float(thresholds.get("water_level", 0.45)):
		return String(biomes.get("water", "water"))
	if temperature < float(thresholds.get("tundra_threshold", 0.28)):
		return String(biomes.get("tundra", "tundra"))
	if is_marsh(coord, height, moisture, height_map, float(thresholds.get("marsh_threshold", 0.68)), float(thresholds.get("water_level", 0.45))):
		return String(biomes.get("marsh", "marsh"))
	var desert_temp_cutoff := clampf(float(thresholds.get("hot_threshold", 0.7)) - float(thresholds.get("desert_temperature_bias", 0.08)), 0.0, 1.0)
	var desert_moisture_cutoff := clampf(float(thresholds.get("desert_threshold", 0.25)) + float(thresholds.get("desert_moisture_bias", 0.08)), 0.0, 1.0)
	if temperature >= desert_temp_cutoff and moisture <= desert_moisture_cutoff:
		return String(biomes.get("desert", "desert"))
	if temperature >= float(thresholds.get("warm_threshold", 0.55)) and moisture <= float(thresholds.get("badlands_threshold", 0.4)):
		return String(biomes.get("badlands", "badlands"))
	return String(biomes.get("grassland", "grassland"))

static func tree_overlay_biome(temperature: float, moisture: float, jungle_threshold: float, hot_threshold: float, tundra_threshold: float, biomes: Dictionary) -> String:
	var jungle_moisture_cutoff := maxf(0.0, jungle_threshold - 0.08)
	var jungle_temperature_cutoff := maxf(0.0, hot_threshold - 0.06)
	if moisture >= jungle_moisture_cutoff and temperature >= jungle_temperature_cutoff:
		return String(biomes.get("jungle", "jungle"))
	if temperature < tundra_threshold:
		return String(biomes.get("tundra", "tundra"))
	return String(biomes.get("forest", "forest"))

static func is_marsh(coord: Vector2i, height: float, moisture: float, height_map: Dictionary, marsh_threshold: float, water_level: float) -> bool:
	if moisture < marsh_threshold:
		return false
	if height <= water_level + 0.08:
		return true
	for offset: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN, Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)]:
		if float(height_map.get(coord + offset, 1.0)) < water_level:
			return true
	return false

static func biome_to_tile(biome: String, tiles: Dictionary, biomes: Dictionary) -> Vector2i:
	if biome == String(biomes.get("water", "water")): return tiles.get("water", Vector2i.ZERO) as Vector2i
	if biome == String(biomes.get("mountain", "mountain")): return tiles.get("mountain", Vector2i.ZERO) as Vector2i
	if biome == String(biomes.get("hills", "hills")): return tiles.get("hills", Vector2i.ZERO) as Vector2i
	if biome == String(biomes.get("marsh", "marsh")): return tiles.get("marsh", Vector2i.ZERO) as Vector2i
	if biome == String(biomes.get("tundra", "tundra")): return tiles.get("snow", Vector2i.ZERO) as Vector2i
	if biome == String(biomes.get("desert", "desert")): return tiles.get("sand", Vector2i.ZERO) as Vector2i
	if biome == String(biomes.get("badlands", "badlands")): return tiles.get("badlands", Vector2i.ZERO) as Vector2i
	if biome == String(biomes.get("forest", "forest")): return tiles.get("tree", Vector2i.ZERO) as Vector2i
	if biome == String(biomes.get("jungle", "jungle")): return tiles.get("jungle_tree", Vector2i.ZERO) as Vector2i
	return tiles.get("grass", Vector2i.ZERO) as Vector2i
