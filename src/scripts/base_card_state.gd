class_name BaseCardState
extends Node

var card: TextureRect
var state_machine: CardStateMachine

func transition_to(state: String) -> void:
	state_machine.transition_to(state)


func enter() -> void:
	pass


func exit() -> void:
	pass


func update() -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


# States return true here when they have captured an interaction that must keep
# receiving mouse events after the cursor leaves the card. Most states return
# false and only handle card-local _gui_input events.
func wants_captured_input(_event: InputEvent) -> bool:
	return false


func on_mouse_entered() -> void:
	pass


func on_mouse_exited() -> void:
	pass
