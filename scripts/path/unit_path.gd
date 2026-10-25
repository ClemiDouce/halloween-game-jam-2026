class_name UnitPath extends Node

@export var point_list : Array[Node2D]

func get_next_point(index: int):
	if index + 1 >= point_list.size():
		return Vector2.INF
	else:
		return point_list[index + 1].global_position
	
func get_previous_point(index: int):
	if index - 1 < 0:
		return -1
	else:
		return point_list[index - 1].global_position

func get_start_position():
	return point_list[0].global_position

func get_end_position():
	return point_list[0].global_position
