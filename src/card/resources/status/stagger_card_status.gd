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
