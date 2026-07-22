class_name TurnManager
extends Node


signal turn_started(player: BasePlayer)
signal turn_finished


var current_player: BasePlayer
var turn_count: int = 1
var players: Array[BasePlayer] = []

func start(all_players: Array[BasePlayer]) -> void:
	# flip a coin and decide who goes first.
	players = all_players
	current_player = all_players.pick_random()
	turn_started.emit(current_player)

# flip to the other player
func _on_turn_ended() -> void:
	var index := players.find(current_player)
	index += 1
	
	if index >= players.size():
		index = 0
		
	current_player = players[index]
	turn_started.emit(current_player)
