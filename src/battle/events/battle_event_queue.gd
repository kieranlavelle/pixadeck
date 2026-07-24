class_name BattleEventQueue
extends Node

signal event_dispatched(event: BattleEvent)
signal event_resolved(event: BattleEvent)

var _queue: Array[BattleEvent] = []
var _is_resolving: bool = false


func dispatch(event: BattleEvent) -> void:
	_queue.append(event)

	if _is_resolving:
		return

	_is_resolving = true
	while not _queue.is_empty():
		var next_event: BattleEvent = _queue.pop_front()
		event_dispatched.emit(next_event)
		await _resolve_event(next_event)
		event_resolved.emit(next_event)
	_is_resolving = false


func enqueue(event: BattleEvent) -> void:
	_queue.append(event)


func _resolve_event(_event: BattleEvent) -> void:
	await get_tree().process_frame
