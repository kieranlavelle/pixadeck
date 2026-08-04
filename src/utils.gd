class_name Utils
extends RefCounted

static func wait_seconds(seconds: float) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	await tree.create_timer(seconds).timeout
