class_name MyTurnEndingEffect
extends CardEffect


func can_trigger(event: BattleEvent, _context: BattleContext, source: Card) -> bool:
	return event.type == BattleEventType.TURN_ENDING and event.owner == source.owner_combatant
