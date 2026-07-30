class_name CardStatusData
extends Resource

# A duration of -1 never expires. Definitions are shared resources; all
# per-application state belongs on CardStatusInstance.
# `USE_DEFAULT_DURATION` is only an application-time sentinel: it means the
# caller omitted a duration, so apply this definition's default instead.
const USE_DEFAULT_DURATION: int = -2

# `UNIQUE_REFRESH`: retain one instance and reset duration.
# `STACK_DURATION`: retain one instance and add duration.
# `SEPARATE_INSTANCES`: append independently timed instances.
enum StackPolicy {
	UNIQUE_REFRESH,
	STACK_DURATION,
	SEPARATE_INSTANCES,
}

@export var id: StringName
@export var display_name: String
@export var default_duration: int = 1
@export var stack_policy: StackPolicy = StackPolicy.UNIQUE_REFRESH

# Return true only when this status blocks this specific triggered effect.
func blocks_trigger(
	_trigger: CardEffect,
	_source_card: Card,
	_event: BattleEvent,
	_context: BattleContext,
	_instance: CardStatusInstance
) -> bool:
	return false
