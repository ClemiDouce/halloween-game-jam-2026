class_name HotkeyButton
extends Button

@export var hotkey_label: Label
@export var empty_icon_texture: Texture2D


func _ready() -> void:
	button_mask = 0
	self.clear()


func assign_unit(unit_type: UnitResource) -> void:
	hotkey_label.text = unit_type.input_keyboard.as_text_keycode()
	self.icon = unit_type.button_icon if unit_type.button_icon else empty_icon_texture
	self.tooltip_text = (
		"""
		%s - %s (%ss)
		Build Cost: %s 
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
			unit_type.cost,
			CombatData.BodyType.find_key(unit_type.body_type),
			CombatData.DamageType.find_key(unit_type.damage_type),
			unit_type.health,
			unit_type.damage,
			unit_type.speed,
			unit_type.attack_range,
			unit_type.rate_of_fire
		]
	).lstrip(" ").rstrip(" ")
	print(unit_type.input_keyboard.as_text_keycode())

func assign_building(building: Building) -> void:
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
	self.hotkey_label.text = keycode_label
	self.tooltip_text = "%s - %s" % [keycode_label, action_name]
	self.icon = icon_texture if icon_texture else empty_icon_texture
	
func clear() -> void:
	hotkey_label.text = ""
	self.tooltip_text = ""
	self.icon = empty_icon_texture
