extends BaseCardState

const DRAG_THRESHOLD: int = 20
var mouse_pos_on_enter: Vector2


func enter() -> void:
	mouse_pos_on_enter = card.get_global_mouse_position()
	
	card.clicked_panel.visible = true
	card.show_tooltip()


func exit() -> void:
	card.clicked_panel.visible = false
	card.hide_tooltip()


func handle_input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion and mouse_pos_on_enter:
		var current_pos := card.get_global_mouse_position()
		if mouse_pos_on_enter.distance_to(current_pos) > DRAG_THRESHOLD:
			transition_to("DRAGGING")
			return
	
	# as we're inside this loop we did not go over the drag threshold
	# so we should reset mouse pos. This will mean that to drag they would
	# have to deselect? If we re-enter clicked state we will end up in a constant
	# loop of entering clicked
	if event.is_action_released("left_mouse_button"):
		mouse_pos_on_enter = Vector2.ZERO
	
	if event.is_action_pressed("right_mouse_button"):
		transition_to("IDLE")
		return
