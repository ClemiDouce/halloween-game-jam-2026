class_name UnitQueue
extends Object

signal unit_ready(type: UnitResource, path: UnitPath)

func add_to_queue(type: UnitResource, path: UnitPath):
	unit_ready.emit(type, path)
