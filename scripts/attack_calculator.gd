class_name AttackCalculator



static func get_attack_damage(attacker: UnitResource, target: UnitResource):
	var final_damage = attacker.damage
	match(target.body_type):
		UnitResource.BodyType.HUMAN:
			match(attacker.damage_type):
				UnitResource.DamageType.BULLET:
					pass
				UnitResource.DamageType.EXPLOSIVE:
					pass
		UnitResource.BodyType.ARMORED:
			match(attacker.damage_type):
				UnitResource.DamageType.BULLET:
					final_damage *= 0.3
				UnitResource.DamageType.EXPLOSIVE:
					pass
	return final_damage
