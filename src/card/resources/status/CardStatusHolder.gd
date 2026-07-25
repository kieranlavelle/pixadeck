class_name CardStatusHolder
extends RefCounted

var host: Card
var statuses: Array[CardStatusInstance] = []


func add_status(status: CardStatusInstance) -> void:
	statuses.append(status)


func remove_status(status: CardStatusInstance) -> void:
	statuses.erase(status)


func decrement_statuses() -> void:
	for status in statuses:
		
		# these are permernant status'
		if status.remaining_turns == -1:
			continue
		
		if status.remaining_turns == 1:
			remove_status(status)
		
		status.remaining_turns -= 1

func can_resolve_effect(effect: EffectData, event: BattleEvent, context: BattleContext) -> bool:
	for status in statuses:
		if not status.can_resolve_effect(effect, event, context):
			return false
	return true
