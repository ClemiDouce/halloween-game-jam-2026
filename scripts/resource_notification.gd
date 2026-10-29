class_name ResourceNotification 
extends Label

var slide_tween : Tween
var default_position : Vector2

func _ready() -> void:
	default_position = position
	hide()

func play_notification(value: int):
	text = str(value)
	if slide_tween:
		slide_tween.kill()
	
	show()
	slide_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	slide_tween.tween_property(self, "position:y", -30, 0.2).as_relative().from(default_position.y)
	slide_tween.tween_callback(func(): hide())
