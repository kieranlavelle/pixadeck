class_name ApplyStatusAction
extends EffectAction

@export var status: CardStatusData

func apply(_event: BattleEvent, context: BattleContext, source: Card, targets: Array[Variant]) -> void:
	for target in targets:

		# currently we will only apply status' to cards
		if target is not Card:
			continue
		
		# no status associeated with action, can't apply
		if status == null:
			return

		var instance := CardStatusInstance.new()
		instance.data = status
		instance.applier = source
		instance.host = target
		instance.remaining_turns = status.duration

		var cmd := ApplyStatusCommand.new(source.owner_combatant, target, source, instance)
		await context.execute(cmd)
