class_name CardStateMachine
extends Node

const INITIAL_STATE: String = "IDLE"
const PLAYER_TURN_ONLY_STATES: Array[String] = ["DRAGGING", "CLICKED", "PLAYED"]


var states: Dictionary[String, BaseCardState] = {}
var current_state: BaseCardState
var card: Card


func _ready():
	card = self.get_parent()
	for child in self.get_children():
		var state_node := child as BaseCardState
		if state_node == null:
			continue
		state_node.card = card
		state_node.state_machine = self
		states[state_node.name.to_upper()] = state_node
	
	# set the initial state
	current_state = states[INITIAL_STATE]


func transition_to(state: String) -> void:	
	# we can never move another players cards to these states
	if not card.is_locally_owned and PLAYER_TURN_ONLY_STATES.has(state):
		return
	
	# cant move your card into these states on your opponents turn
	if card.opponents_turn and PLAYER_TURN_ONLY_STATES.has(state):
		return
	
	var new_state: BaseCardState = states[state]
	
	# perform exit for current state
	current_state.exit()
	
	# enter new state
	current_state = new_state
	new_state.enter()


func handle_input(event: InputEvent) -> void:
	current_state.handle_input(event)


# Used by Card._input while a state has captured the mouse.
# This keeps drag/cancel/release logic in the active state instead of spreading
# card-state decisions across Control callbacks.
func wants_captured_input(event: InputEvent) -> bool:
	return current_state.wants_captured_input(event)


func on_mouse_entered() -> void:
	current_state.on_mouse_entered()


func on_mouse_exited() -> void:
	current_state.on_mouse_exited()
