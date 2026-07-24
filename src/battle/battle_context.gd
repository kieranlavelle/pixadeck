class_name BattleContext
extends RefCounted


var event_queue: BattleEventQueue
var combatants: Array[Combatant] = []
var battle_manager: BattleManager

func _init(
	_event_queue: BattleEventQueue,
	_combatants: Array[Combatant],
	_battle_manager: BattleManager
) -> void:
	event_queue = _event_queue
	combatants = _combatants
	battle_manager = _battle_manager


func spend_mana(combatant: Combatant, amount: int) -> bool:
	if combatant.stats.current_mana < amount:
		return false
	combatant.stats.use_mana(amount)
	return true


func deal_damage(target: Combatant, amount: int) -> void:
	if target == null:
		return
	target.stats.refresh_health(target.stats.current_health - amount)


# This function only checks mana requrements. Not turns, or anything else.
func can_play_card(combatant: Combatant, card: Card) -> bool:
	if combatant.stats.current_mana >= card.card_data.card_cost:
		return true
	return false


func request_play_card(combatant: Combatant, card: Card, zone: CardDropZone) -> bool:
	var request_event := BattleEvent.new(
		BattleEventType.CARD_PLAY_REQUESTED,
		combatant,
		combatant,
		zone,
		card
	)
	await event_queue.dispatch(request_event)

	if request_event.cancelled:
		return false

	if not spend_mana(combatant, card.card_data.card_cost):
		return false

	combatant.hand.play_card(card, zone)

	var played_card_event := BattleEvent.new(
		BattleEventType.CARD_PLAYED,
		combatant,
		combatant,
		zone,
		card
	)
	await event_queue.dispatch(played_card_event)

	return true


func draw_card(combatant: Combatant) -> Card:
	var draw_card_event := BattleEvent.new(
		BattleEventType.CARD_DRAW_REQUESTED,
		combatant,
		combatant.deck,
	)
	await event_queue.dispatch(draw_card_event)

	if draw_card_event.cancelled:
		return null
	
	var card: Card = await combatant.deck.draw_card()
	if card != null:
		var draw_event := BattleEvent.new(BattleEventType.CARD_DRAWN, combatant, combatant.deck, combatant.hand, card)
		await event_queue.dispatch(draw_event)
		return card

	return null