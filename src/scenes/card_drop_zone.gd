class_name CardDropZone
extends Control

# The card dropzone technically has two zones. One for each player.
# the CardDropZone decides where a card gets reparented to.

@onready var TopZone = $Layout/TopZone
@onready var BottomZone = $Layout/BottomZone


# currently there is no notion of an owner, and there is only a player
func play_card(card: Card, combatant: Combatant):
	if combatant.seat == Combatant.Seat.BOTTOM:
		card.reparent(BottomZone)
	else:
		card.reparent(TopZone)
