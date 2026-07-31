class_name AllEnemiesTargetSelector
extends TargetSelector


func select_targets(_event: BattleEvent, context: BattleContext, effect_card: Card) -> Array[Variant]:
	var targets := context.combatants.filter(func(t):
		return t != effect_card.owner_combatant
	)

	return targets
