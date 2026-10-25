class_name UnitEntity extends Node2D

@onready var attack_area: Area2D = %AttackArea
@onready var attack_shape : CollisionShape2D = %AttackShape
@onready var shape : CircleShape2D = attack_shape.shape
@onready var sprite: Sprite2D = %Sprite2D
@onready var root: Node2D = %Root
@onready var hitbox: Hitbox = %Hitbox

const PLAYER_COLLISION_LAYER = 16
const HOSTILE_COLLISION_LAYER = 32


var is_player: bool
# Unit Stats
var health : int

var unit_data : UnitResource
var path : UnitPath
var path_index : int = 0
var target_position : Vector2 = Vector2.ZERO

# Attack
var attack_target : Hitbox = null
var attack_timer : float = 0.


enum UnitState {IDLE, MOVING, ATTACKING}
var state : UnitState = UnitState.MOVING

func set_unit(unit: UnitResource, _path: UnitPath, _player_team: bool):
	unit_data = unit
	#shape.radius = unit.attack_range
	is_player = _player_team
	sprite.texture = unit.texture
	path = _path
	if is_player:
		global_position = path.get_start_position()
		target_position = path.get_next_point(path_index)
	else:
		path_index = path.end_index
		global_position = path.get_end_position()
		target_position = path.get_previous_point(path_index)
	
	hitbox.collision_layer = PLAYER_COLLISION_LAYER if _player_team else HOSTILE_COLLISION_LAYER
	attack_area.collision_mask = HOSTILE_COLLISION_LAYER if _player_team else PLAYER_COLLISION_LAYER
	
func _physics_process(delta: float) -> void:
	match(state):
		UnitState.IDLE:
			pass
		UnitState.MOVING:
			if self.global_position.is_equal_approx(target_position):
				if is_player:
					path_index += 1
					target_position = path.get_next_point(path_index)
				else:
					path_index -= 1
					target_position = path.get_previous_point(path_index)
				if target_position == Vector2.INF:
					state = UnitState.IDLE
					return
			root.rotation = lerp_angle(root.rotation, global_position.direction_to(target_position).angle(), delta * 10)
			global_position = global_position.move_toward(target_position, unit_data.speed * delta)
			
		
		UnitState.ATTACKING:
			if not is_instance_valid(attack_target):
				attack_target = null
				var hitboxes = attack_area.get_overlapping_areas()
				if hitboxes.is_empty():
					state = UnitState.MOVING
					attack_timer = 0.
				else:
					for hit in hitboxes:
						if is_instance_valid(hit):
							attack_target = hit
							return
			# Attack
			attack_timer += delta
			if attack_timer >= unit_data.rate_of_fire:
				attack_timer -= unit_data.rate_of_fire
				attack_target.get_damage(unit_data.damage)


func _on_attack_area_area_entered(area: Area2D) -> void:
	if area is not Hitbox:
		return
	if attack_target != null:
		return
		
	attack_target = area
	state = UnitState.ATTACKING


func _on_hitbox_hurt(value: int) -> void:
	health -= max(0, health - value)
	if health == 0:
		#TODO Death Animation
		queue_free()
	else:
		#TODO Hurt Animation
		pass

#func _draw() -> void:
	#if target_position != Vector2.INF:
		#draw_circle(target_position, 10, Color.RED, true)
		
		
		
		
