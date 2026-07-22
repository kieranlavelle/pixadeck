extends BaseCardState

var drag_offset: Vector2
var original_position: Vector2

func enter() -> void:
	card.dragging_panel.visible = true
	original_position = card.global_position
	
	drag_offset = card.get_global_mouse_position() - card.global_position


func exit() -> void:
	card.dragging_panel.visible = false
	card.playable_panel.visible = false


func handle_input(event: InputEvent) -> void:
	if event.is_action_released("left_mouse_button"):
		var dropzone = get_tree().get_first_node_in_group("CardDropZone")
		var rect = dropzone.get_global_rect()
		var drop_vector = card.get_global_mouse_position()
		
		if rect.has_point(drop_vector):
			card.request_transition.emit(card, "DRAGGING", "PLAYED", _on_played_transition)
		else:
			card.global_position = original_position
			transition_to("IDLE")
	
	if event is InputEventMouseMotion:
		card.global_position = card.get_global_mouse_position() - drag_offset
		var dropzone = get_tree().get_first_node_in_group("CardDropZone")
		var rect = dropzone.get_global_rect()
		var drop_vector = card.get_global_mouse_position()
		
		if rect.has_point(drop_vector):
			card.playable_panel.visible = true
		else:
			card.playable_panel.visible = false
	

func _on_played_transition(success: bool):
	if success:
		var dropzone = get_tree().get_first_node_in_group("CardDropZone")
		transition_to("PLAYED")
		card.play(dropzone)
	else:
		card.global_position = original_position
		transition_to("IDLE")
