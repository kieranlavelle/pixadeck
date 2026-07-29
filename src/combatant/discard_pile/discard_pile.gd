class_name DiscardPile
extends RefCounted

var _pile: Array[CardData] = []
var is_hovered := false

func add_card(card_data: CardData) -> void:
	_pile.append(card_data.duplicate())
