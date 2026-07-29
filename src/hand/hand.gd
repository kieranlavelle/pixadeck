class_name Hand
extends HBoxContainer

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

@export var card_played_sound: AudioStream


const DEFAULT_MAX_HAND_SIZE = 5
const CARD_SCENE = preload("res://src/card/card.tscn")

signal emit_command(command: PlayCardCommand, callback: Variant)
signal card_discarded(card: Card)

var can_drop_at: Callable
var cards: Array[Card] = []
var owner_combatant: Combatant

func _ready():
	audio.stream = card_played_sound


func is_hand_full() -> bool:
	return len(cards) >= DEFAULT_MAX_HAND_SIZE


func has_card(card) -> bool:
	return true if cards.find(card) != -1 else false


func add_to_hand(card_data: CardData) -> Card:
	if cards.size() < DEFAULT_MAX_HAND_SIZE:
		var card_instance = CARD_SCENE.instantiate()
		card_instance.card_data = card_data
		card_instance.owner_combatant = owner_combatant
		card_instance.can_drop_at = can_drop_at

		# connect signals
		card_instance.emit_command.connect(emit_command.emit)

		add_child(card_instance)
		cards.append(card_instance)

		return card_instance
	return null


func update_cards_for_turn(is_opponents_turn: bool) -> void:
	for card in cards:
		card.opponents_turn = is_opponents_turn
		card.is_locally_owned = owner_combatant.is_local_player


# Called by the BattleManager during PlayCardCommand orchestration.
func play_card(card: Card, board: Board) -> void:

	if audio.stream:
		audio.play()

	board.add_card(card)
	var index = cards.find(card)

	# find() can return -1
	if index != -1:
		cards.remove_at(index)


func discard_card(card: Card) -> Card:
	var index := cards.find(card)
	if index == -1:
		return null

	cards.remove_at(index)
	card_discarded.emit(card)
	return card
