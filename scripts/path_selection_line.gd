class_name PathVisualizer extends Line2D

@export var base : BaseManager

@export var min_max_width := Vector2()
@export var pulse_speed := 0.5

var pulse_tween : Tween

func _ready() -> void:
	base.path_selected.connect(setup_visualizer)

func setup_visualizer(path: UnitPath):
	clear_points()
	var point_positions = path.point_list.map(func(node: Node2D): return node.global_position)
	point_positions.resize(2)
	points = point_positions
	print(points)
	width = min_max_width.x
	start_pulsing()
	
func start_pulsing():
	if pulse_tween:
		pulse_tween.kill()
	
	pulse_tween = create_tween().set_loops()
	#pulse_tween.tween_property(self, "width", min_max_width.y, pulse_speed)
	#pulse_tween.tween_property(self, "width", min_max_width.x, pulse_speed)
	pulse_tween.tween_method(_ceiled_width, min_max_width.x, min_max_width.y, 1.)
	pulse_tween.tween_method(_ceiled_width, min_max_width.y, min_max_width.x, 1.)

func _ceiled_width(value: float):
	width = ceili(value)
