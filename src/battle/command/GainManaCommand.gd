class_name GainManaCommand
extends Command

var owner: Combatant
var amount: int
var source: Variant


func _init(_owner: Combatant, _amount: int, _source: Variant = null):
	owner = _owner
	amount = _amount
	source = _source if _source != null else _owner


func execute(context: BattleContext) -> GainManaCommand:
	if owner == null:
		reason = "No combatant to gain mana"
		return self

	var gained := context.gain_mana(owner, amount)
	if gained == 0:
		reason = "Mana amount must be positive and there must be room below the mana cap"
		return self

	await context.event_queue.enqueue(BattleEvent.new(
		BattleEventType.MANA_GAINED,
		owner,
		source,
		owner,
		null,
		{"amount": gained}
	))
	is_success = true
	return self
