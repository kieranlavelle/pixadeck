class_name Mana
extends Control


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

# tell's the mana what state to load in as
var available: bool = false


func _ready():
	if available:
		set_available()
	else:
		set_unavailable()


func set_available() -> void:
	available = true
	sprite.material.set_shader_parameter("desaturation", 0.0)


func set_unavailable() -> void:
	available = false
	sprite.material.set_shader_parameter("desaturation", 1.0)


func use_mana() -> void:
	available = false
	#animation_player.play("drain_mana")
	create_tween().tween_property(sprite.material, "shader_parameter/desaturation", 1.0, 0.75)
