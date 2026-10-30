extends PanelContainer

@export var label: RichTextLabel
@export var visualizer: BaseVisualizer

const REQUISTION = preload("uid://cqwrurfstykui")

const CRYSTAL = preload("uid://y8ep32g2xixa")


@export_category("Text")
@export_multiline var no_selection_text: String
@export_multiline var build_building_text: String
@export_multiline var build_unit_text: String

func _ready() -> void:
	_show_no_selection_hint()
	visualizer.building_selected.connect(func(building: Building):
		if building == null:
			_show_buildings_hint()
		else:
			_show_units_hint(building)
	)

func _show_no_selection_hint() -> void:
	label.text = "[font_size=16]%s[/font_size]" % [no_selection_text]

func _show_buildings_hint() -> void:
	label.text = "[font_size=16]%s[/font_size]" % [build_building_text]
	
	for building in visualizer.player.controlling_base.get_building_types():
		var unit_names: Array[String] = []
		for unit in building.units:
			unit_names.append(unit.unit_name)
		
		label.text += "\n\n[font_size=16][b]%s -[/b] %s[/font_size]\n[i]Produces: %s[/i]" % [
			building.input_keyboard.as_text_keycode(),
			building.building_name,
			" ".join(unit_names)
		]

func _show_units_hint(building: Building) -> void:
	label.text = "[font_size=16]%s[/font_size]" % [build_unit_text]
	
	for unit in building.units:
		var resource_text = ""
		if unit.money_cost > 0:
			resource_text += "[img height=1em]%s[/img] %s" % [REQUISTION.resource_path, unit.money_cost]
		if unit.money_cost > 0 and unit.crystal_cost > 0:
			resource_text += "  "
		if unit.crystal_cost > 0:
			resource_text += "[img height=1em]%s[/img] %s" % [CRYSTAL.resource_path, unit.crystal_cost]
		label.text += "\n\n[font_size=16][b]%s -[/b] %s[/font_size]\n%s\n%s" % [
			unit.input_keyboard.as_text_keycode(),
			unit.unit_name,
			"%s %s" % [
				CombatData.BodyType.find_key(unit.body_type),
				CombatData.DamageType.find_key(unit.damage_type)
			],
			resource_text,
		]
		if unit.ui_description != "":
			label.text += "\n[i]%s[/i]" % [unit.ui_description]
	
