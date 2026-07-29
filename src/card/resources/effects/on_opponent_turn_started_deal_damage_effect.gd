class_name OnOpponentTurnStartedDealDamageEffect
extends OnOpponentTurnStartedEffect

@export var amount: int = 1
@export var target_selector: TargetSelector


func resolve(event: BattleEvent, context: BattleContext, source: Card) -> void:
	if target_selector == null:
		return

	for target in target_selector.select_targets(event, context, source):
		if target is not Combatant:
			continue

		var command := DealDamageCommand.new(source.owner_combatant, target, amount, source)
		await context.execute(command)
