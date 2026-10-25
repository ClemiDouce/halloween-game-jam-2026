class_name BaseManager
extends Node

signal slot_updated(grid_x: int, grid_y: int)

const BUILDING_GRID_X: int = 3
const BUILDING_GRID_Y: int = 3

var building_slots: Array[BuildingSlot] = []
var _selected_build_slot = null


func _ready() -> void:
	_generate_building_slots()


## Initialize building_slots
func _generate_building_slots() -> void:
	for x in range(BUILDING_GRID_X):
		for y in range(BUILDING_GRID_Y):
			var slot := BuildingSlot.new()
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
