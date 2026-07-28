class_name StaggerCardStatus
extends CardStatusData


# stagger prevents ANY host from resolving ANY effect
func can_resolve_effect(
	_effect: EffectData,
	_event: BattleEvent,
	_context: BattleContext,
	_instance: CardStatusInstance
) -> bool:
	return false


func should_tick(event: BattleEvent, instance: CardStatusInstance) -> bool:

	# Only decrement on turn_end
	if event.type != BattleEventType.TURN_ENDED:
		return false
	
	# Tick after the opponent who does not own the host card
	# turns end
	return event.owner == instance.host.owner_combatant


func combine_instance(current: CardStatusInstance, other: CardStatusInstance) -> CardStatusInstance:
	var new := CardStatusInstance.new()
	new.data = self
	new.host = current.host
	new.applier = other.applier
	new.remaining_turns = current.remaining_turns + other.remaining_turns
	return new
