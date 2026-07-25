class_name EffectData
extends Resource

@export var name: String
@export_multiline var description: String

@export var trigger_events: Array[StringName]
@export var trigger_filters: Array[TriggerFilterData] = []
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


func resolve(_event: BattleEvent, _context: BattleContext, _source: Card) -> void:
	pass


func get_tooltip_keywords() -> Array[KeywordData]:
	return tooltip_keywords
