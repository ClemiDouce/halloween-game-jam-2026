class_name BaseEntity
extends Node2D

@onready var attack_area: Area2D = %AttackArea
@onready var attack_shape : CollisionShape2D = %AttackShape
@onready var shape : CircleShape2D = attack_shape.shape
@onready var hitbox: Hitbox = %Hitbox

@export var base_data : BaseData

signal destroyed(data: BaseData)

var health : int
var attack_target: Hitbox
var attack_timer : float = 0.

func _ready() -> void:
	set_data()

func set_data() -> void:
	health = base_data.health
	shape.radius = base_data.attack_range
	hitbox.collision_layer = CombatData.PLAYER_COLLISION_LAYER if base_data.team == CombatData.Team.PLAYER else CombatData.HOSTILE_COLLISION_LAYER
	attack_area.collision_mask = CombatData.HOSTILE_COLLISION_LAYER if base_data.team == CombatData.Team.PLAYER else CombatData.PLAYER_COLLISION_LAYER

func _on_entity_hitbox_hurt(attacker: EntityData) -> void:
	var damage = AttackCalculator.get_attack_damage(attacker, base_data)
	health = max(0, health - damage)
	print("%s received %s damage from %s. Current health : %s" % [base_data.unit_name, damage, attacker.unit_name, health])
	if health <= 0:
		#TODO Death Animation
		destroyed.emit(base_data)
		queue_free()
	else:
		#TODO Hurt Animation
		pass
	
func _process(delta: float) -> void:
	if attack_target:
		
		if not is_instance_valid(attack_target):
			attack_target = null
			var hitboxes = attack_area.get_overlapping_areas()
			if hitboxes.is_empty():
				attack_timer = 0.
			else:
				for hit in hitboxes:
					if is_instance_valid(hit):
						attack_target = hit
						return
		# Attack
		attack_timer += delta
		if attack_timer >= base_data.rate_of_fire:
			attack_timer -= base_data.rate_of_fire
			attack_target.get_damage(self.base_data)


func _on_attack_area_area_entered(area: Area2D) -> void:
	if area is not Hitbox:
		return
	
	attack_target = area as Hitbox
