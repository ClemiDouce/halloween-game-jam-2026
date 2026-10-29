class_name GameManager 
extends Node

@onready var foreground_layer: CanvasLayer = %ForegroundLayer
@onready var base_manager: BaseManager = $BaseManager

# Level list
@export var level_list : Array[PackedScene] = []
var current_level_id : int = 0
var current_level : Level = null

# Screens
@onready var start_screen: Control = %StartScreen
@onready var win_screen: Control = %WinScreen
@onready var loose_screen: Control = %LooseScreen

func _ready():
	foreground_layer.fade_in()

func launch_level(level_index: int):
	if level_index < 0 or level_index >= level_list.size():
		return
	
	if current_level != null:
		current_level.queue_free()
	
	var level_to_load = level_list[level_index]
	current_level = level_to_load.instantiate() as Level
	add_child(current_level)
	#await current_level.ready
	current_level.setup_level()
	for base_entity in get_tree().get_nodes_in_group("base"):
		base_entity.destroyed.connect(_on_base_destroyed)
	base_manager.connect_to_level(current_level.paths, current_level.entity_parent)

#region StartState
func _on_play_button_pressed() -> void:
	launch_level(0)
	start_screen.hide()
	foreground_layer.fade_in()


func _on_quit_button_pressed() -> void:
	get_tree().quit()

#endregion

#region GameState
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
	get_tree().call_group("freed", "queue_free")
	await foreground_layer.fade_out()
	get_tree().reload_current_scene()
	#TODO: Affichage ecran de victoire
	if current_level_id + 1 >= level_list.size():
		#TODO Score de fin
		pass
	else:
		#TODO: Passage au niveau suivant
		pass
	
func _on_player_loose():
	get_tree().call_group("freed", "queue_free")
	await foreground_layer.fade_out()
	get_tree().reload_current_scene()
	#TODO: Afficher ecran de defaite
#endregion

#region WinState

#endregion

#region LooseState

#endregion
