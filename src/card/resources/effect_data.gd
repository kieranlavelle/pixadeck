class_name EffectData
extends Resource

@export var name: String
@export_multiline var description: String

@export var trigger_events: Array[StringName] = []
@export var trigger_filters: Array[TriggerFilterData] = []
@export var effect_actions: Array[SelectorActionPair] = []

# display info
@export var tooltip_keywords: Array[KeywordData] = []
	
	
func listens_to(event_type: StringName) -> bool:
	return trigger_events.has(event_type)


func is_triggered_by(event: BattleEvent, context: BattleContext, source: Card) -> bool:
	if not listens_to(event.type):
		return false
		
	for _filter in trigger_filters:
		if not _filter.matches(event, context, source):
			return false
			
	return true


func resolve(event: BattleEvent, context: BattleContext, source: Card) -> void:
	for pair in effect_actions:
		var targets: Array[Variant] = pair.selector.select_targets(event, context, source)
		pair.action.apply(event, context, source, targets)


func get_tooltip_keywords() -> Array[KeywordData]:
	return tooltip_keywords
