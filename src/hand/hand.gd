class_name Hand
extends HBoxContainer

const DEFAULT_MAX_HAND_SIZE = 5
const CARD_SCENE = preload("res://src/card/card.tscn")

signal hand_empty

var cards: Array[Card] = []

func add_to_hand(card_data: CardData) -> void:
	if cards.size() < DEFAULT_MAX_HAND_SIZE:
		var card_instance = CARD_SCENE.instantiate()
		card_instance.card_data = card_data
		card_instance.played_card.connect(play_card)
		add_child(card_instance)
		cards.append(card_instance)


func update_cards_for_turn(is_opponents_turn: bool) -> void:
	for card in get_children():
		card.opponents_turn = is_opponents_turn
		card.is_locally_owned = get_parent().is_local_player


func play_card(card: Card, new_parent: CardDropZone) -> void:
	# this get_parent().player_id needs to be removed later
	new_parent.play_card(card, get_parent().player_id)
	var index = cards.find(card)
	cards.remove_at(index)

	if cards.size() == 0:
		hand_empty.emit()
