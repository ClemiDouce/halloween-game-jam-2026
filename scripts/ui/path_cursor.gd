extends Sprite2D

@export var base_manager: BaseManager

func _ready() -> void:
	base_manager.path_selected.connect(func(path: UnitPath):
		self.global_position = path.point_list[0].global_position.lerp(path.point_list[1].global_position, 0.25)
	)
