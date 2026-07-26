class_name BattleEvent
extends RefCounted

var type: StringName
var owner: Combatant
var source: Variant
var target: Variant
var card: Card
var payload: Dictionary = {}
var cancelled: bool = false
var cancelled_reason: String = ""
var before_end: Variant


func _init(
	_type: StringName,
	_owner: Combatant = null,
	_source: Variant = null,
	_target: Variant = null,
	_card: Card = null,
	_payload: Dictionary = {},
	_before_end = null,
) -> void:
	type = _type
	owner = _owner
	source = _source
	target = _target
	card = _card
	payload = _payload
	before_end = _before_end


func cancel(reason: String = "") -> void:
	cancelled = true
	cancelled_reason = reason


func clean_up() -> void:
	if before_end != null:
		await before_end.call(self)
