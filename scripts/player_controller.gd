class_name PlayerController
extends Node

@export var controlling_base: BaseManager

signal building_selected(building: BuildingSlot, pos: Vector2i)
signal selection_stage_changed(stage: SelectionStage)
signal building_built(building: Building)
signal unit_queued(unit: UnitEntity)
signal action_triggered(action_name: String)

enum SelectionStage { NONE, SELECTING }
var _selection_stage: SelectionStage = SelectionStage.NONE:
	set(value):
		if value != _selection_stage:
			_selection_stage = value
			selection_stage_changed.emit(_selection_stage)
	get():
		return _selection_stage

var _selection_row: int = -1
var _selected_building: BuildingSlot = null:
	set(value):
		if value != _selected_building:
			_selected_building = value
			building_selected.emit(
				_selected_building, controlling_base.get_grid_pos(_selected_building)
			)
	get():
		return _selected_building


func get_selection_row() -> int:
	return _selection_row


func get_selected() -> BuildingSlot:
	return _selected_building

func _ready() -> void:
	controlling_base.team = CombatData.Team.PLAYER


func _process(_delta: float) -> void:
	_handle_building_selection()

	if Input.is_action_just_pressed("next_path"):
		controlling_base.next_path()


func _input(event: InputEvent) -> void:
	_handle_selected_building_slot(event)


func _handle_selected_building_slot(event: InputEvent) -> void:
	if not _selected_building:
		return

	if _selected_building.has_building():
		for unit in _selected_building.get_unit_options():
			if (
				unit.input_keyboard
				&& unit.input_keyboard.is_match(event)
				and event.is_pressed()
				and event.echo == false
			):
				_selected_building.queue_unit(unit)
				unit_queued.emit(unit)
				self._selection_stage = SelectionStage.NONE

		if Input.is_action_just_pressed("destroy_building"):
			action_triggered.emit("Destroy")
			_selected_building.destroy()
			self._selection_stage = SelectionStage.NONE
		return

	for building_type in controlling_base.get_building_types():
		if (
			(building_type.input_keyboard && building_type.input_keyboard.is_match(event))
			or (building_type.input_gamepad && building_type.input_gamepad.is_match(event))
		):
			building_built.emit(building_type)
			_selected_building.build(building_type)
			self._selection_stage = SelectionStage.NONE
			#print("Built building at %s" % [_selected_building])
			return


func _handle_building_selection():
	match _selection_stage:
		SelectionStage.NONE:
			if Input.is_action_just_pressed("select_slot_1"):
				_selection_row = 0
				self._selection_stage = SelectionStage.SELECTING
			if Input.is_action_just_pressed("select_slot_2"):
				_selection_row = 1
				self._selection_stage = SelectionStage.SELECTING
			if Input.is_action_just_pressed("select_slot_3"):
				_selection_row = 2
				self._selection_stage = SelectionStage.SELECTING
		SelectionStage.SELECTING:
			if Input.is_action_just_pressed("select_slot_1"):
				_selection_stage = SelectionStage.NONE
				_selected_building = controlling_base.get_build_slot(_selection_row, 0)
			if Input.is_action_just_pressed("select_slot_2"):
				_selection_stage = SelectionStage.NONE
				self._selected_building = controlling_base.get_build_slot(_selection_row, 1)
			if Input.is_action_just_pressed("select_slot_3"):
				_selection_stage = SelectionStage.NONE
				self._selected_building = controlling_base.get_build_slot(_selection_row, 2)
