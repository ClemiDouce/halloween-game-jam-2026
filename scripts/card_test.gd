class_name QueueVisualizer 
extends Control

@export var base_manager: BaseManager

const QUEUE_CARD = preload("uid://d36fo5kwwpef4")
@onready var card_container: HFlowContainer = %CardContainer

func _ready() -> void:
	if is_instance_valid(base_manager):
		base_manager.unit_queue.unit_queued.connect(_add_card)

#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#_add_card()

func _add_card(unit: UnitResource):
	var new_card = QUEUE_CARD.instantiate() as QueueCard
	card_container.add_child(new_card)
	new_card.setup_card(unit)
	if card_container.get_child_count() > 20:
		card_container.
	
