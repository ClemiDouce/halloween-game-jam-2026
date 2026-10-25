class_name PathManager extends Node

const GUN_SOLDIER = preload("uid://l0m3pssrbkug")
const UNIT_ENTITY = preload("uid://bybp5w4ae511b")
@onready var entities: Node2D = %Entities
@onready var unit_path: UnitPath = $UnitPath
@onready var unit_path_2: UnitPath = $UnitPath2
@onready var unit_path_3: UnitPath = $UnitPath3

func _ready():
	# Test Unit on path
	var unit = UNIT_ENTITY.instantiate() as UnitEntity
	entities.add_child(unit)
	await unit.ready
	unit.set_unit(GUN_SOLDIER, unit_path_3, true)
