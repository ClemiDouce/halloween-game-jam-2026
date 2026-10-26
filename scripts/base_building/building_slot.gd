class_name BuildingSlot
extends Object

signal slot_updated

var _building: Building = null
var paths: Array[UnitPath]
var queue: UnitQueue = null


func has_building() -> bool:
	return _building != null


func build(building_type: Building) -> void:
	if has_building():
		push_error("BuildingSlot is already in use, cannot build another building")
		return

	_building = building_type
	slot_updated.emit()


func get_texture() -> Texture:
	if not _building:
		return null
	return _building.building_texture


func destroy() -> void:
	if not has_building():
		return
	_building = null
	slot_updated.emit()

func get_unit_options() -> Array[UnitResource]:
	if not _building:
		return []
	return _building.units

func queue_unit(unit_resource: UnitResource) -> void:
	if not has_building() or unit_resource not in _building.units:
		return
	#print("Unit queued: %s" % [unit_resource.damage])
	queue.add_to_queue(unit_resource)
