class_name BattleContext
extends RefCounted


var event_queue: BattleEventQueue
var combatants: Array[Combatant] = []
var battle_manager: BattleManager
var battlefield: CardDropZone
var turn_manager: TurnManager

func _init(
	_event_queue: BattleEventQueue,
	_combatants: Array[Combatant],
	_battle_manager: BattleManager,
	_battlefield: CardDropZone,
	_turn_manager: TurnManager
) -> void:
	event_queue = _event_queue
	combatants = _combatants
	battle_manager = _battle_manager
	battlefield = _battlefield
	turn_manager = _turn_manager


func execute(command: Command) -> Command:
	return await command.execute(self)


func spend_mana(combatant: Combatant, amount: int) -> bool:
	if combatant.stats.current_mana < amount:
		return false
	combatant.stats.use_mana(amount)
	return true


func play_card(combatant: Combatant, card: Card) -> void:
	combatant.hand.play_card(card, battlefield)


func start_turn(combatant: Combatant) -> void:

	# In future we could make a TurnStatedCommand and make it interruptable.
	# that is not in scope for this code
	var turn_setup_event := BattleEvent.new(BattleEventType.TURN_SETUP_STARTED, combatant, combatant)
	await event_queue.enqueue(turn_setup_event)

	# turn setup steps
	combatant.stats.on_new_turn()

	var cmd := RequestDrawCardCommand.new(combatant, combatant.deck, combatant.hand)
	await execute(cmd)

	# makes cards interactable
	combatant.enable_player()

	await event_queue.enqueue(
		BattleEvent.new(BattleEventType.TURN_STARTED, combatant, combatant)
	)


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


func get_active_cards(event: BattleEvent) -> Array[Card]:
	var drop_zone = event.owner.get_tree().get_first_node_in_group("CardDropZone")
	return drop_zone.get_all_cards()


# This returns an array of all targets, which is all cards + combatants
func get_all_targets(event: BattleEvent) -> Array[Variant]:
	var targets = []
	targets.append_array(get_active_cards(event))
	targets.append_array(combatants)
	return targets


func apply_status(target_card: Card, instance: CardStatusInstance) -> void:

	var current_instance: CardStatusInstance
	var index: int
	for i in range(len(target_card.card_status_holder.statuses)):
		if target_card.card_status_holder.statuses[i].data.id == instance.data.id:
			# these are the same status type
			current_instance = target_card.card_status_holder.statuses[i]
			index = i
			break
	
	# can we just add the new status?
	if current_instance == null:
		target_card.add_status(instance)
		return
	
	# If there are two instances of a status, combine them
	var new_instance := current_instance.data.combine_instance(current_instance, instance)
	target_card.card_status_holder.statuses[index] = new_instance


func expire_card_statuses_for_owner(event: BattleEvent) -> void:
	var cards: Array[Card] = get_active_cards(event).filter(
		func(card: Card):
			return card.owner_combatant == event.owner
	)
	
	# find all cards with a status and remove them or decrement
	# their duration for cards owned by the owner. This is important
	# if you play a card that applies a status to their cards, they
	# will lower theirs on their turn.
	for card in cards:
		card.card_status_holder.decrement_statuses(event)


func has_room_on_battlefield(owner: Combatant) -> bool:
	return battlefield.can_add_card_to_zone(owner)
