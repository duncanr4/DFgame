class_name OverworldTerrainGenerator
extends RefCounted

func generate(host: Node, seed: int, rng: RandomNumberGenerator) -> Dictionary:
	host._configure_landmass_centers(rng)
	var map_size: Vector2i = host.map_size
	var noise_frequency: float = host.noise_frequency
	var noise_octaves: int = host.noise_octaves
	var temperature_frequency: float = host.temperature_frequency
	var rainfall_frequency: float = host.rainfall_frequency

	var continent_noise := FastNoiseLite.new()
	continent_noise.seed = seed
	continent_noise.frequency = (noise_frequency * 0.35) / float(map_size.x)
	continent_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	continent_noise.fractal_octaves = maxi(4, noise_octaves)
	continent_noise.fractal_lacunarity = 2.1
	continent_noise.fractal_gain = 0.52
	continent_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

	var detail_noise := FastNoiseLite.new()
	detail_noise.seed = seed + 37
	detail_noise.frequency = (noise_frequency * 2.2) / float(map_size.x)
	detail_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	detail_noise.fractal_octaves = 4
	detail_noise.fractal_lacunarity = 2.3
	detail_noise.fractal_gain = 0.55
	detail_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

	var ridge_noise := FastNoiseLite.new()
	ridge_noise.seed = seed + 83
	ridge_noise.frequency = (noise_frequency * 1.1) / float(map_size.x)
	ridge_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	ridge_noise.fractal_octaves = 3
	ridge_noise.fractal_lacunarity = 2.0
	ridge_noise.fractal_gain = 0.6
	ridge_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

	host._temperature_noise = FastNoiseLite.new()
	host._temperature_noise.seed = seed + 101
	host._temperature_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	host._temperature_noise.frequency = temperature_frequency / float(map_size.x)
	host._temperature_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	host._temperature_noise.fractal_octaves = 3

	host._rainfall_noise = FastNoiseLite.new()
	host._rainfall_noise.seed = seed + 211
	host._rainfall_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	host._rainfall_noise.frequency = rainfall_frequency / float(map_size.x)
	host._rainfall_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	host._rainfall_noise.fractal_octaves = 4

	host._vegetation_noise = FastNoiseLite.new()
	host._vegetation_noise.seed = seed + 317
	host._vegetation_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	host._vegetation_noise.frequency = (noise_frequency * 2.8) / float(map_size.x)
	host._vegetation_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	host._vegetation_noise.fractal_octaves = 3

	var height_map: Dictionary = {}
	var temperature_map: Dictionary = {}
	var moisture_map: Dictionary = {}
	var vegetation_map: Dictionary = {}

	for y in range(map_size.y):
		for x in range(map_size.x):
			var height := host._sample_height(continent_noise, detail_noise, ridge_noise, x, y)
			height_map[Vector2i(x, y)] = height

	host._smooth_height_map(height_map, 1, 0.35)

	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord := Vector2i(x, y)
			var height: float = height_map[coord]
			temperature_map[coord] = host._sample_temperature(x, y, height)
			moisture_map[coord] = host._sample_moisture(x, y, height)
			vegetation_map[coord] = host._sample_vegetation(x, y, height, moisture_map[coord], temperature_map[coord])

	return {
		"height_map": height_map,
		"temperature_map": temperature_map,
		"moisture_map": moisture_map,
		"vegetation_map": vegetation_map
	}
