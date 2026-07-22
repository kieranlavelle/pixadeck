extends Label

func _ready() -> void:
	visible = false


func display_text(text_to_show: String) -> void:
	modulate.a = 1
	text = text_to_show


func clear_text() -> void:
	text = ""


func fade_and_hide() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0, 0.4).finished.connect(func(): 
		visible = false
		clear_text()
	)
