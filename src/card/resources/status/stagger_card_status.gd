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
