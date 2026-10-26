class_name PathManager extends Node

#
#@onready var entities: Node2D = %Entities
#@onready var unit_path: UnitPath = $UnitPath
#@onready var unit_path_2: UnitPath = $UnitPath2
#@onready var unit_path_3: UnitPath = $UnitPath3
#
#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("ui_down"):
		#_spawn_unit(true)
	#elif Input.is_action_just_pressed("ui_up"):
		#_spawn_unit(false)
		#
#func _spawn_unit(player: bool):
	#var unit = UNIT_ENTITY.instantiate() as UnitEntity
	#entities.add_child.call_deferred(unit)
	#await unit.ready
	#unit.set_unit(GUN_SOLDIER, unit_path, player)
