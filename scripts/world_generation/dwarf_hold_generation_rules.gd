extends RefCounted
class_name DwarfHoldGenerationRules

static func pick_seeded_zone_target(rng: RandomNumberGenerator, count_range: Vector2i) -> int:
	var minimum := mini(count_range.x, count_range.y)
	var maximum := maxi(count_range.x, count_range.y)
	return rng.randi_range(minimum, maximum)

static func pick_random_wander_direction(rng: RandomNumberGenerator) -> Vector2:
	var directions: Array[Vector2] = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	return directions[rng.randi_range(0, directions.size() - 1)]
