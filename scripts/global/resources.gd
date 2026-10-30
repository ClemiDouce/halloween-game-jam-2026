extends Node

signal requisition_updated(new_value: int, diff: int)
signal crystal_updated(new_value: int, diff: int)

func set_start_value(requisition_start: int, crystal_start):
	requisition = requisition_start
	crystal = crystal_start
	

var requisition: int = 0:
	set(new_value):
		requisition_updated.emit(new_value, new_value - requisition)
		requisition = new_value

var crystal: int = 0:
	set(new_value):
		crystal_updated.emit(new_value, new_value - crystal)
		crystal = new_value
