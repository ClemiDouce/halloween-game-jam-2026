class_name PlayerController
extends Node

@export var controlling_base: BaseManager

signal building_selected(building: BuildingSlot, pos: Vector2i)
signal selection_stage_changed(stage: SelectionStage)

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


func _process(_delta: float) -> void:
	_handle_building_selection()


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
