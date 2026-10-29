class_name EntityData
extends Resource

@export var unit_name : String
@export var health: int
@export var damage : int
@export var attack_range : float
@export var rate_of_fire : float
@export var bullet_texture : Texture2D

@export var body_type : CombatData.BodyType
@export var damage_type : CombatData.DamageType
@export var elevation: CombatData.ElevationType = CombatData.ElevationType.GROUND
