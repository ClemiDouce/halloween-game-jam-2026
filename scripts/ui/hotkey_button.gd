class_name HotkeyButton
extends Button

@export var hotkey_label: Label
@export var empty_icon_texture: Texture2D

var assigned_data = null

func _ready() -> void:
	button_mask = 0
	self.clear()


func create_ghost() -> void:
	var ghost := Sprite2D.new()
	ghost.texture = self.icon
	ghost.scale = self.scale
	ghost.centered = true
	self.add_child(ghost)
	ghost.global_position = self.global_position + Vector2(32,32)
	var tween := create_tween()
	tween.tween_property(ghost, "scale", ghost.scale * 2, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(ghost, "modulate", Color.TRANSPARENT, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(ghost.queue_free)


func assign_unit(unit_type: UnitResource) -> void:
	assigned_data = unit_type
	hotkey_label.text = unit_type.input_keyboard.as_text_keycode()
	self.icon = unit_type.button_icon if unit_type.button_icon else empty_icon_texture
	self.tooltip_text = (
		"""
		%s - %s (%ss)
		Body Type: %s
		Damage Type: %s
		Health: %s
		Damage: %s
		Speed: %s
		Attack Range: %s
		Attack Rate: %s
		"""
		% [
			unit_type.input_keyboard.as_text_keycode(),
			unit_type.unit_name,
			unit_type.time_to_build,
			CombatData.BodyType.find_key(unit_type.body_type),
			CombatData.DamageType.find_key(unit_type.damage_type),
			unit_type.health,
			unit_type.damage,
			unit_type.speed,
			unit_type.attack_range,
			unit_type.rate_of_fire
		]
	).lstrip(" ").rstrip(" ")
	#print(unit_type.input_keyboard.as_text_keycode())

func assign_building(building: Building) -> void:
	assigned_data = building
	hotkey_label.text = building.input_keyboard.as_text_keycode()
	self.icon = building.button_icon if building.button_icon else empty_icon_texture
	var unit_names: Array[String] = []
	for unit in building.units:
		unit_names.append(unit.unit_name)
	
	self.tooltip_text = (
		"""
		%s - %s
		Builds: %s
		"""  % [
			building.input_keyboard.as_text_keycode(),
			building.building_name,
			", ".join(unit_names) if unit_names.size() > 0 else "None"
		]
	)

func assign_action(keycode_label: String, action_name: String, icon_texture: Texture2D = null) -> void:
	assigned_data = action_name
	self.hotkey_label.text = keycode_label
	self.tooltip_text = "%s - %s" % [keycode_label, action_name]
	self.icon = icon_texture if icon_texture else empty_icon_texture
	
func clear() -> void:
	assigned_data = null
	hotkey_label.text = ""
	self.tooltip_text = ""
	self.icon = empty_icon_texture
