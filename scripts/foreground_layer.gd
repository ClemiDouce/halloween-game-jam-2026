extends CanvasLayer

signal faded_out
signal faded_in

@onready var fade_rect: ColorRect = $FadeRect

#region Fade in / out
func fade_out():
	var fade_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(fade_rect, "color:a", 1, 2.).from(0.)
	await fade_tween.finished
	faded_out.emit()
	
func fade_in():
	var fade_tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(fade_rect, "color:a", 0, 2.).from(1.)
	await fade_tween.finished
	faded_in.emit()
#endregion
