extends RefCounted

static func temperature_to_color(temperature: float) -> Color:
	var cold := Color(0.2, 0.45, 1.0, 0.45)
	var hot := Color(1.0, 0.25, 0.1, 0.45)
	return cold.lerp(hot, clampf(temperature, 0.0, 1.0))

static func elevation_to_color(height: float, water_level: float, mountain_level: float) -> Color:
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
		var land_ratio := clampf((height - water_level) / maxf(mountain_level - water_level, 0.001), 0.0, 1.0)
		return lowland.lerp(highland, land_ratio)
	var mountain_ratio := clampf((height - mountain_level) / maxf(1.0 - mountain_level, 0.001), 0.0, 1.0)
	return highland.lerp(snow, mountain_ratio)

static func moisture_to_color(moisture: float) -> Color:
	var dry := Color(0.55, 0.35, 0.18, 0.45)
	var wet := Color(0.15, 0.55, 0.9, 0.45)
	return dry.lerp(wet, clampf(moisture, 0.0, 1.0))

static func biome_to_overlay_color(biome: String, alpha: float = 0.45) -> Color:
	match biome:
		"water":
			return Color(0.1, 0.35, 0.75, alpha)
		"mountain":
			return Color(0.55, 0.55, 0.6, alpha)
		"hills":
			return Color(0.6, 0.45, 0.25, alpha)
		"marsh":
			return Color(0.2, 0.6, 0.45, alpha)
		"tundra":
			return Color(0.75, 0.8, 0.9, alpha)
		"desert":
			return Color(0.9, 0.75, 0.35, alpha)
		"badlands":
			return Color(0.7, 0.35, 0.25, alpha)
		"forest":
			return Color(0.2, 0.55, 0.25, alpha)
		"jungle":
			return Color(0.15, 0.45, 0.2, alpha)
		"grassland":
			return Color(0.35, 0.7, 0.35, alpha)
	return Color(0.5, 0.5, 0.5, alpha)
