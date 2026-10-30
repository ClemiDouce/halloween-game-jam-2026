class_name BaseManager
extends Node

signal slot_updated(slot: BuildingSlot)
signal path_selected(path: UnitPath)
signal unit_ready(type: UnitResource, path: UnitPath)

# Unit Spawn
const UNIT_ENTITY = preload("uid://bybp5w4ae511b")

# Building
const BUILDING_GRID_X: int = 3
const BUILDING_GRID_Y: int = 3

var team : CombatData.Team

static var _buildings: Array[Building] = []
var disabled_units: Array[String] = []


var paths: Array[UnitPath]
var entity_parent: Node2D

var building_slots: Array[BuildingSlot] = []
var unit_queue: UnitQueue = UnitQueue.new()
var _selected_path: UnitPath:
	set(value):
		if _selected_path != value:
			_selected_path = value
			unit_queue.path = _selected_path
			path_selected.emit(_selected_path)
	get():
		return _selected_path

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_PAUSABLE
	self.unit_queue.unit_ready.connect(generate_unit)
	
	_generate_building_slots()

func _update_game_rule_references() -> void:
	for x in range(BUILDING_GRID_X):
		for y in range(BUILDING_GRID_Y):
			var slot := get_build_slot(x,y)
			slot._banned_units = disabled_units

func set_game_rules(rules: GameRules) -> void:
	disabled_units.clear()
	_buildings = rules.enabled_buildings
	for unit in rules.disabled_units:
		disabled_units.append(unit.unit_name)
	_update_game_rule_references()

func generate_unit(unit_type, path):
	var unit = UNIT_ENTITY.instantiate() as UnitEntity
	entity_parent.add_child.call_deferred(unit)
	await unit.ready
	unit.set_unit(unit_type, path, team)

func connect_to_level(level_paths: Array[UnitPath], level_entity_parent: Node2D):
	paths = level_paths
	entity_parent = level_entity_parent
	_selected_path = paths[0]

func _process(delta: float) -> void:
	unit_queue._process(delta)

func next_path() -> void:
	var index = paths.find(_selected_path)
	if index + 1 >= paths.size():
		index = 0
	else:
		index += 1
	_selected_path = paths[index]

func select_path_by_index(path_index: int) -> void:
	if path_index < 0 or path_index >= paths.size():
		return
	_selected_path = paths[path_index]

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
			slot._banned_units = disabled_units
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

func reset_base():
	for slot in building_slots:
		slot.destroy()
		slot_updated.emit.call_deferred(slot)
	unit_queue.clear_queue()
	
