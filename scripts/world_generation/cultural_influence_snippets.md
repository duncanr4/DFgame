# Cultural influence integration snippets

## World generation call site

```gdscript
var pipeline := CULTURAL_INFLUENCE.new() as CulturalInfluence
pipeline.apply_cultural_influence(
	map_size.x,
	map_size.y,
	_tile_data,
	_collect_settlement_sources(),
	_collect_faction_sources(),
	func(_coord: Vector2i, tile_data: Dictionary) -> bool:
		return String(tile_data.get("base_biome", tile_data.get("biome_type", "grassland"))) != BIOME_WATER,
	map_seed,
	_resolve_wood_elf_territory()
)
```

## Overlay rendering

```gdscript
var image := pipeline.build_culture_overlay_image(map_size.x, map_size.y, _tile_data, 0.08, 0.62)
var texture := ImageTexture.create_from_image(image)
culture_overlay.texture = texture
culture_overlay.visible = _culture_overlay_enabled
```

## Tooltip extraction

```gdscript
var culture_tooltip := pipeline.build_tooltip_data(tile_data)
var strength_label := String(culture_tooltip.get("strength_label", ""))
var breakdown := culture_tooltip.get("breakdown", []) as Array[Dictionary]
```
