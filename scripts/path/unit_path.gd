class_name UnitPath extends Node

@export var point_list : Array[Node2D]
var end_index : int:
	get:
		return point_list.size() - 1

func get_next_point(index: int, path_dir: int):
	if index + path_dir >= point_list.size() or index + path_dir < 0:
		return Vector2.INF
	else:
		return point_list[index + path_dir].global_position

func get_start_position():
	return point_list[0].global_position

func get_end_position():
	return point_list[end_index].global_position
