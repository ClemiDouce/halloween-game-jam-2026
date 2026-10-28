@tool
class_name BaseVisualizer
extends Node

signal building_selected(building: Building)

const BUILDING_TILE_WIDTH = 64
const BUILDING_TILE_HEIGHT = 16

@export var player: PlayerController
@export var building_padding: Vector2 = Vector2(48.0, 48.0)
@export var empty_building_slot_texture: Texture2D
@export var selection_cursor_texture: Texture2D

@export var slot_holder: Control
@export var selection_line: Line2D

@export var axis_label_textures: Array[Texture2D] = []
@export var y_axis_label_textures: Array[Texture2D] = []

@export_category("Tilemap")
@export var base_tilemap: TileMapLayer
@export var base_center_tile: Vector2i = Vector2i(2, 12)

@export_category("UI Buttons")
@export var button_holder: GridContainer
@export var button_template: PackedScene
@export var button_grid_size: Vector2i = Vector2i(3,3)

var _x_axis_sprites: Array[Sprite2D] = []
var _y_axis_sprites: Array[Sprite2D] = []

var _building_sprites: Array[Sprite2D] = []
var _cursor: Sprite2D = null
var _selected_sprite: Sprite2D = null
var _building_scale: Vector2
var _hotkey_buttons: Array[HotkeyButton] = []

# Tweens
var _cursor_tween: Tween

func _get_base() -> BaseManager:
	return player.controlling_base


func _ready() -> void:
	_cursor = Sprite2D.new()
	_cursor.name = "Cursor"
	_cursor.texture = selection_cursor_texture
	_cursor.z_index = 31
	slot_holder.add_child(_cursor)
	_cursor.hide()

	for x in range(BaseManager.BUILDING_GRID_X):
		for y in range(BaseManager.BUILDING_GRID_Y):
			var sprite = Sprite2D.new()
			sprite.name = "Building (%d, %d)" % [x, y]
			sprite.texture = empty_building_slot_texture
			sprite.scale = base_tilemap.scale
			_building_scale = sprite.scale
			sprite.offset.y = -16
			sprite.z_index = 32
			sprite.position = _get_building_slot_pos(x, y)
			slot_holder.add_child(sprite)
			_building_sprites.append(sprite)

	_generate_label_sprites()
	_generate_hotkey_buttons()
	_get_base().slot_updated.connect(_on_slot_updated)
	player.building_selected.connect(_on_building_selected)
	player.selection_stage_changed.connect(_on_selection_stage_changed)
	player.building_built.connect(func(building: Building):
		for button in _hotkey_buttons:
			if button.assigned_data == building:
				button.create_ghost()
				break
	)
	player.unit_queued.connect(func(unit: UnitResource):
		for button in _hotkey_buttons:
			if button.assigned_data == unit:
				button.create_ghost()
				
				var tween = create_tween()
				tween.tween_property(_selected_sprite, "scale", _building_scale * 1.05, 0.125/2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(_selected_sprite, "scale", _building_scale, 0.125/2.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
				break
	)
	player.action_triggered.connect(func(action_name: String):
		for button in _hotkey_buttons:
			if button.assigned_data is String and button.assigned_data == action_name:
				button.create_ghost()
				break
	)


func _on_selection_stage_changed(stage: PlayerController.SelectionStage) -> void:
	if stage == PlayerController.SelectionStage.SELECTING:
		selection_line.show()
		var row = player.get_selection_row()
		var first_pos = _get_building_slot_pos(row, 0)
		var last_pos = _get_building_slot_pos(row, 2)
		selection_line.points = [first_pos, last_pos]

		for i in range(_x_axis_sprites.size()):
			_x_axis_sprites[i].hide()
		for i in range(_y_axis_sprites.size()):
			_y_axis_sprites[i].position = _get_building_slot_pos(player.get_selection_row(), i)
			_y_axis_sprites[i].show()
	else:
		selection_line.hide()
		for i in range(_x_axis_sprites.size()):
			_x_axis_sprites[i].show()
		for i in range(_y_axis_sprites.size()):
			_y_axis_sprites[i].hide()


func _on_building_selected(_slot: BuildingSlot, grid_pos: Vector2i) -> void:
	print("Selected %s" % [grid_pos])
	if _cursor_tween:
		_cursor_tween.kill()
	
	if _cursor.visible:
		_cursor_tween = create_tween()
		_cursor_tween.tween_property(
			_cursor,
			"position",
			_get_building_slot_pos(grid_pos.x, grid_pos.y),
			0.125
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		_cursor_tween.parallel().tween_property(_cursor, "scale", Vector2(0.5, 0.5), 0.125/2.).set_ease(Tween.EASE_OUT)
		_cursor_tween.tween_property(_cursor, "scale", Vector2(1., 1.), 0.125/2.).set_trans(Tween.TRANS_BOUNCE)
	else:
		_cursor.position = _get_building_slot_pos(grid_pos.x, grid_pos.y)
		_cursor.show()
	_selected_sprite = _get_sprite_from_grid_pos(grid_pos.x, grid_pos.y)
	building_selected.emit(_slot._building)
	
	_update_hotkey_buttons(_slot)


func _on_slot_updated(slot: BuildingSlot) -> void:
	var slot_pos = _get_base().get_grid_pos(slot)
	var sprite = _get_sprite_from_grid_pos(slot_pos.x, slot_pos.y)
	if slot.has_building() and sprite.texture != slot.get_texture():
		var original_scale = sprite.scale
		sprite.scale = Vector2(0,0)
		sprite.texture = slot.get_texture()
		var tween = create_tween()
		tween.tween_property(sprite, "scale", original_scale + Vector2(0.1,0.1), 0.125).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "scale", original_scale, 0.125/2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	else:
		sprite.texture = empty_building_slot_texture

	if player.get_selected() == slot:
		_update_hotkey_buttons(slot)
		building_selected.emit(slot._building)


func _get_building_slot_pos(grid_x: float, grid_y: float) -> Vector2:
	grid_x = (grid_x - 0.5 ) * 2
	grid_y = (grid_y - 0.5) * 2
	return base_tilemap.map_to_local(Vector2i(grid_x, grid_y) + base_center_tile - Vector2i(1,1)) * base_tilemap.scale


func _get_world_from_grid(grid_x: float, grid_y: float) -> Vector2:
	return base_tilemap.map_to_local(Vector2i(grid_x, grid_y) + base_center_tile - Vector2i(1,1)) * base_tilemap.scale


func _get_sprite_from_grid_pos(grid_x: int, grid_y: int) -> Sprite2D:
	return slot_holder.get_node("Building (%d, %d)" % [grid_x, grid_y])

func _generate_hotkey_buttons() -> void:
	button_holder.columns = button_grid_size.x
	for x in range(button_grid_size.x):
		for y in range(button_grid_size.y):
			var hotkey_button: HotkeyButton = button_template.instantiate()
			_hotkey_buttons.append(hotkey_button)
			button_holder.add_child(hotkey_button)

func _update_hotkey_buttons(slot: BuildingSlot) -> void:
	for button in _hotkey_buttons:
		button.clear()
	
	if slot.has_building():
		var unit_options := slot.get_unit_options()
		for i in range(unit_options.size()):
			_hotkey_buttons[i].assign_unit(unit_options[i])
		
		for action in InputMap.action_get_events("destroy_building"):
			if action is InputEventKey:
				_hotkey_buttons[_hotkey_buttons.size() - 1].assign_action(
					action.as_text_physical_keycode(), "Destroy",
					preload("res://assets/art/icons/destroy_icon.png")
				)
				break
	else:
		var building_types = _get_base().get_building_types()
		for i in range(building_types.size()):
			_hotkey_buttons[i].assign_building(building_types[i])

func _generate_label_sprites() -> void:
	var offset: Vector2 = Vector2(0, -64)
	
	for i in range(axis_label_textures.size()):
		var x_sprite := Sprite2D.new()
		x_sprite.name = "XLabel%d" % i
		x_sprite.texture = axis_label_textures[i]
		x_sprite.position = (_get_building_slot_pos(i, 0))
		x_sprite.z_index = 30
		x_sprite.scale *= 2
		slot_holder.add_child(x_sprite)
		_x_axis_sprites.append(x_sprite)

		var y_sprite := Sprite2D.new()
		y_sprite.name = "YLabel%d" % i
		y_sprite.texture = y_axis_label_textures[i]
		y_sprite.position = (_get_building_slot_pos(0, i)) + offset
		y_sprite.z_index = 64
		y_sprite.scale *= 2
		y_sprite.hide()
		slot_holder.add_child(y_sprite)
		_y_axis_sprites.append(y_sprite)
