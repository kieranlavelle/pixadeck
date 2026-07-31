class_name RandomEnemyTargetSelector
extends TargetSelector


func select_targets(_event: BattleEvent, context: BattleContext, effect_card: Card) -> Array[Variant]:
	var targets := context.combatants.filter(func(t):
		return t != effect_card.owner_combatant
	)

	if targets.is_empty():
		return []

	return [targets.pick_random()]
