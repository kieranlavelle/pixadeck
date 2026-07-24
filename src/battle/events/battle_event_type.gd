class_name BattleEventType
extends RefCounted

# Note on current events
# For now there are only a small set of battle events. These are events
# that will be used by the current small set of cards.

# Turn based events
const TURN_STARTED := &"turn_started"
const TURN_ENDED := &"turn_ended"

# Card based events
const CARD_PLAY_REQUESTED := &"card_play_requested"
const CARD_PLAYED := &"card_played"
const CARD_DRAW_REQUESTED := &"card_draw_requested"
const CARD_DRAWN := &"card_drawn"

const DAMAGE_REQUESTED := &"damage_requested"
const DAMAGE_DEALT := &"damage_dealt"

const STATUS_APPLIED := &"status_applied"
