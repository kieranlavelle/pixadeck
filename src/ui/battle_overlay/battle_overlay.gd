extends CanvasLayer

signal request_end_turn

@onready var TextDisplayNode = $TextDisplay
@onready var EndTurnButton: Button = $EndTurnButton

func _ready():
	hide_end_turn_button()
	
	# re-emit childs signal
	EndTurnButton.request_end_turn.connect(request_end_turn.emit)

func _on_turn_start(player: Combatant):
	# for now, the actul player will always be player 0 as they're first in the tree
	if player.is_local_player:
		TextDisplayNode.display_text("Your turn!")
	else:
		TextDisplayNode.display_text("Opponents turn!")
	TextDisplayNode.set_visible(true)
	
	# clear the text after 1 second
	await get_tree().create_timer(1.2).timeout
	TextDisplayNode.fade_and_hide()


func show_end_turn_button():
	EndTurnButton.disabled = false
	EndTurnButton.visible = true


func hide_end_turn_button():
	EndTurnButton.disabled = true
	EndTurnButton.visible = false
