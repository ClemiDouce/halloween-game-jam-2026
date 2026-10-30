class_name AIController extends Node

@export var controlling_base: BaseManager
@export var wave: Wave
@export var base_entity: BaseEntity
@export var team: CombatData.Team = CombatData.Team.HOSTILE

var decision_delay : float = 2.5
var decision_timer := 0.

var started := false

func _ready() -> void:
	controlling_base.team = team
	base_entity.destroyed.connect(func(_base): started = false)
	started = true

func start_controller():
	started = true

func stop_controller():
	started = false
	controlling_base.reset_base()

func select_random_path():
	var random_index = randi_range(0, controlling_base.paths.size())
	controlling_base.select_path_by_index(random_index)

func do_decision():
	started = false
	select_random_path()
	var action = wave.get_random_action()
	for i in range(action.count):
		controlling_base.get_build_slot(1, 1).queue_unit(action.unit, true)
		await get_tree().create_timer(0.2).timeout
	started = true

func _process(delta: float) -> void:
	if started:
		decision_timer += delta
		if decision_timer >= decision_delay:
			decision_timer -= decision_delay
			do_decision()
			
