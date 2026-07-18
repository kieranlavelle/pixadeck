extends BaseCardState

func enter() -> void:
	card.hover_panel.visible = true
	card.show_tooltip()


func exit() -> void:
	card.hover_panel.visible = false
	card.hide_tooltip()


func on_mouse_exited() -> void:
	transition_to("IDLE")


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse_button"):
		transition_to("CLICKED")
