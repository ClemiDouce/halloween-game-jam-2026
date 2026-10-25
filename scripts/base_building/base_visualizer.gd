@tool
class_name BaseVisualizer
extends Node

const BUILDING_TILE_WIDTH = 64
const BUILDING_TILE_HEIGHT = 16

@export var base: BaseManager
@export var building_padding: Vector2 = Vector2(48.0, 48.0)
@export var empty_building_slot_texture: Texture2D

@export var slot_holder: Control

var _building_sprites: Array[Sprite2D] = []


func _ready() -> void:
	var center_pos: Vector2 = Vector2(slot_holder.size.x / 2, slot_holder.size.y / 2)
	for x in range(BaseManager.BUILDING_GRID_X):
		for y in range(BaseManager.BUILDING_GRID_Y):
			var sprite = Sprite2D.new()
			sprite.name = "Building (%d, %d)" % [x, y]
			sprite.texture = empty_building_slot_texture
			sprite.position = _get_world_from_grid(x, y, building_padding) + center_pos
			slot_holder.add_child(sprite)
			_building_sprites.append(sprite)

	base.slot_updated.connect(_on_slot_updated)


func _on_slot_updated(grid_x: int, grid_y: int) -> void:
	var sprite = _get_world_from_grid(grid_x, grid_y)


func _get_world_from_grid(grid_x: int, grid_y: int, padding: Vector2) -> Vector2:
	var iso_x: float = (grid_x - grid_y) * (BUILDING_TILE_WIDTH * 0.5 + padding.x)
	var iso_y: float = (grid_x + grid_y) * (BUILDING_TILE_HEIGHT * 0.5 + padding.y)
	return Vector2(iso_x, iso_y)


func _get_sprite_from_grid_pos(grid_x: int, grid_y: int) -> Sprite2D:
	return slot_holder.get_node("Building (%d, %d)" % [grid_x, grid_y])
