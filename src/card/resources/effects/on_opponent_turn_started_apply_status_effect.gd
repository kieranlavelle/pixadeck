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

		var instance := CardStatusInstance.new()
		instance.data = status
		instance.applier = source
		instance.host = target
		instance.remaining_turns = status.duration

		var command := ApplyStatusCommand.new(source.owner_combatant, target, source, instance)
		await context.execute(command)
