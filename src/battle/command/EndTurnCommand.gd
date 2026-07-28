class_name EndTurnCommand
extends Command


func execute(context: BattleContext) -> EndTurnCommand:
	var owner := context.turn_manager.current_combatant
	if owner == null:
		reason = "No active combatant"
		is_success = false
		return self

	# TURN_ENDING is the last reaction window while the current owner is active.
	var turn_ending_event := BattleEvent.new(
		BattleEventType.TURN_ENDING,
		owner,
		owner
	)
	await context.event_queue.enqueue(turn_ending_event)


	var turn_ended_event := BattleEvent.new(
		BattleEventType.TURN_ENDED,
		owner,
		owner,
		null,
		null,
		{},
		context.expire_card_statuses_for_owner
	)
	await context.event_queue.enqueue(turn_ended_event)

	# The existing turn event contract has no cancellation semantics. Effects may
	# react to the ending, but cannot prevent the turn from advancing.
	context.advance_turn()

	is_success = true
	return self
