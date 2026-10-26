class_name Hitbox extends Area2D

@onready var collision_shape : CollisionShape2D = %CollisionShape2D
@onready var shape : CircleShape2D = collision_shape.shape

signal hurt(value: int)

func set_radius(new_radius: float) -> void:
	shape.radius = new_radius
	
func get_damage(attacker: UnitResource) -> void:
	hurt.emit(attacker)
