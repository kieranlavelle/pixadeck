class_name Stats
extends VBoxContainer

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_value: Label = $HealthBar/HealthValue
@onready var mana_bar: ProgressBar = $ManaBar
@onready var mana_value: Label = $ManaBar/ManaValue

const MAX_HEALTH: int = 40
const MAX_MANA: int = 9

var current_health: int = MAX_HEALTH

# current_max_mana indicates what the max mana level
# the player has reached, with a ceiling of MAX_MANA.
var current_max_mana: int = 0

# current_mana is how much mana remains this turn out of
# the available current_max_mana.
var current_mana: int = 0

signal mana_changed(current: int, maximum: int)


func _ready() -> void:
	health_bar.max_value = MAX_HEALTH
	health_bar.step = 1
	mana_bar.max_value = MAX_MANA
	mana_bar.step = 1
	refresh_health(current_health)
	refresh_mana(current_mana)


# Called from the Combatant when a new turn starts.
func on_new_turn() -> void:
	if current_max_mana < MAX_MANA:
		current_max_mana += 1

	refresh_mana(current_max_mana)


func try_spend_mana(amount: int) -> bool:
	if amount <= 0 or amount > current_mana:
		return false

	current_mana -= amount
	mana_changed.emit(current_mana, current_max_mana)
	_update_mana_display()
	return true


func try_gain_mana(amount: int) -> int:
	if amount <= 0:
		return 0

	var gained: int = min(amount, current_max_mana - current_mana)
	if gained <= 0:
		return 0

	current_mana += gained
	mana_changed.emit(current_mana, current_max_mana)
	_update_mana_display()
	return gained


func refresh_mana(total_available: int) -> void:
	var old_value := current_mana
	current_mana = clampi(total_available, 0, current_max_mana)
	if old_value != current_mana:
		mana_changed.emit(current_mana, current_max_mana)
	_update_mana_display()


func refresh_health(total_available: int) -> void:
	current_health = clampi(total_available, 0, MAX_HEALTH)
	health_bar.value = current_health
	health_value.text = "Health %d/%d" % [current_health, MAX_HEALTH]


func _update_mana_display() -> void:
	mana_bar.value = current_mana
	mana_value.text = "Mana %d/%d" % [current_mana, MAX_MANA]
