class_name UnitResource extends Resource

enum BodyType {HUMAN, ARMORED}
enum DamageType {BULLET, EXPLOSIVE}

# Unit Stats
@export var unit_name : String
@export var health: int
@export var speed : float


@export var body_type : BodyType
@export var damage_type : DamageType
@export var damage : int
@export var attack_range : float
@export var rate_of_fire : float

# Construction
@export_subgroup("Construction")
@export var cost : int
@export var time_to_build : float # seconds
@export var texture : Texture2D
@export var input_keyboard: InputEventKey
