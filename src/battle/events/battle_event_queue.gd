class_name BattleEventQueue
extends Node

signal event_dispatched(event: BattleEvent)
signal event_resolved(event: BattleEvent)

var battle_context: BattleContext
var _queue: Array[BattleEvent] = []
var _is_resolving: bool = false
var _trace: EventTrace = EventTrace.new()

class CardTriggerPair:
	var card: Card
	var trigger: CardEffect

	func _init(_card: Card, _trigger: CardEffect):
		card = _card
		trigger = _trigger



# Add event onto the queue and then if we're not already
# processing the queue begin to process it.
func enqueue(event: BattleEvent) -> void:
	_queue.append(event)
	if not _is_resolving:
		await _drain()


func _drain() -> void:
	_is_resolving = true
	while not _queue.is_empty():
		var event: BattleEvent = _queue.pop_front()

		# collect a snapshot so for this event, it's effects are finite,
		# cannot cascade and can't be altered while processing. Makes it
		# determenistic.
		_trace.event_started(event)
		event_dispatched.emit(event)
		# STATUS_EXPIRY is deterministic maintenance, never a reaction window.
		var triggers: Array[CardTriggerPair] = []
		if event.type != BattleEventType.STATUS_EXPIRY:
			triggers = _collect_triggers_snapshot(event)
		for trigger in triggers:
			await _resolve_trigger(trigger, event)

		await battle_context.resolve_lifecycle_event(event)
		event_resolved.emit(event)
		_trace.event_ended(event)
	_is_resolving = false


func _collect_triggers_snapshot(event: BattleEvent) -> Array[CardTriggerPair]:
	var _will_trigger: Array[CardTriggerPair] = []

	for card in battle_context.get_active_cards():
		for effect in card.card_data.effects:

			# Effect classes own their event and source-relation rules.
			if not effect.can_trigger(event, battle_context, card):
				continue
			
			_will_trigger.append(CardTriggerPair.new(card, effect))


	return _will_trigger


func _resolve_trigger(pair: CardTriggerPair, event: BattleEvent) -> void:
	# check just before it runs, in case it depends on other resolves further up in the chain
	# will default to true if there are no status' so won't block normal runs
	var blocking_status := pair.card.card_status_holder.blocks_trigger(
		pair.trigger,
		pair.card,
		event,
		battle_context
	)
	if blocking_status != null:
		await battle_context.event_queue.enqueue(BattleEvent.new(
			BattleEventType.STATUS_TRIGGER_BLOCKED,
			pair.card.owner_combatant,
			blocking_status.source,
			pair.card,
			pair.card,
			{"status": blocking_status, "trigger": pair.trigger}
		))
		return
	await pair.trigger.resolve(event, battle_context, pair.card)
