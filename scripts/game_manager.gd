class_name GameManager 
extends Node

func _ready():
	#TODO Connect to every base "destroyed" signal
	for base_entity in get_tree().get_nodes_in_group("base"):
		base_entity.destroyed.connect(_on_base_destroyed)
		
		
func _on_base_destroyed(base_data: BaseData):
	if base_data.team == CombatData.Team.PLAYER:
		# LOSE!
		print("Player lose")
	elif base_data.team == CombatData.Team.HOSTILE:
		# Check if other hostile base exist, else win
		var bases = get_tree().get_nodes_in_group("base")
		var hostiles_base = bases.filter(func(b: BaseEntity):
				return b.base_data.team == CombatData.Team.HOSTILE and b.base_data != base_data
		)
		
		if hostiles_base.size() == 0:
			# WIN !
			print("Win !")
		else:
			print("Not Yet, %s bases remain up" % hostiles_base.size())
