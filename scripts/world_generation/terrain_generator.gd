extends RefCounted

const MASK_TWIN_LEFT_CENTER := Vector2(0.32, 0.48)
const MASK_TWIN_RIGHT_CENTER := Vector2(0.68, 0.52)
const MASK_TWIN_RADIUS := Vector2(0.55, 0.33)
const MASK_SADDLE_SCALE := 2.2

static func sample_height(continent_noise: FastNoiseLite, detail_noise: FastNoiseLite, ridge_noise: FastNoiseLite, x: int, y: int, settings: Dictionary, landmass_centers: Array[Vector2]) -> float:
	var continent := to_normalized(continent_noise.get_noise_2d(float(x), float(y)))
	var detail := to_normalized(detail_noise.get_noise_2d(float(x), float(y)))
	var ridges := 1.0 - absf(ridge_noise.get_noise_2d(float(x), float(y)))
	var height := continent * 0.72 + detail * 0.18 + ridges * 0.1
	var archipelago := (to_normalized(detail_noise.get_noise_2d(float(x) * 2.6, float(y) * 2.6)) - 0.5) * 0.12
	height += archipelago
	height += sample_continent_bias(x, y, settings, landmass_centers)
	var water_level := float(settings.get("water_level", 0.45))
	var coast_mask := 1.0 - clampf(absf(height - water_level) / 0.15, 0.0, 1.0)
	var coast_jag := detail_noise.get_noise_2d(float(x) * 5.1, float(y) * 5.1) * 0.06 * coast_mask
	return clampf(height + coast_jag, 0.0, 1.0)

static func configure_landmass_centers(rng: RandomNumberGenerator, count: int, margin: float) -> Array[Vector2]:
	var centers: Array[Vector2] = []
	var safe_count := maxi(1, count)
	var clamped_margin := clampf(margin, 0.0, 0.45)
	for _i in range(safe_count):
		centers.append(Vector2(rng.randf_range(-1.0 + clamped_margin, 1.0 - clamped_margin), rng.randf_range(-1.0 + clamped_margin, 1.0 - clamped_margin)))
	return centers

static func smooth_height_map(height_map: Dictionary, passes: int, strength: float, water_level: float) -> void:
	for _pass_index in range(passes):
		var next_map := height_map.duplicate()
		for coord: Vector2i in height_map.keys():
			var current: float = height_map.get(coord, 0.0)
			var is_land := current >= water_level
			var accum := current
			var count := 1
			for offset: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN, Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)]:
				var neighbor := coord + offset
				var neighbor_height: float = height_map.get(neighbor, current)
				if is_land and neighbor_height < water_level: continue
				if not is_land and neighbor_height >= water_level: continue
				accum += neighbor_height
				count += 1
			next_map[coord] = lerpf(current, accum / float(count), strength)
		height_map.clear()
		for coord: Vector2i in next_map.keys():
			height_map[coord] = next_map[coord]

static func to_normalized(noise_sample: float) -> float:
	return clampf((noise_sample + 1.0) * 0.5, 0.0, 1.0)

static func sample_continent_bias(x: int, y: int, settings: Dictionary, landmass_centers: Array[Vector2]) -> float:
	var map_size := settings.get("map_size", Vector2i.ONE) as Vector2i
	var denom_x := maxf(1.0, float(map_size.x - 1))
	var denom_y := maxf(1.0, float(map_size.y - 1))
	var nx := float(x) / denom_x
	var ny := float(y) / denom_y
	var centered_nx := nx * 2.0 - 1.0
	var centered_ny := ny * 2.0 - 1.0
	var map_seed := int(settings.get("map_seed", 0))
	var base_seed := map_seed + 0x6a09e667
	var fractal := (value_noise(nx * 18.0 + 2.3, ny * 18.0 + 9.7, base_seed) - 0.5) * 0.1
	fractal += (value_noise(nx * 42.0 + 13.1, ny * 42.0 + 5.4, base_seed + 0xbb67ae85) - 0.5) * 0.05
	var radial := sample_radial_falloff_bias(centered_nx, centered_ny, float(settings.get("falloff_strength", 0.0)), float(settings.get("falloff_power", 2.4)))
	var center := sample_landmass_center_bias(centered_nx, centered_ny, float(settings.get("landmass_falloff_scale", 1.35)), float(settings.get("falloff_power", 2.4)), landmass_centers)
	var mask := sample_landmass_mask_bias(nx, ny, settings)
	return fractal + radial + center + mask + sample_edge_ocean_bias(x, y, settings)

static func sample_edge_ocean_bias(x: int, y: int, settings: Dictionary) -> float:
	var map_size := settings.get("map_size", Vector2i.ONE) as Vector2i
	var max_x := maxf(1.0, float(map_size.x - 1))
	var max_y := maxf(1.0, float(map_size.y - 1))
	var edge_distance := minf(minf(float(x), max_x - float(x)), minf(float(y), max_y - float(y)))
	var half_span := minf(max_x, max_y) * 0.5
	var edge_normalized := clampf(edge_distance / maxf(half_span, 1.0), 0.0, 1.0)
	var falloff := maxf(float(settings.get("edge_ocean_falloff", 0.32)), 0.01)
	var edge_ratio := clampf(edge_normalized / falloff, 0.0, 1.0)
	var edge_ocean := 1.0 - pow(edge_ratio, float(settings.get("edge_ocean_curve", 1.6)))
	var strength := float(settings.get("edge_ocean_strength", 0.2))
	var interior_support := pow(clampf(edge_normalized, 0.0, 1.0), 2.2) * (strength * 0.28)
	return interior_support - edge_ocean * strength

static func sample_radial_falloff_bias(centered_nx: float, centered_ny: float, falloff_strength: float, falloff_power: float) -> float:
	if falloff_strength <= 0.0: return 0.0
	var radial_distance := Vector2(centered_nx, centered_ny).length() / sqrt(2.0)
	var attenuation := 1.0 - pow(clampf(radial_distance, 0.0, 1.0), maxf(falloff_power, 0.05))
	return (attenuation - 0.5) * 2.0 * falloff_strength

static func sample_landmass_center_bias(centered_nx: float, centered_ny: float, landmass_falloff_scale: float, falloff_power: float, landmass_centers: Array[Vector2]) -> float:
	var clamped_scale := maxf(0.001, landmass_falloff_scale)
	var center_distance := distance_to_nearest_landmass_center(centered_nx, centered_ny, landmass_centers)
	var center_support := 1.0 - pow(clampf(center_distance / clamped_scale, 0.0, 1.0), maxf(falloff_power, 0.05))
	return (center_support - 0.5) * 2.0 * (landmass_falloff_scale * 0.08)

static func sample_landmass_mask_bias(nx: float, ny: float, settings: Dictionary) -> float:
	var strength := float(settings.get("landmass_mask_strength", 0.0))
	if strength <= 0.0: return 0.0
	return (sample_landmass_mask(nx, ny, settings) - 0.5) * 2.0 * strength

static func distance_to_nearest_landmass_center(nx: float, ny: float, landmass_centers: Array[Vector2]) -> float:
	if landmass_centers.is_empty(): return Vector2(nx, ny).length()
	var sample_pos := Vector2(nx, ny)
	var min_distance := INF
	for center: Vector2 in landmass_centers:
		min_distance = minf(min_distance, sample_pos.distance_to(center))
	return min_distance

static func sample_landmass_mask(nx: float, ny: float, settings: Dictionary) -> float:
	var left := ellipse_distance(nx, ny, MASK_TWIN_LEFT_CENTER, MASK_TWIN_RADIUS)
	var right := ellipse_distance(nx, ny, MASK_TWIN_RIGHT_CENTER, MASK_TWIN_RADIUS)
	var value := 1.0 - minf(left, right)
	value = pow(clampf(value, 0.0, 1.0), float(settings.get("landmass_mask_power", 0.82)))
	value += cos((ny - 0.5) * PI * MASK_SADDLE_SCALE) * 0.05
	var map_seed := int(settings.get("map_seed", 0))
	var base_seed := map_seed + 0x9e3779b
	value += (value_noise(nx * 12.5 + 3.1, ny * 12.5 + 7.9, base_seed) - 0.5) * 0.12
	value += (value_noise(nx * 34.2 + 11.3, ny * 34.2 + 4.6, base_seed + 0x85ebca6) - 0.5) * 0.06
	return clampf(value, 0.0, 1.0)

static func ellipse_distance(nx: float, ny: float, center: Vector2, radius: Vector2) -> float:
	var dx := (nx - center.x) / maxf(radius.x, 0.001)
	var dy := (ny - center.y) / maxf(radius.y, 0.001)
	return sqrt(dx * dx + dy * dy)

static func value_noise(x: float, y: float, seed_value: int) -> float:
	var xi := int(floor(x))
	var yi := int(floor(y))
	var tx := x - float(xi)
	var ty := y - float(yi)
	var a := hash_coords(xi, yi, seed_value)
	var b := hash_coords(xi + 1, yi, seed_value)
	var c := hash_coords(xi, yi + 1, seed_value)
	var d := hash_coords(xi + 1, yi + 1, seed_value)
	var u := fade(tx)
	var v := fade(ty)
	var ab := lerpf(a, b, u)
	var cd := lerpf(c, d, u)
	return lerpf(ab, cd, v)

static func hash_coords(x: int, y: int, seed_value: int) -> float:
	var h := uint64(x) * 374761393 + uint64(y) * 668265263 + uint64(seed_value) * 2654435761
	h = (h ^ (h >> 13)) * 1274126177
	h = h ^ (h >> 16)
	var unsigned := h & 0xffffffff
	return float(unsigned) / 4294967295.0

static func fade(t: float) -> float:
	return t * t * t * (t * (t * 6.0 - 15.0) + 10.0)
