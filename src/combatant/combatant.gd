class_name Combatant
extends Control

@export var is_local_player: bool
@export var seat: Seat

@onready var deck = $Layout/Deck
@onready var hand = $Layout/Hand
@onready var stats: Stats = $Layout/Stats as Stats
@onready var layout = $Layout
@onready var ai_controller = $AIController

signal player_turn_ended

enum Seat { TOP, BOTTOM }

# set by the battle manager at battle start.
# used to infer if it is the players turn
var combatant_id: int

func _ready() -> void:
	hand.request_play_card.connect(_request_to_play_card)
	hand.request_transition.connect(_handle_card_transition_request)
	hand.owner_combatant = self
	
	
	# disable the AI controller if this is a player
	if is_local_player:
		ai_controller.set_process(false)
	else:
		ai_controller.setup(self)


func _player_turn_ended() -> void:
	player_turn_ended.emit()


func _on_turn_start(combatant: Combatant) -> void:
	# if it's the players turn, draw a card from their hand	
	if combatant.combatant_id == combatant_id:
		
		# Wait so we can see the cards appear.
		# TODO: This will be replaced with animation await
		await get_tree().create_timer(1).timeout
		
		# behaviours agnostic to real vs ai player.
		await deck.draw_card()
		enable_player()
		stats.on_new_turn()
		
		# If it's an AI hand control to the controller.
		if not is_local_player:
			ai_controller.play_turn()
		
	else:
		disable_player()



func disable_player() -> void:
	hand.update_cards_for_turn(true)


func enable_player() -> void:
	hand.update_cards_for_turn(false)


func _request_to_play_card(card: Card, zone: CardDropZone) -> bool:
	var mana_required: int = card.card_data.card_cost
	if mana_required <= stats.current_mana:
		stats.use_mana(mana_required)
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
		if mana_required <= stats.current_mana:
			callback.call(true)
		else:
			callback.call(false)
	else:
		callback.call(true)



func apply_layout() -> void:
	# In future if we want to mirror layouts we can move the index
	# of Layout to changer their ordering
	if seat == Seat.BOTTOM:
		stats.size_flags_vertical = Control.SIZE_SHRINK_END
		deck.size_flags_vertical = Control.SIZE_SHRINK_END
		hand.size_flags_vertical = Control.SIZE_SHRINK_END
	else:
		stats.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		deck.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		hand.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
