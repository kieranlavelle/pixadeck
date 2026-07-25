class_name RandomEnemyTargetSelector
extends TargetSelector

func pick_target(event: BattleEvent, context: BattleContext, source: Card) -> Combatant:
	#var targets := context.get_all_targets(event)
	
	# filter out the owner
	var targets := context.combatants.filter(func(t):
		return t != source.owner_combatant
	)
	
	# filter all cards for now, in future this will target some cards
	#targets = targets.filter(func(t): t is not Card)
	
	if targets.is_empty():
		return null
	
	return targets.pick_random()
