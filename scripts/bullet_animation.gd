class_name BulletAnimation extends Sprite2D

func shoot(target_pos: Vector2):
	look_at(target_pos)
	show()
	var shoot_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	shoot_tween.tween_property(self, "global_position", target_pos, 0.1).from(get_parent().global_position)
	await shoot_tween.finished
	hide()
	position = Vector2.ZERO
