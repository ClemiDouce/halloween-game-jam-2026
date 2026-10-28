@tool
extends Node2D

const TILE_SIZE = 32

@export var crystal_texture: Texture2D
@export_range(1, 16) var count: int = 6

func _ready() -> void:
	var x: int = 0
	var y: int = 0
	for i in range(count):
		var sprite = Sprite2D.new()
		sprite.position.x = x
		sprite.position.y = y + randi() % 2
		sprite.texture = crystal_texture
		self.add_child(sprite)
		x += crystal_texture.get_width() + randi() % 2
		if x >= TILE_SIZE:
			x = 0
			y += crystal_texture.get_height() + randi() % 2
		
