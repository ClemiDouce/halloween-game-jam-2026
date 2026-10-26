class_name UnitResource extends Resource

#enum UnitType {MELEE, RANGED}
#@export var type : UnitType

# Unit Stats
@export var health: int
@export var damage : int
@export var rate_of_fire : float
@export var speed : float
@export var attack_range : float

# Construction
@export var cost : int
@export var time_to_build : float # seconds
@export var texture : Texture2D
@export var input_keyboard: InputEventKey
