class_name UnitResource extends EntityData

# Unit Stats
@export var speed: float
@export var trail_length : int

# Construction
@export_subgroup("Construction")
@export var time_to_build: float  # seconds
@export var texture: Dictionary[CombatData.Team, Texture]
@export var shader: ShaderMaterial
@export var input_keyboard: InputEventKey

# UI
@export var button_icon: Texture2D
@export var ui_description: String
