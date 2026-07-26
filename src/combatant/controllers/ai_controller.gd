class_name AIController
extends Node

signal ai_turn_ended


var combatant: Combatant


func setup(_combatant: Combatant) -> void:
	combatant = _combatant


func play_turn() -> void:
	# as soon as card draw is finished we enter here. Wait a second so as to not look silly.
	await get_tree().create_timer(1).timeout
	
	# look at the cards in hand, pick one, play it.
	var dropzone: CardDropZone = get_tree().get_first_node_in_group("CardDropZone")
	
	if len(combatant.hand.cards) > 0:
		# duplicate the array as ..hand.cards may alter while we play
		var hand_copy: Array[Card] = combatant.hand.cards.duplicate()
		for card in hand_copy:
			await combatant._request_to_play_card(card, dropzone)
			
	# if we got here, the AI has tried to play every card in hand
	ai_turn_ended.emit()
