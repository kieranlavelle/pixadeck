class_name OnOpponentTurnStartedEffect
extends CardEffect


func can_trigger(event: BattleEvent, _context: BattleContext, source: Card) -> bool:
	return event.type == BattleEventType.TURN_STARTED and event.owner != source.owner_combatant
