class_name CardDropZone
extends Control

# The card dropzone technically has two zones. One for each player.
# the CardDropZone decides where a card gets reparented to.

@onready var OpponentZone = $OpponentGrid
@onready var PlayerZone = $PlayerGrid


# currently there is no notion of an owner, and there is only a player
func play_card(card: Card, player: BasePlayer):
	if player.is_local_player:
		card.reparent(PlayerZone)
	else:
		card.reparent(OpponentZone)
