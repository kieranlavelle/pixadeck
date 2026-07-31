class_name DealDamageCommand
extends Command

var owner: Combatant
var target: Combatant
var amount: int
var source: Variant

func _init(_owner: Combatant, _target: Combatant, _amount: int, _source: Variant):
	owner = _owner
	target = _target
	amount = _amount
	source = _source


func execute(context: BattleContext) -> DealDamageCommand:

	if target == null:
		reason = "No target"
		is_success = false
		return self

	if amount <= 0:
		reason = "non-positive value for damage amount"
		is_success = false
		return self

	var deal_damage_request := BattleEvent.new(
		BattleEventType.DAMAGE_REQUESTED,
		owner,
		source,
		target,
		source,
		{
			"amount": amount,
		}
	)
	await context.event_queue.resolve_child(deal_damage_request)

	if deal_damage_request.cancelled:
		reason = deal_damage_request.cancelled_reason
		is_success = false
		return self

	context.deal_damage(target, amount)

	var damage_dealt := BattleEvent.new(
		BattleEventType.DAMAGE_DEALT,
		owner,
		source,
		target,
		source,
		{
			"amount": amount,
		}
	)
	await context.event_queue.resolve_child(damage_dealt)

	is_success = true
	return self
