class_name AIController
extends Node

var combatant: Combatant


func setup(_combatant: Combatant) -> void:
	combatant = _combatant


func play_turn() -> void:
	# as soon as card draw is finished we enter here. Wait a second so as to not look silly.
	await get_tree().create_timer(1).timeout
	
	# look at the cards in hand, pick one, play it.
	var dropzone: CardDropZone = get_tree().get_first_node_in_group("CardDropZone")
	
	if len(combatant.hand.cards) > 0:
		for card in combatant.hand.cards:
			combatant._request_to_play_card(card, dropzone)
			
	# if we got here, the AI has tried to play every card in hand
	combatant.player_turn_ended.emit()
