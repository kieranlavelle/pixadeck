class_name RandomEnemyTargetSelector
extends TargetSelector


func select_targets(_event: BattleEvent, context: BattleContext, source: Card) -> Array[Variant]:
	var targets := context.combatants.filter(func(t):
		return t != source.owner_combatant
	)

	if targets.is_empty():
		return []

	return [targets.pick_random()]
