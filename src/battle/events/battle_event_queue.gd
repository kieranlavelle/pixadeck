class_name BattleEventQueue
extends Node

signal event_dispatched(event: BattleEvent)
signal event_resolved(event: BattleEvent)

var battle_context: BattleContext
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


func _resolve_event(event: BattleEvent) -> void:
		
	for card in battle_context.get_active_cards(event):
		
		for effect in card.card_data.effects:
			# use a closure system here to disallow everything first
			
			# is the effect interested in this event
			if not effect.is_triggered_by(event, battle_context, card):
				continue
			
			# Does any status on this card stop it from handling this event
			if not card.card_status_holder.can_resolve_effect(effect, event, battle_context):
				continue
			
			# effect can proceed
			await effect.resolve(event, battle_context, card)
	
	# tick statu's at turn end and after all other effects
	if event.type == BattleEventType.TURN_ENDED:
		battle_context.expire_card_statuses_for_owner(event)

	print("Resolving event: ", event.type)
