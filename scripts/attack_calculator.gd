class_name AttackCalculator



static func get_attack_damage(attacker: EntityData, target: EntityData):
	var final_damage = attacker.damage
	match(target.body_type):
		CombatData.BodyType.HUMAN:
			match(attacker.damage_type):
				CombatData.DamageType.BULLET:
					pass
				CombatData.DamageType.EXPLOSIVE:
					pass
		CombatData.BodyType.ARMORED:
			match(attacker.damage_type):
				CombatData.DamageType.BULLET:
					final_damage *= 0.3
				CombatData.DamageType.EXPLOSIVE:
					pass
	return final_damage
