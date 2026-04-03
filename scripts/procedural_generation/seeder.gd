@tool
class_name Seeder
extends Node

signal recreate_seed
signal seed_changed

static var instance: Seeder

@export var seed_input: LineEdit

@export_group("Predefined Seed", "seed")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var seed_not_random: bool:
	set(value):
		seed_not_random = value
		if is_node_ready():
			_ready()

@export var seed_global: StringName:
	set(value):
		seed_global = value
		if is_node_ready():
			_ready()

@export_tool_button("Recreate Seed", "Callable") var refresh_seed := create_seed

var current_seed: int = 0

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	if not recreate_seed.is_connected(create_seed):
		recreate_seed.connect(create_seed)
	create_seed()

func create_seed() -> void:
	var curr_seed := String(seed_global)
	var is_seed_random := false
	var has_input := seed_input != null and seed_input.text != ""
	if has_input:
		is_seed_random = true
		curr_seed = seed_input.text
	elif seed_not_random and String(seed_global) != "":
		is_seed_random = true

	if is_seed_random:
		current_seed = curr_seed.hash()
		seed(current_seed)
	else:
		var rng := RandomNumberGenerator.new()
		current_seed = rng.randi()

		seed(current_seed)

	seed_changed.emit()
