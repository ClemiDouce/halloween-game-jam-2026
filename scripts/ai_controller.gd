class_name AIController extends Node

@export var controlling_base: BaseManager

var decision_delay : float = 1.2

func _ready() -> void:
	controlling_base.team = CombatData.Team.HOSTILE
	
	# Build a factory
	
func select_path(index: int):
	controlling_base.select_path_by_index(index)
