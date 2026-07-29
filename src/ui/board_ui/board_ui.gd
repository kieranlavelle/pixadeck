class_name BoardUI
extends Control

@onready var TopZone = $Layout/TopZone
@onready var BottomZone = $Layout/BottomZone

const MAX_CARDS_PER_ZONE = 8

func _on_card_placed(card: Card, seat: Combatant.Seat):
	match seat:
		Combatant.Seat.TOP:
			card.reparent(TopZone)
		Combatant.Seat.BOTTOM:
			card.reparent(BottomZone)


func _on_card_removed(card: Card, seat: Combatant.Seat):
	# A battlefield discard has no visible destination yet, so do not detach the
	# runtime card. Queue it while it remains parented to its board zone.
	card.queue_free()


# detects if the global position is inside the boardUI
func can_accept_drop_at(pos: Vector2) -> bool:
	return get_global_rect().has_point(pos)
