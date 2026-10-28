@tool
class_name Trail2D extends Line2D

@export_category('Trail')
@export var length : = 10

@onready var parent : Node2D = get_parent()
var offset : = Vector2.ZERO
var active := true

func _ready() -> void:
	offset = position
	#top_level = true

func _physics_process(_delta: float) -> void:
	if !active:
		return
	global_position = Vector2.ZERO

	var point : = parent.global_position + offset
	if point.is_equal_approx(Vector2.ZERO):
		return
	add_point(point, 0)
	
	if get_point_count() > length:
		remove_point(get_point_count() - 1)
