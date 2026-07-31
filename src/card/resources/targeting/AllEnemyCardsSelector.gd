class_name AllEnemyCardsSelector
extends TargetSelector

func select_targets(_event: BattleEvent, context: BattleContext, effect_card: Card) -> Array[Variant]:
	var all_enemy_cards := context.get_active_cards().filter(
		func(card: Card):
			return card.owner_combatant != effect_card.owner_combatant
	)
	return all_enemy_cards
