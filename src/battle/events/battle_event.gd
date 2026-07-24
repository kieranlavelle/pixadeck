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


func _init(
	_type: StringName,
	_owner: Combatant = null,
	_source: Variant = null,
	_target: Variant = null,
	_card: Card = null,
	_payload: Dictionary = {}
) -> void:
	type = _type
	owner = _owner
	source = _source
	target = _target
	card = _card
	payload = _payload


func cancel(reason: String = "") -> void:
	cancelled = true
	cancelled_reason = reason
