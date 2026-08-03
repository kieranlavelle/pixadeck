class_name DebugTrace
extends RefCounted

var _traces: Array = []
var _stack: Array = []

enum TraceState { Started, Ended }

class TraceEvent:
	var command: RootCommand
	var parent: TraceEvent
	var event: BattleEvent
	var trace_state: TraceState
	var tree_depth: int

	func _init(_command: RootCommand, _parent: TraceEvent, _event: BattleEvent, _state: TraceState, _depth: int):
		command = _command
		parent = _parent
		event = _event
		trace_state = _state
		tree_depth = _depth

	func to_print_string() -> String:
		if command == null:
			return _event_to_string()
		return _root_to_string()

	func _root_to_string() -> String:
		return "Root: %s %s" % [command.get_script().get_global_name(), TraceState.keys()[trace_state]]

	func _event_to_string() -> String:
			var card_name: String = "null"
			# GDScript doesn't have the `?.` null-conditional operator yet,
			# so we chain truthy checks safely.
			if event and event.get("card") and event.card.get("card_data"):
				card_name = event.card.card_data.card_name

			var event_type: String = ""
			if event and event.get("type"):
				event_type = str(event.type).to_upper()

			var indent: String = " ".repeat(tree_depth * 4)

			# TraceState.keys()[state] neatly returns "STARTED" or "ENDED"
			var state_str: String = TraceState.keys()[trace_state]

			return "%s event> %s %s (card: %s)" % [indent, event_type, state_str, card_name]

func begin_root(command: RootCommand) -> void:
	if len(_stack) > 0:
		push_warning("Tried to begin a new root when one already exists")
		return

	var event := TraceEvent.new(command, null, null, TraceState.Started, 0)
	_traces.append(event)
	_stack.append(event)


func end_root(command: RootCommand) -> void:
	var parent: Variant = _stack.back()
	if (parent == null || parent.command != command):
		push_warning("Tried to end a root when one does not exist or the command does not match the one that does exist")
		return

	_stack.pop_back()
	var event := TraceEvent.new(command, parent.parent, null, TraceState.Ended, parent.tree_depth)
	_traces.append(event)


func begin_event(event: BattleEvent) -> void:
	var parent: Variant = _stack.back()
	if (parent == null):
		push_warning("Tried to begin event %s when there is no active root." % event.type)
		return

	var trace := TraceEvent.new(null, parent, event, TraceState.Started, parent.tree_depth + 1)
	_stack.append(trace)
	_traces.append(trace)


func end_event(event: BattleEvent) -> void:
	var parent: Variant = _stack.back()
	if (parent == null):
		push_warning("Tried to end event %s but there is not active event" % event.type)
		return

	if (parent.event.type != event.type):
		push_warning("Tried to end event %s but it does not match the active event %s." % [event.type, parent.event.type])
		return

	var trace := TraceEvent.new(null, parent, event, TraceState.Ended, parent.tree_depth)
	_stack.pop_back()
	_traces.append(trace)


func _get_events_for_root(command: RootCommand) -> Array[TraceEvent]:

	var events: Array[TraceEvent] = [];

	var in_root := false
	for event in _traces:

		if (in_root):
			events.append(event)
			if event.command == command and event.trace_state == TraceState.Ended:
				return events
		else:
			# skip events we're not interested in
			if event.command == null or event.command != command:
				continue

			if event.command == command and event.trace_state == TraceState.Started:
				in_root = true

	return events


func root_to_string(command: RootCommand) -> String:
	var strings: PackedStringArray = [];
	for event in _get_events_for_root(command):
		strings.append(event.to_print_string())

	return "\n".join(strings)
