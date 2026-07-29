class_name DiscardPile
extends RefCounted

var _pile: Array[CardData] = []
var is_hovered := false

func add_card(card: Card) -> void:
	_pile.append(card.card_data.duplicate())
	card.queue_free()
