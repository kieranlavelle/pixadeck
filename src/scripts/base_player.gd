class_name BasePlayer
extends Node

@export var is_local_player: bool

@onready var deck = $Deck
@onready var hand = $Hand
@onready var mana = $Mana

signal player_turn_ended

# set by the battle manager at battle start.
# used to infer if it is the players turn
var player_id: int

func _ready() -> void:
	hand.request_play_card.connect(_request_to_play_card)
	hand.request_transition.connect(_handle_card_transition_request)


func _player_turn_ended() -> void:
	player_turn_ended.emit()


func _on_turn_start(player: BasePlayer) -> void:
	# if it's the players turn, draw a card from their hand	
	if player.player_id == player_id:
		# this just feels a bit better, so we can see the card appear
		await get_tree().create_timer(1).timeout
		deck.draw_card()
		enable_player()
		
		mana.on_new_turn()
	else:
		disable_player()



func disable_player() -> void:
	hand.update_cards_for_turn(true)


func enable_player() -> void:
	hand.update_cards_for_turn(false)


func _request_to_play_card(card: Card, zone: CardDropZone) -> bool:
	var mana_required: int = card.card_data.card_cost
	if mana_required <= mana.current_mana:
		mana.use_mana(mana_required)
		hand.play_card(card, zone)
		
		return true
	else:
		return false


# There are now two ways to achive a similar result. We could probably remove request play card
# and just treat certain transition requests to play cards instead
func _handle_card_transition_request(card: Card, from: String, to: String, callback: Callable):
	# in the future if more cases come up I will make a matrix, but not right now.
	if from == "DRAGGING" and to == "PLAYED":
		var mana_required: int = card.card_data.card_cost
		if mana_required <= mana.current_mana:
			callback.call(true)
		else:
			callback.call(false)
	else:
		callback.call(true)
