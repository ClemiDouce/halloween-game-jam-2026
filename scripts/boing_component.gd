class_name BoingComponent
extends Node

@export var target: Node2D
var tween : Tween

func boing():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(target, "scale", Vector2(1.25,1.25), 0.125).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target, "scale", Vector2(1,1), 0.125).set_trans(Tween.TRANS_CUBIC)
