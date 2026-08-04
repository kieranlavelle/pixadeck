class_name CardCastingCue
extends Cue


var source: Card


func _init(_source: Card):
	source = _source

func play() -> void:
	source.play_effect_anticipation()

func finish() -> void:
	await source.release_effect_anticipation()
