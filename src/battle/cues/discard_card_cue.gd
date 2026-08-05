class_name DiscardCardCue
extends Cue

var card: Card
var battlefield_center: Vector2
var discard_destination: Vector2

func _init(_card: Card, _battlefield_center: Vector2, _discard_destination: Vector2):
	card = _card
	battlefield_center = _battlefield_center
	discard_destination = _discard_destination


func play() -> void:
	#SfxPlayer.play_sound(Sounds.HIT_SOUND, -10)
	await card.play_discard_animation(battlefield_center, discard_destination)
