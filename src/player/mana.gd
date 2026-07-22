extends HBoxContainer

@onready var mana_label: Label = $ManaLabel

const MANA_CRYSTAL_SCENE = preload("res://src/scenes/mana_crystals/mana_crystal.tscn")

var mana_crystals: Array[Mana] = []

const MAX_MANA: int = 9

# current_max_mana indicates what the max mana level
# the player has got to with a ceiling of MAX_MANA
var current_max_mana: int = 0

# current_mana is how much mana remains this turn out of
# the available current_max_mana. i.e 
# current_max_mana - spent_mana
var current_mana: int = 0

func _ready():
	for i in range(MAX_MANA):
		var instance = MANA_CRYSTAL_SCENE.instantiate()
		mana_crystals.append(instance)
		add_child(instance)


# called from the BasePlayer when a new turn starts
func on_new_turn() -> void:
	if current_max_mana < MAX_MANA:
		current_max_mana += 1
	current_mana = current_max_mana
	
	# update the hand scene to reflect the mana
	refresh_mana(current_mana)


func _format_mana_label() -> void:
	mana_label.text = str(current_mana) + "/" + str(current_max_mana)


func use_mana(amount: int) -> void:
	
	
	var from = current_mana - amount
	var crystals = mana_crystals.slice(from, current_mana)
	
	for crystal in crystals:
		crystal.use_mana()

	current_mana -= amount
	_format_mana_label()

func refresh_mana(total_available: int) -> void:
	
	current_mana = total_available
	_format_mana_label()
	
	var done: int = 0
	for crystal in mana_crystals:
		if done < total_available:
			crystal.set_available()
			done += 1
		else:
			crystal.set_unavailable()
