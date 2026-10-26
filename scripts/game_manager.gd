class_name GameManager 
extends Node

@onready var foreground_layer: CanvasLayer = %ForegroundLayer
@onready var overworld: Level = %Overworld
@onready var base_manager: BaseManager = $BaseManager

func _ready():
	for base_entity in get_tree().get_nodes_in_group("base"):
		base_entity.destroyed.connect(_on_base_destroyed)
	overworld.setup_level(base_manager)
	base_manager.connect_to_level(overworld.paths, overworld.entity_parent)
	foreground_layer.fade_in()
		
		
func _on_base_destroyed(base_data: BaseData):
	if base_data.team == CombatData.Team.PLAYER:
		# LOSE!
		_on_player_loose()
	elif base_data.team == CombatData.Team.HOSTILE:
		# Check if other hostile base exist, else win
		var bases = get_tree().get_nodes_in_group("base")
		var hostiles_base = bases.filter(func(b: BaseEntity):
				return b.base_data.team == CombatData.Team.HOSTILE and b.base_data != base_data
		)
		
		if hostiles_base.size() == 0:
			# WIN !
			_on_player_win()
		else:
			print("Not Yet, %s bases remain up" % hostiles_base.size())

func _on_player_win():
	await foreground_layer.fade_out()
	get_tree().reload_current_scene()
	
func _on_player_loose():
	await foreground_layer.fade_out()
	get_tree().reload_current_scene()
