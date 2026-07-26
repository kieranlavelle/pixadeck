class_name PlayCardCommand
extends Command

var battlefield: CardDropZone
var owner: Combatant
var card: Card


func _init(_battlefield: CardDropZone, _owner: Combatant, _card: Card):
	battlefield = _battlefield
	owner = _owner
	card = _card
