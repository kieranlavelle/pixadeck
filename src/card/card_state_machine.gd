class_name CardStateMachine
extends Node

var initial_state: String = "IDLE"


var states: Dictionary[String, Node] = {}
var current_state: Node


func _ready():
	var card = self.get_parent()
	for state_node in self.get_children():
		state_node.card = card
		state_node.state_machine = self
		states[state_node.name.to_upper()] = state_node
	
	# set the initial state
	current_state = states[initial_state]


func transition_to(state: String) -> void:
	
	print("moved from state: ", current_state.name, " to: ", state)
	
	var new_state = states[state]
	
	# perform exit for current state
	current_state.exit()
	
	# enter new state
	current_state = new_state
	new_state.enter()


func handle_input(event: InputEvent) -> void:
	current_state.handle_input(event)


func on_mouse_entered() -> void:
	current_state.on_mouse_entered()


func on_mouse_exited() -> void:
	current_state.on_mouse_exited()
