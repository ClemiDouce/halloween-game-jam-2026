class_name PathCursor extends Sprite2D

func on_path_selected(path: UnitPath):
	self.global_position = path.point_list[0].global_position.lerp(path.point_list[1].global_position, 0.25)
