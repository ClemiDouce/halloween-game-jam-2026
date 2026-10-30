class_name Level 
extends Node2D

@export var paths: Array[UnitPath] = []
@export var entity_parent: Node2D

@export var ai_list : Array[BaseManager]
@export var game_rules: GameRules
@export var music_track: String = ""

func _ready() -> void:
	# Use default rules
	if not game_rules:
		game_rules = GameRules.new()

	if music_track != "":
		get_tree().root.get_node("GameManager/MusicPlayer").get_stream_playback().switch_to_clip_by_name(music_track)


func setup_level():
	for ai : BaseManager in ai_list:
		ai.connect_to_level(paths, entity_parent)

func start_level():
	var controllers = get_tree().get_nodes_in_group("hostile")
	for ai in controllers:
		if ai is AIController:
			ai.start_controller()
