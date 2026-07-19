extends BaseCardState

func handle_input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		var mouse := card.get_global_mouse_position()
		var card_rect := card.get_global_rect()
		if card_rect.has_point(mouse):
			if not card.tooltip_stack.visible:
				card.show_tooltip()
		else:
			if card.tooltip_stack.visible:
				card.hide_tooltip()

func exit() -> void:
	card.hide_tooltip()
