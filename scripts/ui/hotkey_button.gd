class_name HotkeyButton
extends Button

@export var hotkey_label: Label
@export var empty_icon_texture: Texture2D


func _ready() -> void:
	button_mask = 0
	self.clear()


func assign_unit(unit_type: UnitResource) -> void:
	hotkey_label.text = unit_type.input_keyboard.as_text_key_label()
	self.icon = unit_type.button_icon if unit_type.button_icon else empty_icon_texture


func clear() -> void:
	hotkey_label.text = ""
	self.tooltip_text = ""
	self.icon = empty_icon_texture
