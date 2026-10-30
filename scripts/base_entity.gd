class_name BaseEntity
extends Node2D

@onready var attack_area: Area2D = %AttackArea
@onready var attack_shape : CollisionShape2D = %AttackShape
@onready var shape : CircleShape2D = attack_shape.shape
@onready var hitbox: Hitbox = %Hitbox
@onready var flash_component: FlashComponent = %FlashComponent
@onready var boing_component: BoingComponent = %BoingComponent

@export var base_data : BaseData
@export var texture: Dictionary[CombatData.Team, Texture]
@export_category("Sounds")
@export var sound_destroyed: Array[AudioStream] = []

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
	if base_data.team in texture:
		$Sprite2D.texture = texture[base_data.team]

func _play_sound_rand(streams: Array[AudioStream]) -> void:
	_play_sound(streams.pick_random())

func _play_sound(stream: AudioStream) -> void:
	if not stream:
		return

	var audio_player = AudioStreamPlayer2D.new()
	audio_player.add_to_group("unit_audio_player")
	audio_player.bus = "Sound Effects"
	audio_player.stream = stream
	audio_player.finished.connect(audio_player.queue_free)
	get_parent().add_child(audio_player)
	audio_player.global_position = self.global_position
	audio_player.play()

func _on_entity_hitbox_hurt(attacker: EntityData) -> void:
	var damage = AttackCalculator.get_attack_damage(attacker, base_data)
	health = max(0, health - damage)
	#print("%s received %s damage from %s. Current health : %s" % [base_data.unit_name, damage, attacker.unit_name, health])
	if health <= 0:
		#TODO Death Animation
		destroyed.emit(base_data)
		_play_sound_rand(sound_destroyed)
		queue_free()
	else:
		flash_component.flash()
		boing_component.boing()
	
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
