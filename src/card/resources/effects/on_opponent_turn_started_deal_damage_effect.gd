class_name OnOpponentTurnStartedDealDamageEffect
extends OnOpponentTurnStartedEffect

@export var amount: int = 1
@export var target_selector: TargetSelector


func resolve(event: BattleEvent, context: BattleContext, effect_card: Card) -> void:
	if target_selector == null:
		return

	for target in target_selector.select_targets(event, context, effect_card):
		if target is not Combatant:
			continue

		var command := DealDamageCommand.new(effect_card.owner_combatant, target, amount, effect_card)
		await context.execute(command)
