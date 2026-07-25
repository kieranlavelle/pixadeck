class_name AllEnemiesTargetSelector
extends TargetSelector


func select_targets(_event: BattleEvent, context: BattleContext, source: Card) -> Array[Variant]:
	var targets := context.combatants.filter(func(t):
		return t != source.owner_combatant
	)

	return targets
