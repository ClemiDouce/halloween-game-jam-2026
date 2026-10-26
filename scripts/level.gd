class_name Level 
extends Node2D

@export var paths: Array[UnitPath] = []
@export var entity_parent: Node2D
@export var path_cursor: PathCursor

func setup_level(base_manager: BaseManager):
	base_manager.path_selected.connect(path_cursor.on_path_selected)
