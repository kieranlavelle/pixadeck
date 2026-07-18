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


func handle_input(event: InputEvent) -> void:
	pass


func on_mouse_entered() -> void:
	pass


func on_mouse_exited() -> void:
	pass
