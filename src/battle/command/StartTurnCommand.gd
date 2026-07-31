class_name StartTurnCommand
extends RootCommand

var combatant: Combatant


func _init(_combatant: Combatant):
	combatant = _combatant


func execute(context: BattleContext) -> RootCommand:
	var turn_started_event: BattleEvent = BattleEvent.new(
		BattleEventType.TURN_SETUP_STARTED, combatant, combatant
	)
	await context.event_queue.resolve_child(turn_started_event)

	if turn_started_event.cancelled:
		is_success = false
		reason = turn_started_event.cancelled_reason
		return self

	# setup the players stats for the turn
	combatant.stats.on_new_turn()

	var req_draw_card := RequestDrawCardCommand.new(combatant, combatant.deck, combatant.hand)
	await context.execute(req_draw_card)

	if not req_draw_card.is_success:
		is_success = false
		reason = "Failed to draw card: [" + req_draw_card.reason + "]"
		return self

	# enable player UI-actions
	combatant.enable_player()

	await context.event_queue.resolve_child(
		BattleEvent.new(BattleEventType.TURN_STARTED, combatant, combatant)
	)

	is_success = true
	return self
