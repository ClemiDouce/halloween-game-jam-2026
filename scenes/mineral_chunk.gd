class_name ResourceChunk 
extends Sprite2D

@onready var resource_sprite: Sprite2D = %ResourceSprite
@onready var entity_hitbox: Hitbox = $EntityHitbox

@export var capacity : int = 1
var boing_tween : Tween

func get_gathered():
	if capacity <= 0:
		return
	boing()
	capacity -= 1
	if capacity <= 0:
		entity_hitbox.monitorable = false
	
func boing():
	if boing_tween:
			boing_tween.kill()
	boing_tween = create_tween()
	boing_tween.tween_property(resource_sprite, "scale", Vector2(1.25,1.25), 0.125).set_trans(Tween.TRANS_CUBIC)
	boing_tween.tween_property(resource_sprite, "scale", Vector2(1,1), 0.125).set_trans(Tween.TRANS_CUBIC)


func _on_entity_hitbox_hurt(_attacker: EntityData) -> void:
	get_gathered()
