class_name BaseManager
extends Node

signal slot_updated(slot: BuildingSlot)

const BUILDING_GRID_X: int = 3
const BUILDING_GRID_Y: int = 3

static var _buildings: Array[Building] = [preload("res://data/buildings/tank_factory.tres")]

@export var paths: Array[UnitPath]
@export var overworld: Node2D

var building_slots: Array[BuildingSlot] = []
var unit_queue: UnitQueue = UnitQueue.new()

func _ready() -> void:
	self.unit_queue.unit_ready.connect(func(unit_type, path):
		print("spawning unit")
	)
	
	_generate_building_slots()


func get_building_types() -> Array[Building]:
	return _buildings


## Initialize building_slots
func _generate_building_slots() -> void:
	for x in range(BUILDING_GRID_X):
		for y in range(BUILDING_GRID_Y):
			var slot := BuildingSlot.new()
			slot.paths = paths
			slot.queue = unit_queue
			slot.slot_updated.connect(slot_updated.emit.bind(slot))
			building_slots.append(slot)


## Get the building slot X,Y position
func get_build_slot(x: int, y: int) -> BuildingSlot:
	var index: int = y * BUILDING_GRID_X + x
	if index < 0 or index >= building_slots.size():
		return null
	return building_slots[index]


## Get the grid position from the BuildingSlot object
func get_grid_pos(slot: BuildingSlot) -> Vector2i:
	for x in range(BUILDING_GRID_X):
		for y in range(BUILDING_GRID_Y):
			if get_build_slot(x, y) == slot:
				return Vector2i(x, y)
	return Vector2i.ZERO
