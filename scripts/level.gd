class_name Level 
extends Node2D

@export var paths: Array[UnitPath] = []
@export var entity_parent: Node2D

@export var ai_list : Array[BaseManager]

func setup_level(_base_manager: BaseManager):
	for ai : BaseManager in ai_list:
		ai.connect_to_level(paths, entity_parent)
