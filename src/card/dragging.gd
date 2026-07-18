extends BaseCardState

func enter() -> void:
	card.dragging_panel.visible = true


func exit() -> void:
	card.dragging_panel.visible = false


func handle_input(event: InputEvent) -> void:
	if event.is_action_released("left_mouse_button"):
		transition_to("IDLE")
