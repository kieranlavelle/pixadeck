class_name OnOpponentTurnStartedApplyStatusEffect
extends OnOpponentTurnStartedEffect

@export var status: CardStatusData
@export var target_selector: TargetSelector


func resolve(event: BattleEvent, context: BattleContext, source: Card) -> void:
	if status == null or target_selector == null:
		return

	for target in target_selector.select_targets(event, context, source):
		if target is not Card:
			continue

		var command := ApplyStatusCommand.new(
			source.owner_combatant,
			target,
			source,
			status,
			status.default_duration
		)
		await context.execute(command)
