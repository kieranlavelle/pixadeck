class_name Board
extends RefCounted

signal card_placed(card: Card, to: Combatant.Seat)
signal card_removed(card: Card, from: Combatant.Seat)

# consts
const MAX_CARDS_PER_ZONE: int = 8

# containers
var battlefiled_cards: Dictionary[Combatant.Seat, Array] = {} # of the form Zone->Array[Card]

func _init() -> void:
	var top_cards: Array[Card] = []
	var bottom_cards: Array[Card] = []
	battlefiled_cards = {
		Combatant.Seat.TOP: top_cards,
		Combatant.Seat.BOTTOM: bottom_cards
	}


func get_players_cards(owner: Combatant) -> Array[Card]:
	return battlefiled_cards[owner.seat] as Array[Card]


func add_card(card: Card, owner: Combatant) -> void:
	battlefiled_cards[owner.seat].append(card)
	card_placed.emit(card, owner.seat)


func remove_card(card: Card, owner: Combatant) -> void:
	battlefiled_cards[owner.seat].erase(card)
	card_removed.emit(card, owner.seat)


func get_all_cards() -> Array[Card]:
	var all_cards: Array[Card] = []
	all_cards.append_array(battlefiled_cards[Combatant.Seat.TOP])
	all_cards.append_array(battlefiled_cards[Combatant.Seat.BOTTOM])
	return all_cards


func can_add_card(zone: Combatant.Seat) -> bool:
	return battlefiled_cards[zone].size() < MAX_CARDS_PER_ZONE
