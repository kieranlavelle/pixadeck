class_name CardStatusHolder
extends RefCounted

var host: Card
var statuses: Array[CardStatusInstance] = []


func add_status(status: CardStatusInstance) -> void:
	statuses.append(status)


func remove_status(status: CardStatusInstance) -> void:
	statuses.erase(status)



# UNIQUE_REFRESH and STACK_DURATION require at most one matching instance.
# SEPARATE_INSTANCES must not call this method because every application is
# independently timed.
func find_unique_by_definition(definition: CardStatusData) -> CardStatusInstance:
	var found: CardStatusInstance = null
	for status in statuses:
		if status.definition == definition:
			assert(found == null, "Duplicate instances found for %s" % definition.id)
			if found == null:
				found = status
	return found


func blocks_trigger(
	trigger: CardEffect,
	source_card: Card,
	event: BattleEvent,
	context: BattleContext
) -> CardStatusInstance:
	for status in statuses:
		if status.blocks_trigger(trigger, source_card, event, context):
			return status
	return null
