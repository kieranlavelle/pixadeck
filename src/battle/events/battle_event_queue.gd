class_name BattleEventQueue
extends Node

signal event_dispatched(event: BattleEvent)
signal event_resolved(event: BattleEvent)

var battle_context: BattleContext
var _queue: Array[RootCommand] = []
var _is_resolving: bool = false
var _trace: DebugTrace = DebugTrace.new()

class CardTriggerPair:
	var card: Card
	var trigger: CardEffect

	func _init(_card: Card, _trigger: CardEffect):
		card = _card
		trigger = _trigger


func has_active_root() -> bool:
	return _is_resolving


func enqueue_root(root: RootCommand) -> void:
	_queue.append(root)
	if not _is_resolving:
		await _drain_roots()
	else:
		# wait for this root's completed signal, as we've appended it
		# _drain_roots will pick it up when it's done with the current root
		# in the meantime, this blocks
		await root.completed


func resolve_child(event: BattleEvent) -> void:
	# we use an assert here as this is an error state that should not
	# end up in the game
	assert(_is_resolving, "Child events require an active root")
	await _resolve_event(event)


func _resolve_event(event: BattleEvent) -> void:
	_trace.begin_event(event)
	event_dispatched.emit(event)

	# STATUS_EXPIRY is deterministic maintenance, never a reaction window.
	var triggers: Array[CardTriggerPair] = []
	if event.type != BattleEventType.STATUS_EXPIRY:
		triggers = _collect_triggers_snapshot(event)

	for trigger in triggers:
		await _resolve_trigger(trigger, event)

	await battle_context.resolve_lifecycle_event(event)
	event_resolved.emit(event)
	_trace.end_event(event)


func _drain_roots() -> void:
	_is_resolving = true
	while not _queue.is_empty():
		var root: RootCommand = _queue.pop_front()
		_trace.begin_root(root)
		await root.execute(battle_context)
		root.finish()
		_trace.end_root(root)
		print(_trace.root_to_string(root))
	_is_resolving = false


func _collect_triggers_snapshot(event: BattleEvent) -> Array[CardTriggerPair]:
	var _will_trigger: Array[CardTriggerPair] = []

	for card in battle_context.get_active_cards():
		for effect in card.card_data.effects:

			# Effect classes own their event and effect-card relation rules.
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
		await battle_context.event_queue.resolve_child(BattleEvent.new(
			BattleEventType.STATUS_TRIGGER_BLOCKED,
			pair.card.owner_combatant,
			blocking_status.source,
			pair.card,
			pair.card,
			{"status": blocking_status, "trigger": pair.trigger}
		))
		return
	await pair.trigger.resolve(event, battle_context, pair.card)
