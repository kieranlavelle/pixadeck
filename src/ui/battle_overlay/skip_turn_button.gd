extends Button


signal request_end_turn


func _on_pressed():
	request_end_turn.emit()
