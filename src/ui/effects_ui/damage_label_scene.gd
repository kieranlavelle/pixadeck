class_name FloatingDamageLabel
extends Label

var move_direction: MoveDirection

enum MoveDirection { UP, DOWN }

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0


func take_damage(amount: int, position: Vector2, direction: MoveDirection):

	text = "-"+str(amount)
	reset_size() # we do this after we set the text

	# center the label
	position -= size * 0.5

	global_position = position
	var end_position := global_position

	# set the correct end pos according to the direction we want to move
	if direction == MoveDirection.UP:
		end_position += Vector2(-30, -40)
	else:
		end_position += Vector2(-30, 40)

	# start fully visible
	modulate.a = 1

	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0, 0.5)
	tween.parallel().tween_property(self, "global_position", end_position, 0.5)
	await tween.finished
