class_name CardDropZone
extends Control

# The card dropzone technically has two zones. One for each player.
# the CardDropZone decides where a card gets reparented to.

@onready var TopZone = $Layout/TopZone
@onready var BottomZone = $Layout/BottomZone

var _cards: Array[Card] = []


# currently there is no notion of an owner, and there is only a player
func play_card(card: Card, combatant: Combatant):
	
	# re-affirm owner incase another process spawned this
	card.owner_combatant = combatant
	
	_cards.append(card)
	if combatant.seat == Combatant.Seat.BOTTOM:
		card.reparent(BottomZone)
	else:
		card.reparent(TopZone)


func get_all_cards() -> Array[Card]:
	return _cards
