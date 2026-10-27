class_name Level 
extends Node2D

@export var paths: Array[UnitPath] = []
@export var entity_parent: Node2D
@export var path_cursor: PathCursor

@export var ai_list : Array[BaseManager]

func setup_level(base_manager: BaseManager):
	base_manager.path_selected.connect(path_cursor.on_path_selected)
	for ai : BaseManager in ai_list:
		ai.connect_to_level(paths, entity_parent)
