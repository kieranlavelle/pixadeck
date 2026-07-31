class_name BattleContext
extends RefCounted


var event_queue: BattleEventQueue
var combatants: Array[Combatant] = []
var battle_manager: BattleManager
var board: Board
var turn_manager: TurnManager

func _init(
	_event_queue: BattleEventQueue,
	_combatants: Array[Combatant],
	_battle_manager: BattleManager,
	_board: Board,
	_turn_manager: TurnManager
) -> void:
	event_queue = _event_queue
	combatants = _combatants
	battle_manager = _battle_manager
	board = _board
	turn_manager = _turn_manager


func execute(command: Command) -> Command:
	if command is RootCommand:
		await event_queue.enqueue_root(command)
		return command

	assert(event_queue.has_active_root(), "commands must execute inside a Root")
	return await command.execute(self)


func spend_mana(combatant: Combatant, amount: int) -> bool:
	return combatant.stats.try_spend_mana(amount)


func gain_mana(combatant: Combatant, amount: int) -> int:
	return combatant.stats.try_gain_mana(amount)


func discard_card(
	combatant: Combatant,
	card: Variant,
	zone: int
) -> Card:
	var discarded_card: Card
	match zone:
		DiscardCardCommand.Zone.DECK:
			if card is not CardData:
				return null
			discarded_card = combatant.deck.discard_card(card, combatant)
		DiscardCardCommand.Zone.HAND:
			if card is not Card:
				return null
			discarded_card = combatant.hand.discard_card(card)
		DiscardCardCommand.Zone.BATTLEFIELD:
			if card is not Card:
				return null
			discarded_card = board.discard_card(card, combatant)

	if discarded_card == null:
		return null

	combatant.discard_pile.add_card(discarded_card.card_data)
	return discarded_card


# Advancing the turn emits TurnManager.turn_started. Commands should use this
# rather than reaching into the manager so turn progression has one gateway.
func advance_turn() -> void:
	turn_manager.advance_turn()


func deal_damage(target: Combatant, amount: int) -> void:
	if target == null:
		return
	target.stats.refresh_health(target.stats.current_health - amount)


# This function only checks mana requrements. Not turns, or anything else.
func has_mana_for_card(combatant: Combatant, card: Card) -> bool:
	if combatant.stats.current_mana >= card.card_data.card_cost:
		return true
	return false


# Synchronus, the corutine part is the animation
func draw_and_move_card(combatant: Combatant) -> Card:
	var card_drawn := combatant.deck.draw_card()
	var card_in_hand := combatant.hand.add_to_hand(card_drawn)
	await combatant.deck.animate_card_to_hand(card_in_hand)
	return card_in_hand


func get_active_cards() -> Array[Card]:
	return board.get_all_cards()


# This returns an array of all targets, which is all cards + combatants
func get_all_targets() -> Array[Variant]:
	var targets = []
	targets.append_array(get_active_cards())
	targets.append_array(combatants)
	return targets


func apply_card_status(
	source: Variant,
	target_card: Card,
	definition: CardStatusData,
	duration: int = CardStatusData.USE_DEFAULT_DURATION
) -> CardStatusInstance:
	var applied_duration := definition.default_duration if duration == CardStatusData.USE_DEFAULT_DURATION else duration
	var current: CardStatusInstance = target_card.card_status_holder.find_unique_by_definition(definition)

	if current == null or definition.stack_policy == CardStatusData.StackPolicy.SEPARATE_INSTANCES:
		var instance := CardStatusInstance.new()
		instance.definition = definition
		instance.source = source
		instance.host = target_card
		instance.remaining_turns = applied_duration
		target_card.add_status(instance)
		await _emit_status_fact(BattleEventType.STATUS_APPLIED, source, target_card, instance)
		return instance

	current.source = source
	match definition.stack_policy:
		CardStatusData.StackPolicy.UNIQUE_REFRESH:
			current.remaining_turns = applied_duration
			await _emit_status_fact(BattleEventType.STATUS_REFRESHED, source, target_card, current)
		CardStatusData.StackPolicy.STACK_DURATION:
			if applied_duration == -1:
				current.remaining_turns = -1
			elif current.remaining_turns != -1:
				current.remaining_turns += applied_duration
			await _emit_status_fact(BattleEventType.STATUS_DURATION_STACKED, source, target_card, current)
	return current


func expire_statuses_for_owner(owner: Combatant) -> void:
	for card in board.get_players_cards(owner):
		for status in card.card_status_holder.statuses.duplicate():
			# a value of -1 indicates it lasts forever.
			if status.remaining_turns == -1:
				continue
			status.remaining_turns -= 1
			await _emit_status_fact(BattleEventType.STATUS_DURATION_DECREMENTED, owner, card, status)
			if status.remaining_turns <= 0:
				card.remove_status(status)
				await _emit_status_fact(BattleEventType.STATUS_EXPIRED, owner, card, status)


func resolve_lifecycle_event(event: BattleEvent) -> void:
	if event.type == BattleEventType.STATUS_EXPIRY:
		await expire_statuses_for_owner(event.owner)


func _emit_status_fact(type: StringName, source: Variant, target: Card, status: CardStatusInstance) -> void:
	await event_queue.resolve_child(BattleEvent.new(
		type,
		target.owner_combatant,
		source,
		target,
		target,
		{"status": status, "remaining_turns": status.remaining_turns}
	))
