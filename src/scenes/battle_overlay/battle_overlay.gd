extends CanvasLayer


@onready var TextDisplayNode = $TextDisplay

func _ready():
	visible = false


func display_text(text: String) -> void:
	TextDisplayNode.modulate.a = 1
	TextDisplayNode.text = text


func clear_text() -> void:
	TextDisplayNode.text = ""


func clear_and_hide() -> void:
	visible = false
	TextDisplayNode.text = ""


func fade_and_hide() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(TextDisplayNode, "modulate:a", 0, 0.4).finished.connect(func(): 
		visible = false
		TextDisplayNode.text = ""
	)

func _on_turn_start(player_id: int):
	# for now, the actul player will always be player 0 as they're first in the tree
	if player_id == 0:
		display_text("Your turn!")
	else:
		display_text("Opponents turn!")
	visible = true
	
	# clear the text after 1 second
	await get_tree().create_timer(1.2).timeout
	fade_and_hide()
