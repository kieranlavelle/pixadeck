class_name CardStatusInstance
extends RefCounted

var definition: CardStatusData
var source: Variant
var host: Card
var remaining_turns: int


func blocks_trigger(
	trigger: CardEffect,
	source_card: Card,
	event: BattleEvent,
	context: BattleContext
) -> bool:
	return definition.blocks_trigger(trigger, source_card, event, context, self)
