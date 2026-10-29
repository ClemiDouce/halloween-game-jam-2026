class_name PlayerResourcesVisualizer
extends Control

@onready var requisition_container: VBoxContainer = %RequisitionContainer
@onready var crystal_container: VBoxContainer = %CrystalContainer
@onready var requisition_amount_label: Label = %RequisitionAmountLabel
@onready var crystal_amount_label: Label = %CrystalAmountLabel
@onready var crystal_notification: ResourceNotification = %CrystalNotification
@onready var requisition_notification: ResourceNotification = %RequisitionNotification

func _ready() -> void:
	PlayerResources.crystal_updated.connect(_on_crystal_updated)
	PlayerResources.requisition_updated.connect(_on_requisition_updated)
	
func _on_requisition_updated(new_value: int, diff: int):
	requisition_amount_label.text = str(new_value)
	requisition_notification.play_notification(diff)
	
func _on_crystal_updated(new_value: int, diff: int):
	crystal_amount_label.text = str(new_value)
	crystal_notification.play_notification(diff)
	
