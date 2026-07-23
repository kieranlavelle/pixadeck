extends BaseCardState

const DRAG_THRESHOLD: int = 20
var mouse_pos_on_enter: Vector2
var is_mouse_button_down: bool = false


func enter() -> void:
	mouse_pos_on_enter = card.get_global_mouse_position()
	is_mouse_button_down = true
	
	card.clicked_panel.visible = true
	card.show_tooltip()


func exit() -> void:
	card.clicked_panel.visible = false
	card.hide_tooltip()


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse_button"):
		is_mouse_button_down = true
		mouse_pos_on_enter = card.get_global_mouse_position()
		return
	
	if event is InputEventMouseMotion and is_mouse_button_down:
		var current_pos := card.get_global_mouse_position()
		if mouse_pos_on_enter.distance_to(current_pos) > DRAG_THRESHOLD:
			transition_to("DRAGGING")
			return
	
	if event.is_action_released("left_mouse_button"):
		is_mouse_button_down = false
		mouse_pos_on_enter = Vector2.ZERO
	
	if event.is_action_pressed("right_mouse_button"):
		transition_to("IDLE")
		return


func wants_captured_input(event: InputEvent) -> bool:
	# While the click is held, capture motion/release outside the card so the
	# drag threshold works consistently. After release, only keep right-click
	# captured so a selected card can be cancelled from anywhere.
	return (
		(is_mouse_button_down and event is InputEventMouseMotion)
		or (is_mouse_button_down and event.is_action_released("left_mouse_button"))
		or event.is_action_pressed("right_mouse_button")
	)
