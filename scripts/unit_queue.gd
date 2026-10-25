class_name UnitQueue
extends Object

var path: UnitPath

signal unit_ready(type: UnitResource, path: UnitPath)

func add_to_queue(type: UnitResource):
	unit_ready.emit(type, path)
