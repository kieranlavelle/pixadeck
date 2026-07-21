class_name TurnManager
extends Node


signal turn_started(player_id: int)

# this should always be 2 for now. Built this way for the future.
var num_players: int
var current_player: int
var turn_count: int = 1

func start(num_players: int) -> void:
	# flip a coin and decide who goes first.
	# DEBUG: For now the player always starts first
	var _first = randi() % num_players
	current_player = 0
	turn_started.emit(current_player)

# flip to the other player
func _on_turn_ended() -> void:
	if current_player == 0:
		current_player = 1
	else:
		current_player = 0
	turn_started.emit(current_player)
