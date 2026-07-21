extends BaseCardState

func enter() -> void:
	card.show_tooltip()
	if card.is_locally_owned and not card.opponents_turn:
		card.hover_panel.visible = true
		card.z_index = 1
		var tween := card.create_tween().set_parallel(true)
		tween.tween_property(card.assets, "position:y", -20, 0.15)



func exit() -> void:
	card.hover_panel.visible = false
	card.hide_tooltip()
	
	card.z_index = 0
	var tween := card.create_tween().set_parallel(true)
	tween.tween_property(card.assets, "position:y", 0, 0.15)


func on_mouse_exited() -> void:
	transition_to("IDLE")


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse_button"):
		transition_to("CLICKED")
