class_name StaggerCardStatus
extends CardStatusData


# Stagger blocks triggered effects from the card carrying this instance, but
# never blocks unrelated cards or battle facts.
func blocks_trigger(
	_trigger: CardEffect,
	source_card: Card,
	_event: BattleEvent,
	_context: BattleContext,
	instance: CardStatusInstance
) -> bool:
	return source_card == instance.host
