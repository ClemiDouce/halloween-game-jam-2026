class_name UnitEntity extends Node2D

@onready var attack_area: Area2D = %AttackArea
@onready var collision_shape : CollisionShape2D = %CollisionShape2D
@onready var shape : CircleShape2D = collision_shape.shape
@onready var sprite: Sprite2D = %Sprite2D
@onready var root: Node2D = %Root

const PLAYER_COLLISION_LAYER = 16
const HOSTILE_COLLISION_LAYER = 32

# Unit Stats
var health : int
var move_speed : float

var unit_data : UnitResource
var path : UnitPath
var path_index : int = 0
var target_position : Vector2 = Vector2.ZERO


var attack_target : UnitEntity = null

enum UnitState {IDLE, MOVING, ATTACKING}
var state : UnitState = UnitState.MOVING

func set_unit(unit: UnitResource, _path: UnitPath, _player_team: bool):
	unit_data = unit
	move_speed = unit.speed
	#shape.radius = unit.attack_range
	sprite.texture = unit.texture
	path = _path
	global_position = path.get_start_position()
	target_position = path.get_next_point(path_index)
	attack_area.collision_layer = PLAYER_COLLISION_LAYER if _player_team else HOSTILE_COLLISION_LAYER
	attack_area.collision_mask = HOSTILE_COLLISION_LAYER if _player_team else PLAYER_COLLISION_LAYER
	
func _physics_process(delta: float) -> void:
	match(state):
		UnitState.IDLE:
			pass
		UnitState.MOVING:
			if self.global_position.is_equal_approx(target_position):
				path_index += 1
				target_position = path.get_next_point(path_index)
				if target_position == Vector2.INF:
					state = UnitState.IDLE
					return
			root.rotation = lerp_angle(root.rotation, global_position.direction_to(target_position).angle(), delta * 10)
			global_position = global_position.move_toward(target_position, move_speed * delta)
			
		
		UnitState.ATTACKING:
			if attack_target.health <= 0:
				attack_target = null
				state = UnitState.MOVING


func _on_attack_area_area_entered(area: Area2D) -> void:
	attack_target = area.get_parent()
	state = UnitState.ATTACKING
