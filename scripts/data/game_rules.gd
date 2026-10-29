class_name GameRules
extends Resource

@export var enabled_buildings: Array[Building] = [
	preload("res://data/buildings/tank_factory.tres"),
	preload("res://data/buildings/infantry_barracks.tres"),
	preload("res://data/buildings/airport.tres"),
	preload("res://data/buildings/requisition_center.tres")
]

@export var disabled_units: Array[UnitResource] = []
