class_name Combatant
extends Control

@export var is_local_player: bool
@export var seat: Seat

@onready var deck: Deck = $Layout/Deck as Deck
@onready var hand: Hand = $Layout/Hand as Hand

@onready var stats: Stats = $Layout/Stats as Stats
@onready var layout = $Layout
@onready var ai_controller = $AIController

signal emit_command(command: PlayCardCommand, callback: Variant)

enum Seat { TOP, BOTTOM }

# set by the battle manager at battle start.
# used to infer if it is the players turn
var combatant_id: int
var battle_context: BattleContext
var discard_pile: DiscardPile

func _ready() -> void:
	hand.emit_command.connect(emit_command.emit)
	hand.owner_combatant = self

	# create their discard pile container
	discard_pile = DiscardPile.new()


	# disable the AI controller if this is a player
	if is_local_player:
		ai_controller.set_process(false)
	else:
		ai_controller.setup(self)


func _on_turn_start(combatant: Combatant) -> void:
	# if it's the players turn, draw a card from their hand
	if combatant.combatant_id == combatant_id:
		# If it's an AI hand control to the controller.
		if not is_local_player:
			ai_controller.play_turn()

	else:
		disable_player()


func disable_player() -> void:
	hand.update_cards_for_turn(true)


func enable_player() -> void:
	hand.update_cards_for_turn(false)


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
