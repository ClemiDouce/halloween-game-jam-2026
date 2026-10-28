class_name UnitQueue
extends Object

var path: UnitPath

signal unit_queued(type: UnitResource)
signal unit_ready(type: UnitResource, path: UnitPath)

var queue_list : Array[QueueItem]


func add_to_queue(type: UnitResource):
	var new_item = QueueItem.new()
	new_item.unit = type
	new_item.path = path
	new_item.time_left = type.time_to_build
	unit_queued.emit(type)
	queue_list.append(new_item)

func _process(delta: float):
	if not queue_list.is_empty():
		for item in queue_list:
			item.time_left -= delta
			if item.time_left <= 0.:
				unit_ready.emit(item.unit, item.path)
				item.done = true
		queue_list = queue_list.filter(func(item: QueueItem): return !item.done)
