class_name Wave extends Resource

@export var unit_spawn_chance : Dictionary[AIAction, float]

func get_random_action() -> AIAction:
	var rng = RandomNumberGenerator.new()
	var random_choice : AIAction = unit_spawn_chance.keys()[rng.rand_weighted(unit_spawn_chance.values())]
	return random_choice
