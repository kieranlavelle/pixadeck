class_name EffectsLayer
extends Control

var damage_label_scene = preload("res://src/ui/effects_ui/damage_label_scene.tscn")



func take_damage_visuals(amount: int, location: Vector2, target: Combatant):
	var label: FloatingDamageLabel = damage_label_scene.instantiate()
	var direction: FloatingDamageLabel.MoveDirection
	
	if target.seat == Combatant.Seat.TOP:
		direction = FloatingDamageLabel.MoveDirection.DOWN
	else:
		direction = FloatingDamageLabel.MoveDirection.UP
	
	add_child(label)
	await label.take_damage(amount, location, direction)
	label.queue_free()
	
