extends BaseCardState

func on_mouse_entered() -> void:
	# Played cards are passive battlefield controls, so hover is best handled by
	# Control's enter/exit signals instead of _gui_input. _gui_input only runs
	# while the card receives the event, which can leave the tooltip visible
	# after the cursor moves away.
	card.show_tooltip()


func on_mouse_exited() -> void:
	# This is the paired cleanup for played-card hover. Keeping it on the signal
	# path avoids the stale tooltip artifact caused by waiting for another input
	# event to be delivered to this card.
	card.hide_tooltip()

func exit() -> void:
	card.hide_tooltip()
