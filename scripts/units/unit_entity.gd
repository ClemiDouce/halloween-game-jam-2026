class_name UnitEntity extends Node2D

const MISSING_TEXTURE = preload("res://assets/art/placeholder/unit_placeholder.png")
const MAX_CONCURRENT_ENTITY_SOUNDS = 15
const DB_VOLUME_MODIFIER = -8.

@onready var attack_area: Area2D = %AttackArea
@onready var attack_shape : CollisionShape2D = %AttackShape
@onready var shape : CircleShape2D = attack_shape.shape
@onready var sprite: Sprite2D = %Sprite2D
@onready var root: Node2D = %Root
@onready var hitbox: Hitbox = %Hitbox
@onready var move_trail: Trail2D = $MoveTrail
@onready var flash_component: FlashComponent = %FlashComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var bullet_sprite: BulletAnimation = %BulletSprite

# Gatherer Sprite
@onready var gather_bolt_left: Line2D = %GatherBoltLeft
@onready var gather_bolt_right: Line2D = %GatherBoltRight
@onready var mineral_sprite: Sprite2D = %MineralSprite
@onready var bolts: Node2D = %Bolts

@export var gathering_delay := 1.2
var gathering_time := 0.

@export_category("Sounds")
@export var sounds_destroyed: Array[AudioStream] = []
@export var sounds_laser_attack: Array[AudioStream] = []
@export var sounds_bullet_attack: Array[AudioStream] = []
@export var sounds_explosive_attack: Array[AudioStream] = []
var _sounds_attack: Array[AudioStream] = []

var team : CombatData.Team
var dead := false

# Unit Stats
var health : int

var unit_data : UnitResource
var path : UnitPath
var path_dir: int = 1
var path_index : int = 0

var target_position : Vector2 = Vector2.ZERO

# Attack
var attack_target : Hitbox = null
var attack_timer : float = 0.
var attacks_ground: bool = false

# Animation
var _animation_timer: float = 0.
var _atlas: AtlasTexture = null

enum UnitState {IDLE, MOVING, ATTACKING, GATHERING}
var state : UnitState = UnitState.MOVING
var have_mineral := false

var is_gather_unit: bool: 
	get(): return unit_data.damage_type == CombatData.DamageType.EXPLOIT

func set_unit(unit: UnitResource, _path: UnitPath, _team: CombatData.Team):
	unit_data = unit
	health = unit.health
	shape.radius = unit.attack_range
	team = _team
	bullet_sprite.texture = unit.bullet_texture
	
	if unit.shader:
		sprite.material = unit.shader
	move_trail.length = unit.trail_length

	if _team in unit.texture:
		if unit.texture[_team] is AtlasTexture:
			_atlas = unit.texture[_team].duplicate()
			sprite.texture = _atlas
		else:
			sprite.texture = unit.texture[_team]
	else:
		sprite.texture = MISSING_TEXTURE

	match unit.damage_type:
		CombatData.DamageType.BULLET:
			_sounds_attack = sounds_bullet_attack
		CombatData.DamageType.EXPLOSIVE:
			_sounds_attack = sounds_explosive_attack
		CombatData.DamageType.LASER:
			_sounds_attack = sounds_laser_attack

	path = _path
	if team == CombatData.Team.PLAYER:
		path_dir = 1
		global_position = path.get_start_position()
		target_position = path.get_next_point(path_index, path_dir)
	elif team == CombatData.Team.HOSTILE:
		path_dir = -1
		path_index = path.end_index
		global_position = path.get_end_position()
		target_position = path.get_next_point(path_index, path_dir)
	
	match unit_data.elevation:
		CombatData.ElevationType.GROUND:
			hitbox.collision_layer = CombatData.PLAYER_COLLISION_LAYER if team == CombatData.Team.PLAYER else CombatData.HOSTILE_COLLISION_LAYER
		CombatData.ElevationType.SKY:
			self.z_index += 1
			hitbox.collision_layer = CombatData.PLAYER_COLLISION_LAYER_FLYING if team == CombatData.Team.PLAYER else CombatData.HOSTILE_COLLISION_LAYER_FLYING
	
	if is_gather_unit:
		attack_area.collision_mask = CombatData.MINERAL_COLLISION_LAYER
	else:
		match unit_data.attacks_elevation:
			CombatData.ElevationType.GROUND:
				attack_area.collision_mask = CombatData.HOSTILE_COLLISION_LAYER if team == CombatData.Team.PLAYER else CombatData.PLAYER_COLLISION_LAYER
				attacks_ground = true
			CombatData.ElevationType.SKY:
				attacks_ground = false
				attack_area.collision_mask = CombatData.HOSTILE_COLLISION_LAYER_FLYING if team == CombatData.Team.PLAYER else CombatData.PLAYER_COLLISION_LAYER_FLYING
	
	# Offset
	root.position = Vector2(
		randi_range(-10, 10),
		randi_range(-10, 10)
	)
	move_trail.offset = root.position
	var pop_tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	pop_tween.tween_property(root, "scale", Vector2(1.3,1.3), 0.2).from(Vector2(0.6, 0.4))
	pop_tween.tween_property(root, "scale", Vector2.ONE, 0.1)
	await get_tree().physics_frame
	move_trail.clear_points()
	move_trail.active = true

func _process(delta: float) -> void:
	_process_animation(delta)

func _play_sound_rand(streams: Array[AudioStream]) -> void:
	_play_sound(streams.pick_random())

func _play_sound(stream: AudioStream) -> void:
	if not stream:
		return
	if get_tree().get_node_count_in_group("unit_audio_player") >= MAX_CONCURRENT_ENTITY_SOUNDS:
		return
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.add_to_group("unit_audio_player")
	audio_player.bus = "Sound Effects"
	audio_player.stream = stream
	audio_player.volume_db += DB_VOLUME_MODIFIER
	audio_player.finished.connect(audio_player.queue_free)
	get_parent().add_child(audio_player)
	audio_player.global_position = self.global_position
	audio_player.play()

func _physics_process(delta: float) -> void:
	match(state):
		UnitState.IDLE:
			pass
		UnitState.MOVING:
			if self.global_position.is_equal_approx(target_position):
				
				if is_gather_unit and have_mineral:
					path_index -= path_dir
					target_position = path.get_next_point(path_index, path_dir)
				else:
					path_index += path_dir
					target_position = path.get_next_point(path_index, path_dir)

				if target_position == Vector2.INF:
					if is_gather_unit:
						if team == CombatData.Team.PLAYER:
							if path_index <= 0:
								have_mineral = false
								mineral_sprite.hide()
								attack_target = null
								path_index += path_dir
								target_position = path.get_next_point(path_index, path_dir)
								return
						else:
							pass

					# Turn around if unit cannot attack the base
					if not attacks_ground:
						path_dir *= -1
						target_position = path.get_next_point(path_index, path_dir)
						return
					state = UnitState.IDLE
					return



			root.rotation = lerp_angle(root.rotation, global_position.direction_to(target_position).angle(), delta * 10)
			global_position = global_position.move_toward(target_position, unit_data.speed * delta)
			
		
		UnitState.ATTACKING:
			if not is_instance_valid(attack_target):
				attack_target = null
				var hitboxes = attack_area.get_overlapping_areas()
				for hit in hitboxes:
					if is_instance_valid(hit):
						attack_target = hit
						return
				state = UnitState.MOVING
				attack_timer = 0.
			# Attack
			else:
				if self.global_position.distance_to(attack_target.global_position) > shape.radius - (unit_data.speed * delta):
					global_position = global_position.move_toward(attack_target.global_position, unit_data.speed * delta)
				root.rotation = lerp_angle(root.rotation, global_position.direction_to(attack_target.global_position).angle(), delta * 10)
				attack_timer += delta
				if attack_timer >= unit_data.rate_of_fire:
					attack_timer -= unit_data.rate_of_fire
					bullet_sprite.shoot(attack_target.sprite.global_position)
					attack_target.get_damage(self.unit_data)
					animation_player.play("squish")
					_play_sound_rand(_sounds_attack)
		UnitState.GATHERING:
			root.rotation = lerp_angle(root.rotation, global_position.direction_to(attack_target.global_position).angle(), delta * 10)
			gather_bolt_left.points = [Vector2.ZERO, gather_bolt_left.to_local(attack_target.global_position)]
			gather_bolt_right.points = [Vector2.ZERO, gather_bolt_right.to_local(attack_target.global_position)]
			gathering_time += delta
			if gathering_time >= gathering_delay:
				mineral_sprite.show()
				bolts.hide()
				gathering_time = 0.
				have_mineral = true
				target_position = path.get_previous_point(path_index+path_dir)
				state = UnitState.MOVING

func change_to_gathering(mineral_target: Hitbox):
	attack_target = mineral_target
	state = UnitState.GATHERING
	bolts.show()
	
	
	
func _on_attack_area_area_entered(area: Area2D) -> void:
	if area is not Hitbox:
		return
	if attack_target != null:
		return
		
	if is_gather_unit:
		change_to_gathering(area)
	else:
		attack_target = area
		state = UnitState.ATTACKING
		
	

func _process_animation(delta: float) -> void:
	if not _atlas or state != UnitState.MOVING:
		return

	if _animation_timer > 0.25:
		_animation_timer = 0.
		var frame_size := _atlas.region.size
		if _atlas.region.position.x + frame_size.x > _atlas.get_width():
			_atlas.region.position.x = 0.
		else:
			_atlas.region.position.x += frame_size.x
	else:
		_animation_timer += delta

func _on_hitbox_hurt(attacker: EntityData) -> void:
	var damage = AttackCalculator.get_attack_damage(attacker, unit_data)
	health = max(0, health - damage)
	print("%s received %s damage from %s. Current health : %s" % [unit_data.unit_name, damage, attacker.unit_name, health])
	if health <= 0:
		if dead:
			return
		dead = true
		hitbox.monitorable = false
		hitbox.monitoring = false
		death_animation()
	else:
		flash_component.flash()

func death_animation():
	animation_player.stop()
	var death_tween = create_tween()
	death_tween.tween_property(root, "scale", Vector2(1.3,1.3), 0.2)
	death_tween.tween_property(root, "rotation_degrees", 360, 0.5).as_relative().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	death_tween.parallel().tween_property(root, "scale", Vector2(0.1, 0.1), 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await death_tween.finished
	_play_sound_rand(sounds_destroyed)
	queue_free()
