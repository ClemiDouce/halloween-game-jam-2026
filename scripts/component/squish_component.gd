class_name SquishComponent extends Node

@export var target : Node2D

var base_scale : Vector2
@export var squish_scale : Vector2

func squish():
	base_scale = target.scale
	var squish_tween = create_tween()
	squish_tween.tween_property(target, "scale:x", squish_scale.x, 0.1)
	squish_tween.parallel().tween_property(target, "scale:y", squish_scale.y, 0.05)
	squish_tween.tween_property(target, "scale", base_scale, 0.1)
