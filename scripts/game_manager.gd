class_name GameManager 
extends Node

signal fade_in
signal fade_out

@onready var foreground_layer: CanvasLayer = %ForegroundLayer
@onready var base_manager: BaseManager = $BaseManager
@onready var music_player: AudioStreamPlayer = %MusicPlayer
@onready var player_controller: PlayerController = %PlayerController
@onready var base_view: CanvasLayer = %BaseView
@onready var path_visualizer: PathVisualizer = %PathVisualizer

# Level list
@export var level_list : Array[PackedScene] = []
var current_level_id : int = 0
var current_level : Level = null

# Screens
@onready var start_screen: Control = %StartScreen
@onready var win_screen: Control = %WinScreen
@onready var loose_screen: Control = %LooseScreen
@onready var next_level_screen: Control = %NextLevelScreen
@onready var pause_screen: Control = %PauseScreen

# Demo level
@export var demo_scene : PackedScene
var is_demo := false

@export_category("Focus")
@export var main_menu_focus: Control
@export var next_level_focus: Control
@export var win_screen_focus: Control
@export var loose_screen_focus: Control
@export var pause_screen_focus: Control

var _paused: bool = false

func _ready():
	foreground_layer.faded_in.connect(fade_in.emit)
	foreground_layer.faded_out.connect(fade_out.emit)
	
	spawn_demo_level()
	main_menu_focus.grab_focus()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if Input.is_action_just_pressed("ui_cancel"):
		if not next_level_screen.visible and not win_screen.visible and not loose_screen.visible and not start_screen.visible:
			toggle_paused()

func launch_level(level_index: int):
	if level_index < 0 or level_index >= level_list.size():
		return
	_unpause()
	
	await foreground_layer.fade_out()
	if current_level != null:
		current_level.queue_free()
		
	is_demo = false
	var level_to_load = level_list[level_index]
	current_level = level_to_load.instantiate() as Level
	add_child(current_level)
	#await current_level.ready
	current_level.setup_level()
	player_controller.clear_player_base()
	foreground_layer.fade_in()
	for base_entity in get_tree().get_nodes_in_group("base"):
		base_entity.destroyed.connect(_on_base_destroyed)
	base_manager.connect_to_level(current_level.paths, current_level.entity_parent)
	base_manager.set_game_rules(current_level.game_rules)

#region StartState
func spawn_demo_level():
	is_demo = true
	if current_level != null:
		await foreground_layer.fade_out()
		current_level.queue_free()
	var demo_instance = demo_scene.instantiate()
	current_level = demo_instance
	base_view.hide()
	add_child(demo_instance)
	for base_entity in get_tree().get_nodes_in_group("base"):
		base_entity.destroyed.connect(_on_base_destroyed)
	current_level.start_level()
	await foreground_layer.fade_in()
	

func _on_play_button_pressed() -> void:
	await launch_level(0)
	start_screen.hide()
	base_view.show()
	music_player.get_stream_playback().switch_to_clip_by_name("Game Loop")
	player_controller.start_level()
	foreground_layer.fade_in()


func _on_quit_button_pressed() -> void:
	get_tree().quit()

#endregion

#region GameState
func _on_base_destroyed(base_data: BaseData):
	if is_demo:
		spawn_demo_level()
		return
	if base_data.team == CombatData.Team.PLAYER:
		# LOSE!
		_on_player_loose()
		current_level.stop()
	elif base_data.team == CombatData.Team.HOSTILE:
		# Check if other hostile base exist, else win
		var bases = get_tree().get_nodes_in_group("base")
		var hostiles_base = bases.filter(func(b: BaseEntity):
				return b.base_data.team == CombatData.Team.HOSTILE and b.base_data != base_data
		)
		
		if hostiles_base.size() == 0:
			# WIN !
			_on_player_win()
			current_level.stop()
		else:
			pass
			#print("Not Yet, %s bases remain up" % hostiles_base.size())

func _on_player_win():
	clean_level()
	#TODO: Affichage ecran de victoire
	if current_level_id + 1 >= level_list.size():
		#TODO Score de fin
		_pause()
		win_screen.show()
		win_screen_focus.grab_focus()
	else:
		#TODO: Passage au niveau suivant
		_pause()
		next_level_screen.show()
		next_level_focus.grab_focus()
	
func _on_player_loose():
	clean_level()
	_pause()
	loose_screen.show()
	loose_screen_focus.grab_focus()
	
func clean_level():
	get_tree().call_group("freed", "death")
#endregion

#region WinState

#endregion

#region LooseState

#endregion


func toggle_paused() -> void:
	_paused = not _paused
	if _paused:
		_pause()
		pause_screen.show()
		pause_screen_focus.grab_focus()
	else:
		_unpause()

func _unpause() -> void:
	_paused = false
	get_tree().paused = false
	pause_screen.hide()

func _pause() -> void:
	get_tree().paused = true

func _on_back_menu_button_pressed() -> void:
	_unpause()
	path_visualizer.clear()
	next_level_screen.hide()
	win_screen.hide()
	loose_screen.hide()
	music_player.get_stream_playback().switch_to_clip_by_name("Intro Loop")
	spawn_demo_level()
	await fade_out
	player_controller.active = false
	start_screen.show()
	main_menu_focus.grab_focus()

func _on_try_again_button_pressed() -> void:
	launch_level(current_level_id)
	loose_screen.hide()


func _on_next_level_button_pressed() -> void:
	current_level_id += 1
	next_level_screen.hide()
	launch_level(current_level_id)
