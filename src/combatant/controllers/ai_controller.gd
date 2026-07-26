class_name AIController
extends Node

signal ai_turn_ended


var combatant: Combatant
var _manager: BattleManager
var played_card: bool = false


func setup(_combatant: Combatant) -> void:
	combatant = _combatant


func play_turn() -> void:
	# as soon as card draw is finished we enter here. Wait a second so as to not look silly.
	await get_tree().create_timer(1).timeout

	played_card = false

	
	# look at the cards in hand, pick one, play it.
	var dropzone: CardDropZone = get_tree().get_first_node_in_group("CardDropZone")
	
	if len(combatant.hand.cards) > 0:
		# duplicate the array as ..hand.cards may alter while we play
		var cards: Array[Card] = combatant.hand.cards.duplicate()
		for card in cards:
			if played_card:
				break

			var command = PlayCardCommand.new(dropzone, combatant, card)
			await _manager._on_command(command, _command_callback)
			
	# if we got here, the AI has tried to play every card in hand
	ai_turn_ended.emit()

func _command_callback(command: PlayCardCommand):
	if command.success():
		played_card = true
