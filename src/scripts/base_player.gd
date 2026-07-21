class_name BasePlayer
extends Node

@export var is_local_player: bool

@onready var deck = $Deck
@onready var hand = $Hand

signal player_turn_ended

# set by the battle manager at battle start.
# used to infer if it is the players turn
var player_id: int

func _ready() -> void:
	hand.hand_empty.connect(_player_turn_ended)
	get_groups()


func _player_turn_ended() -> void:
	player_turn_ended.emit()


func _on_turn_start(id: int) -> void:
	# if it's the players turn, draw a card from their hand	
	if id == player_id:
		# this just feels a bit better, so we can see the card appear
		await get_tree().create_timer(1).timeout
		deck.draw_card()
		enable_player()
	else:
		disable_player()


func disable_player() -> void:
	hand.update_cards_for_turn(true)


func enable_player() -> void:
	hand.update_cards_for_turn(false)
