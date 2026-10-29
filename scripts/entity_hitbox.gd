class_name Hitbox extends Area2D

@onready var collision_shape : CollisionShape2D = %CollisionShape2D
@onready var shape : CircleShape2D = collision_shape.shape
@export var sprite : Sprite2D
@export var elevation: CombatData.ElevationType

signal hurt(attacker: EntityData)
	
func get_damage(attacker: EntityData) -> void:
	hurt.emit(attacker)
