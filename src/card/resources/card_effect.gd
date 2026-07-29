class_name CardEffect
extends Resource

# Each subclass describes one readable card rule. Keep mutable state on the
# runtime card or a status instance, never on this shared resource.
@export var id: StringName
@export_multiline var display_text: String

@export var tooltip_keywords: Array[KeywordData] = []


func can_trigger(_event: BattleEvent, _context: BattleContext, _source: Card) -> bool:
	return false


func resolve(_event: BattleEvent, _context: BattleContext, _source: Card) -> void:
	pass


func get_tooltip_keywords() -> Array[KeywordData]:
	return tooltip_keywords
