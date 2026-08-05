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


# detects if the global position is inside the boardUI
func can_accept_drop_at(pos: Vector2) -> bool:
	return get_global_rect().has_point(pos)


func get_discard_animation_target(seat: Combatant.Seat) -> Vector2:
	if seat == Combatant.Seat.BOTTOM:
			return get_viewport_rect().size + Vector2(100, 100)

	return Vector2(-100, -100)


func get_battlefield_centre() -> Vector2:
	return get_global_rect().get_center()
