class_name BuildingSlot
extends Object

signal slot_updated

var _building: Building = null
var _banned_units: Array[String] = []
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
	var units: Array[UnitResource] = []
	for unit in _building.units:
		if unit.unit_name not in _banned_units:
			units.append(unit)
	return units

func queue_unit(unit_resource: UnitResource, bot: bool = false) -> bool:
	if !bot:
		if unit_resource.unit_name in _banned_units:
			return false
		if not has_building() or unit_resource not in _building.units:
			return false
		if PlayerResources.requisition < unit_resource.money_cost or PlayerResources.crystal < unit_resource.crystal_cost:
			return false
	#print("Unit queued: %s" % [unit_resource.damage])
		if unit_resource.money_cost > 0:
			PlayerResources.requisition -= unit_resource.money_cost
			
		if unit_resource.crystal_cost > 0:
			PlayerResources.crystal -= unit_resource.crystal_cost
	queue.add_to_queue(unit_resource)
	return true
