class_name EventTrace
extends RefCounted

var _roots: Array[RootEvent] = []

var current_root: RootEvent
var current_indentation: int = 0

enum TraceState { STARTED, ENDED }

class RootEvent:
	var command: Command
	var events: Array[TraceEvent] = []

class TraceEvent:
	var state: TraceState
	var event: BattleEvent
	var indentation: int

	func printable_string() -> String:

		var c_name := "null"
		if event.card is Card:
			c_name = event.card.card_data.card_name

		var format := "%s event> %s %s (card: %s)"
		return format % [_create_indents(indentation), event.type.to_upper(), TraceState.keys()[state], c_name]


	func _create_indents(amnt: int) -> String:
		var val = ""
		for i in range(amnt):
			val += " "
		return val


func start_root(cmd: Command):
	if current_root:
		print("There was already an active root when trying to start one")
		return

	current_root = RootEvent.new()
	current_root.command = cmd
	current_indentation += 4


func end_root(cmd: Command):
	if current_root == null:
		print("There is no root to end on end_root call")
		return

	if current_root.command != cmd:
		print("The command on the current root does not match the supplied command to end_root")
		return

	_roots.append(current_root)
	_print_root(current_root)
	current_root = null
	current_indentation = 0


func event_started(event: BattleEvent) -> TraceEvent:
	var trace_event := TraceEvent.new()
	trace_event.state = TraceState.STARTED
	trace_event.event = event
	trace_event.indentation = current_indentation
	current_root.events.append(trace_event)

	current_indentation += 4
	return trace_event


func event_ended(event: BattleEvent) -> TraceEvent:
	current_indentation -= 4

	var trace_event := TraceEvent.new()
	trace_event.state = TraceState.ENDED
	trace_event.event = event
	trace_event.indentation = current_indentation
	current_root.events.append(trace_event)

	return trace_event


func _print_root(event: RootEvent):
	var cls_name: StringName = event.command.get_script().get_global_name()
	print("ROOT: ", cls_name, " STARTED:")
	for child_event in event.events:
		print(child_event.printable_string())
	print("ROOT: ", cls_name, " Ended")
