class_name Level 
extends Node2D

@export var paths: Array[UnitPath] = []
@export var entity_parent: Node2D

@export var ai_list : Array[BaseManager]
@export var game_rules: GameRules

func _ready() -> void:
	# Use default rules
	if not game_rules:
		game_rules = GameRules.new()

func setup_level():
	for ai : BaseManager in ai_list:
		ai.connect_to_level(paths, entity_parent)

func start_level():
	var controllers = get_tree().get_nodes_in_group("hostile")
	for ai in controllers:
		if ai is AIController:
			ai.start_controller()
		
