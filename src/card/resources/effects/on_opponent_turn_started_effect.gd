class_name OnOpponentTurnStartedEffect
extends CardEffect


func can_trigger(event: BattleEvent, _context: BattleContext, effect_card: Card) -> bool:
	return event.type == BattleEventType.TURN_STARTED and event.owner != effect_card.owner_combatant
