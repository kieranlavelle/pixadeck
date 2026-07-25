class_name CardStatusData
extends Resource

# For duration `-1` can be used to indicate that it never expires

@export var id: String
@export var display_name: String
@export var duration: int

# This function basically is a way for a status to intercept ANY card effect
# the base function allows all card effects to pass.
func can_resolve_effect(
	_effect: EffectData,
	_event: BattleEvent,
	_context: BattleContext,
	_instance: CardStatusInstance
) -> bool:
	return true
