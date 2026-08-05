class_name DealDamageCue
extends Cue


var target: Combatant
var amount: int
var context: BattleContext


func _init(_target: Combatant, _amount: int, _context: BattleContext):
	target = _target
	amount = _amount
	context = _context


func play() -> void:
	SfxPlayer.play_sound(Sounds.HIT_SOUND, -20)
	await context.effects_layer.take_damage_visuals(
		amount,
		target.stats.get_global_rect().get_center(),
		target
	)
