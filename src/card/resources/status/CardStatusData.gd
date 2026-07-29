class_name CardStatusData
extends Resource

# For duration `-1` can be used to indicate that it never expires

@export var id: String
@export var display_name: String
@export var duration: int = 1

# This function basically is a way for a status to intercept ANY card effect
# the base function allows all card effects to pass.
func can_resolve_effect(
	_effect: CardEffect,
	_event: BattleEvent,
	_context: BattleContext,
	_instance: CardStatusInstance
) -> bool:
	return true


func should_tick(_event: BattleEvent, _instance: CardStatusInstance) -> bool:
	return true


# As CardStatusData does not hold any copies of instance it just has to take
# in two instances that are created by this type of CardStatusData and combine them,
# then return a new status
func combine_instance(_current: CardStatusInstance, other: CardStatusInstance) -> CardStatusInstance:
	push_error("%s must implement combine_instance()" % display_name)
	return other
