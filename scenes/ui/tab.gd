extends Sprite2D

var tween: Tween

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("next_path"):
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.25,1.25), 0.125).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "scale", Vector2(1,1), 0.125).set_trans(Tween.TRANS_CUBIC)
