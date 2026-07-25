class_name DoesNotOwnSourceCardTriggerFilter
extends TriggerFilterData


func matches(event: BattleEvent, context: BattleContext, source: Card) -> bool:
	return event.owner != source.owner_combatant
