class_name RootCommand
extends Command

signal completed

var is_completed := false

func finish() -> void:
	is_completed = true
	completed.emit()
