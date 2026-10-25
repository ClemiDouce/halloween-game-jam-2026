class_name UnitEntity extends Node2D

@onready var collision_shape : CollisionShape2D = %CollisionShape2D
@onready var shape : CircleShape2D = collision_shape.shape
@onready var sprite: Sprite2D = %Sprite2D

var unit_data : UnitResource
var path : Array[Vector2]
var move_speed : float

enum UnitState {POOLED, MOVING, ATTACKING}
var state : UnitState

func set_unit(unit: UnitResource, _path: Array[Vector2], _pooled: bool = false):
	unit_data = unit
	move_speed = unit.speed
	shape.radius = unit.attack_range
	sprite.texture = unit.texture
	path = _path
	state = UnitState.POOLED if _pooled else UnitState.MOVING
	
func _physics_process(_delta: float) -> void:
