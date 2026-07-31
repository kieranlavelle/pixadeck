class_name TurnManager
extends Node


signal before_turn_started(combatant: Combatant)
signal turn_started(combatant: Combatant)
signal turn_finished(conbatant: Combatant)

# StartTurnCommand has to run before turn_started
# as turn_started causes combatants to act the issue is
# turn_started is also used for BattleOverlay display and it would be nice
# to see the text from that for a second before cards are drawn (which StartTrunCommand)
# makes happen. For this reason we should have a before_turn_started signal which
# runs for a second before the turn starts and is conntexted to battle_overlay

var current_combatant: Combatant
var combatants: Array[Combatant] = []
var context: BattleContext

func start(all_combatants: Array[Combatant]) -> void:
	# flip a coin and decide who goes first.
	combatants = all_combatants
	current_combatant = all_combatants.pick_random()

	before_turn_started.emit(current_combatant)
	await get_tree().create_timer(1).timeout
	await process_turn_started_command()
	turn_started.emit(current_combatant)


func advance_turn() -> void:
	var index := combatants.find(current_combatant) + 1
	if index >= combatants.size():
		index = 0

	current_combatant = combatants[index]
	before_turn_started.emit(current_combatant)
	await get_tree().create_timer(1).timeout
	await process_turn_started_command()
	turn_started.emit(current_combatant)


func process_turn_started_command() -> void:
	var start_turn_cmd := StartTurnCommand.new(current_combatant)
	await context.event_queue.enqueue_root(start_turn_cmd)
