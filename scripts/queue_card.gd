class_name QueueCard
extends PanelContainer

@onready var unit_icon: TextureRect = %UnitIcon
@onready var cooldown_progress: ProgressBar = %CooldownProgress
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func setup_card(unit: UnitResource):
	unit_icon.texture = unit.button_icon
	var cooldown_tween = create_tween()
	cooldown_tween.tween_property(cooldown_progress, "value", 100, unit.time_to_build).from(0.)
	await cooldown_tween.finished
	animation_player.play("unrise")
