@tool
class_name BaseVisualizer
extends Node

const BUILDING_TILE_WIDTH = 64
const BUILDING_TILE_HEIGHT = 16

@export var player: PlayerController
@export var building_padding: Vector2 = Vector2(48.0, 48.0)
@export var empty_building_slot_texture: Texture2D
@export var selection_cursor_texture: Texture2D

@export var slot_holder: Control
@export var selection_line: Line2D

@export var axis_label_textures: Array[Texture2D] = []
@export var axis_label_active_textures: Array[Texture2D] = []
var _x_axis_sprites: Array[Sprite2D] = []
var _y_axis_sprites: Array[Sprite2D] = []

var _building_sprites: Array[Sprite2D] = []
var _cursor: Sprite2D = null
var _origin: Vector2


func _get_base() -> BaseManager:
	return player.controlling_base


func _ready() -> void:
	_cursor = Sprite2D.new()
	_cursor.name = "Cursor"
	_cursor.texture = selection_cursor_texture
	_cursor.z_index = -1
	slot_holder.add_child(_cursor)
	_cursor.hide()

	_origin = Vector2(slot_holder.size.x / 2, slot_holder.size.y / 2)
	for x in range(BaseManager.BUILDING_GRID_X):
		for y in range(BaseManager.BUILDING_GRID_Y):
			var sprite = Sprite2D.new()
			sprite.name = "Building (%d, %d)" % [x, y]
			sprite.texture = empty_building_slot_texture
			sprite.position = _get_world_from_grid(x, y, building_padding) + _origin
			slot_holder.add_child(sprite)
			_building_sprites.append(sprite)

	_generate_label_sprites()
	_get_base().slot_updated.connect(_on_slot_updated)
	player.building_selected.connect(_on_building_selected)
	player.selection_stage_changed.connect(_on_selection_stage_changed)


func _on_selection_stage_changed(stage: PlayerController.SelectionStage) -> void:
	if stage == PlayerController.SelectionStage.SELECTING:
		selection_line.show()
		var row = player.get_selection_row()
		var first_pos = _get_world_from_grid(row, 0, building_padding)
		var last_pos = _get_world_from_grid(row, 2, building_padding)
		selection_line.position = _origin
		selection_line.points = [first_pos, last_pos]

		for i in range(_x_axis_sprites.size()):
			if i == row:
				_x_axis_sprites[i].texture = axis_label_active_textures[i]
			else:
				_x_axis_sprites[i].texture = axis_label_textures[i]
	else:
		selection_line.hide()
		for i in range(_x_axis_sprites.size()):
			_x_axis_sprites[i].texture = axis_label_textures[i]


func _on_building_selected(_slot: BuildingSlot, grid_pos: Vector2i) -> void:
	print("Selected %s" % [grid_pos])
	_cursor.position = _get_world_from_grid(grid_pos.x, grid_pos.y, building_padding) + _origin
	_cursor.show()


func _on_slot_updated(slot: BuildingSlot) -> void:
	var slot_pos = _get_base().get_grid_pos(slot)
	var sprite = _get_sprite_from_grid_pos(slot_pos.x, slot_pos.y)
	if slot.has_building():
		sprite.texture = slot.get_texture()
	else:
		sprite.texture = empty_building_slot_texture


func _get_world_from_grid(grid_x: int, grid_y: int, padding: Vector2) -> Vector2:
	var iso_x: float = (grid_x - grid_y) * (BUILDING_TILE_WIDTH * 0.5 + padding.x)
	var iso_y: float = (grid_x + grid_y) * (BUILDING_TILE_HEIGHT * 0.5 + padding.y)
	return Vector2(iso_x, iso_y)


func _get_sprite_from_grid_pos(grid_x: int, grid_y: int) -> Sprite2D:
	return slot_holder.get_node("Building (%d, %d)" % [grid_x, grid_y])


func _generate_label_sprites() -> void:
	for i in range(axis_label_textures.size()):
		var x_sprite := Sprite2D.new()
		x_sprite.name = "XLabel%d" % i
		x_sprite.texture = axis_label_textures[i]
		x_sprite.position = (_get_world_from_grid(i, -1, building_padding) + _origin)
		slot_holder.add_child(x_sprite)
		_x_axis_sprites.append(x_sprite)

		var y_sprite := Sprite2D.new()
		y_sprite.name = "YLabel%d" % i
		y_sprite.texture = axis_label_textures[i]
		y_sprite.position = (_get_world_from_grid(-1, i, building_padding) + _origin)
		slot_holder.add_child(y_sprite)
		_y_axis_sprites.append(y_sprite)
