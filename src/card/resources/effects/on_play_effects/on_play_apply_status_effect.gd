class_name OnPlayApplyStatusEffect
extends OnPlayEffect

@export var status: CardStatusData
@export var target_selector: TargetSelector


func resolve(event: BattleEvent, context: BattleContext, effect_card: Card) -> void:
	if status == null or target_selector == null:
		return

	for target in target_selector.select_targets(event, context, effect_card):
		if target is not Card:
			continue

		var command := ApplyStatusCommand.new(
			effect_card.owner_combatant,
			target,
			effect_card,
			status,
			status.default_duration
		)
		await context.execute(command)
