class_name CardStatusHolder
extends RefCounted

var host: Card
var statuses: Array[CardStatusInstance] = []


func add_status(status: CardStatusInstance) -> void:
	statuses.append(status)


func remove_status(status: CardStatusInstance) -> void:
	statuses.erase(status)


func decrement_statuses(event: BattleEvent) -> void:
	for i in range(statuses.size() - 1, -1, -1):
		var status := statuses[i]
		
		# this status does not want to tick for this event
		if not status.data.should_tick(event, status):
			continue

		if status.remaining_turns == -1:
			continue

		status.remaining_turns -= 1

		if status.remaining_turns <= 0:
			remove_status(status)


func can_resolve_effect(effect: CardEffect, event: BattleEvent, context: BattleContext) -> bool:
	for status in statuses:
		if not status.can_resolve_effect(effect, event, context):
			return false
	return true
