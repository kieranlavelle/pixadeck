class_name BattleEventType
extends RefCounted


# Turn based events
const TURN_SETUP_STARTED := &"turn_setup_started"
const TURN_STARTED := &"turn_started"

# emit just before this users turn ends, querying the current user could
# give you the wrong info.
const TURN_ENDING := &"turn_ending"

# Deterministic maintenance after TURN_ENDING triggers and before TURN_ENDED.
const STATUS_EXPIRY := &"status_expiry"

# emited after game logic for who's turn it is has been incremented and this
# users turn has ended.
const TURN_ENDED := &"turn_ended"

# Card based events
const CARD_PLAY_REQUESTED := &"card_play_requested"
const CARD_PLAYED := &"card_played"
const CARD_DRAW_REQUESTED := &"card_draw_requested"
const CARD_DRAWN := &"card_drawn"
const CARD_DISCARDED := &"card_discarded"

# Resource facts
const MANA_SPENT := &"mana_spent"
const MANA_GAINED := &"mana_gained"

const DAMAGE_REQUESTED := &"damage_requested"
const DAMAGE_DEALT := &"damage_dealt"

const APPLY_STATUS_REQUESTED := &"apply_status_requested"
const STATUS_APPLIED := &"status_applied"
const STATUS_REFRESHED := &"status_refreshed"
const STATUS_DURATION_STACKED := &"status_duration_stacked"
const STATUS_TRIGGER_BLOCKED := &"status_trigger_blocked"
const STATUS_DURATION_DECREMENTED := &"status_duration_decremented"
const STATUS_EXPIRED := &"status_expired"
