class_name BattleManager
extends Node2D

@onready var PlayerNode = $Player
@onready var EnemyNode = $Enemy
@onready var TurnManagerNode = $TurnManager
@onready var BattleOverlay = $BattleOverlay

func _ready():
	PlayerNode.player_turn_ended.connect(TurnManagerNode._on_turn_ended)
	EnemyNode.player_turn_ended.connect(TurnManagerNode._on_turn_ended)
	
	TurnManagerNode.turn_started.connect(PlayerNode._on_turn_start)
	TurnManagerNode.turn_started.connect(EnemyNode._on_turn_start)
	TurnManagerNode.turn_started.connect(BattleOverlay._on_turn_start)
	
	# assign players a player-id. Player 0 will always be the actual Player
	var players := get_tree().get_nodes_in_group("Player")
	for i in len(players):
		players[i].player_id = i

	TurnManagerNode.start(len(players))
