class_name UnitEntity extends Node2D

@onready var attack_area: Area2D = %AttackArea
@onready var attack_shape : CollisionShape2D = %AttackShape
@onready var shape : CircleShape2D = attack_shape.shape
@onready var sprite: Sprite2D = %Sprite2D
@onready var root: Node2D = %Root
@onready var hitbox: Hitbox = %Hitbox
@onready var move_trail: Trail2D = $MoveTrail
@onready var flash_component: FlashComponent = %FlashComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer


var team : CombatData.Team
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

func set_unit(unit: UnitResource, _path: UnitPath, _team: CombatData.Team):
	unit_data = unit
	health = unit.health
	shape.radius = unit.attack_range
	team = _team
	sprite.texture = unit.texture
	path = _path
	if team == CombatData.Team.PLAYER:
		global_position = path.get_start_position()
		target_position = path.get_next_point(path_index)
	elif team == CombatData.Team.HOSTILE:
		path_index = path.end_index
		global_position = path.get_end_position()
		target_position = path.get_previous_point(path_index)
	
	hitbox.collision_layer = CombatData.PLAYER_COLLISION_LAYER if team == CombatData.Team.PLAYER else CombatData.HOSTILE_COLLISION_LAYER
	attack_area.collision_mask = CombatData.HOSTILE_COLLISION_LAYER if team == CombatData.Team.PLAYER else CombatData.PLAYER_COLLISION_LAYER
	# Offset
	root.position = Vector2(
		randi_range(-5, 5),
		randi_range(-5, 5)
	)
	var pop_tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	pop_tween.tween_property(root, "scale", Vector2(1.3,1.3), 0.2).from(Vector2(0.6, 0.4))
	pop_tween.tween_property(root, "scale", Vector2.ONE, 0.1)
	await get_tree().physics_frame
	move_trail.clear_points()
	move_trail.active = true
	
func _physics_process(delta: float) -> void:
	match(state):
		UnitState.IDLE:
			pass
		UnitState.MOVING:
			if self.global_position.is_equal_approx(target_position):
				if team == CombatData.Team.PLAYER:
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
			else:
				root.rotation = lerp_angle(root.rotation, global_position.direction_to(attack_target.global_position).angle(), delta * 10)
				attack_timer += delta
				if attack_timer >= unit_data.rate_of_fire:
					attack_timer -= unit_data.rate_of_fire
					attack_target.get_damage(self.unit_data)
					animation_player.play("squish")
				


func _on_attack_area_area_entered(area: Area2D) -> void:
	if area is not Hitbox:
		return
	if attack_target != null:
		return
		
	attack_target = area
	state = UnitState.ATTACKING


func _on_hitbox_hurt(attacker: EntityData) -> void:
	var damage = AttackCalculator.get_attack_damage(attacker, unit_data)
	health = max(0, health - damage)
	print("%s received %s damage from %s. Current health : %s" % [unit_data.unit_name, damage, attacker.unit_name, health])
	if health <= 0:
		#TODO Death Animation
		queue_free()
	else:
		flash_component.flash()

#func _draw() -> void:
	#if target_position != Vector2.INF:
		#draw_circle(target_position, 10, Color.RED, true)
		
		
		
		
