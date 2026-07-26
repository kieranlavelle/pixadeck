class_name CardDropZone
extends Control

@onready var TopZone = $Layout/TopZone
@onready var BottomZone = $Layout/BottomZone

var _cards_top: Array[Card] = []
var _cards_bottom: Array[Card] = []

const MAX_CARDS_PER_ZONE = 8


func play_card(card: Card, combatant: Combatant):
	
	# re-affirm owner incase another process spawned this
	card.owner_combatant = combatant
	
	if combatant.seat == Combatant.Seat.BOTTOM:
		_cards_bottom.append(card)
		card.reparent(BottomZone)
	else:
		_cards_top.append(card)
		card.reparent(TopZone)


func get_all_cards() -> Array[Card]:
	var all_cards: Array[Card] = []
	all_cards.append_array(_cards_top)
	all_cards.append_array(_cards_bottom)
	return all_cards


# expresses if a combatant can add cards to a zone according
# to if their zone is full or not.
func can_add_card_to_zone(_owner: Combatant) -> bool:
	if _owner.seat == Combatant.Seat.BOTTOM:
		return _cards_bottom.size() < MAX_CARDS_PER_ZONE
	else:
		return _cards_top.size() < MAX_CARDS_PER_ZONE
