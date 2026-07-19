class_name Hand
extends HBoxContainer

const DEFAULT_MAX_HAND_SIZE = 5
const CARD_SCENE = preload("res://src/card/card.tscn")

var cards: Array[Card] = []

func add_to_hand(card_data: CardData) -> void:
	if cards.size() < DEFAULT_MAX_HAND_SIZE:
		var card_instance = CARD_SCENE.instantiate()
		card_instance.card_data = card_data
		add_child(card_instance)
		cards.append(card_instance)
