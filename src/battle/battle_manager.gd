class_name BattleManager
extends Node2D

@onready var PlayerNode = $Player
@onready var EnemyNode = $Enemy
@onready var TurnManagerNode = $TurnManager
@onready var BattleOverlay = $BattleOverlay

var players: Array[BasePlayer] = []

func _ready():
		
	# if A player end's their turn emit turn_finished
	PlayerNode.player_turn_ended.connect(TurnManagerNode.turn_finished.emit)
	EnemyNode.player_turn_ended.connect(TurnManagerNode.turn_finished.emit)
	
	# If A player skips their turn emit turn finished
	BattleOverlay.request_end_turn.connect(TurnManagerNode.turn_finished.emit)
	
	
	# UI Updates
	TurnManagerNode.turn_started.connect(_ui_on_turn_start)
		
	# What to do when a turn starts?
	TurnManagerNode.turn_started.connect(PlayerNode._on_turn_start)
	TurnManagerNode.turn_started.connect(EnemyNode._on_turn_start)
	TurnManagerNode.turn_started.connect(BattleOverlay._on_turn_start)
	
	players.assign(get_tree().get_nodes_in_group("Player"))
	for player in players:
		player.player_id = player.get_instance_id()

	TurnManagerNode.start(players)

func _ui_on_turn_start(player: BasePlayer) -> void:
	
	# we don't need to check it's there turn as it must be inside this
	# as the signal fired.
	if player.is_local_player:
		BattleOverlay.show_end_turn_button()
	else:
		BattleOverlay.hide_end_turn_button()
