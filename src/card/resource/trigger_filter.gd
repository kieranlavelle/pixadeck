class_name TriggerFilterData
extends Resource

# if it matches then this will filter OUT a given event
func matches(event: BattleEvent, context: BattleContext, source: Card) -> bool:
	return true
