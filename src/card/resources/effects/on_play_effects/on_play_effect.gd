class_name OnPlayEffect
extends CardEffect


func can_trigger(event: BattleEvent, _context: BattleContext, effect_card: Card) -> bool:
	return event.type == BattleEventType.CARD_PLAYED and effect_card == event.card
