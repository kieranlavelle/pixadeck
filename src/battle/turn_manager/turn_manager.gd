class_name TurnManager
extends Node


signal turn_started(combatant: Combatant)
signal turn_finished


var current_combatant: Combatant
var turn_count: int = 1
var combatants: Array[Combatant] = []

func start(all_combatants: Array[Combatant]) -> void:
	# flip a coin and decide who goes first.
	combatants = all_combatants
	current_combatant = all_combatants.pick_random()
	turn_started.emit(current_combatant)

# flip to the other player
func _on_turn_ended() -> void:
	var index := combatants.find(current_combatant)
	index += 1
	
	if index >= combatants.size():
		index = 0
		
	current_combatant = combatants[index]
	turn_started.emit(current_combatant)
