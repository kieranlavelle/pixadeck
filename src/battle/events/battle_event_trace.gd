class_name EventTrace
extends Node

var _trace: Array = []

enum TraceEventState { STARTED, ENDED }

class TraceEvent:
	var id: int
	var state: TraceEventState
	var event: BattleEvent


func event_started(event: BattleEvent) -> TraceEvent:
	var trace_id: int = _trace.size()
	var trace_event := TraceEvent.new()
	trace_event.id = trace_id
	trace_event.state = TraceEventState.STARTED
	trace_event.event = event
	_trace.append(trace_event)

	return trace_event


func event_ended(event: BattleEvent) -> TraceEvent:
	var trace_id: int = _trace.size()
	var trace_event := TraceEvent.new()
	trace_event.id = trace_id
	trace_event.state = TraceEventState.ENDED
	trace_event.event = event
	_trace.append(trace_event)

	return trace_event