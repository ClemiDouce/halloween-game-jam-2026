class_name QueueVisualizer 
extends Control

@export var base_manager: BaseManager

const QUEUE_CARD = preload("uid://d36fo5kwwpef4")
@onready var card_container: HFlowContainer = %CardContainer

func _ready() -> void:
	if is_instance_valid(base_manager):
		base_manager.unit_queue.unit_queued.connect(_add_card)


func _add_card(unit: UnitResource):
	var new_card = QUEUE_CARD.instantiate() as QueueCard
	card_container.add_child(new_card)
	new_card.setup_card(unit)
	if card_container.get_child_count() > 20:
		card_container.add_theme_constant_override("h_separation", -6)
	else:
		card_container.add_theme_constant_override("h_separation", 2)
	
