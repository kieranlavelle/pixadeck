class_name CardStatusInstance
extends RefCounted

var data: CardStatusData
var applier: Variant
var host: Card
var remaining_turns: int


func can_resolve_effect(effect: EffectData, event: BattleEvent, context: BattleContext) -> bool:
	return data.can_resolve_effect(effect, event, context, self)
