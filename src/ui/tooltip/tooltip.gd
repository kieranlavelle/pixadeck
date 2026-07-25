# res://src/scenes/tooltip.gd
extends PanelContainer

@onready var title = %Title
@onready var cost = %Cost
@onready var description = %Description
@onready var header = %Header
@onready var divider = %Divider


func setup(title_v: String, description_v: String, cost_v: int = -1) -> void:
	
	# effect tooltips will have a title and a description
	# card tooltips will have a > -1 cost
	title.text = title_v
	description.text = description_v
	
	if cost_v > -1:
		
		# set the correct theme
		theme.default_font_size = 5
		
		cost.text = str(cost_v)
		cost.show()
		divider.show()
	else:
		theme.default_font_size = 4
		cost.hide()
		divider.hide()
