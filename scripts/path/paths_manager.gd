class_name PathManager extends Node

# Unit Spawn
const GUN_SOLDIER = preload("uid://l0m3pssrbkug")
const UNIT_ENTITY = preload("uid://bybp5w4ae511b")
const SMALL_TANK = preload("uid://dm0mjpsku7osy")


@onready var entities: Node2D = %Entities
@onready var unit_path: UnitPath = $UnitPath
@onready var unit_path_2: UnitPath = $UnitPath2
@onready var unit_path_3: UnitPath = $UnitPath3

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		_spawn_unit(true, SMALL_TANK, CombatData.Team.PLAYER)
	elif Input.is_action_just_pressed("ui_up"):
		_spawn_unit(false, GUN_SOLDIER, CombatData.Team.HOSTILE)
		
func _spawn_unit(player: bool, unit_type: UnitResource, team: CombatData.Team):
	var unit = UNIT_ENTITY.instantiate() as UnitEntity
	entities.add_child.call_deferred(unit)
	await unit.ready
	unit.set_unit(unit_type, unit_path, team)
