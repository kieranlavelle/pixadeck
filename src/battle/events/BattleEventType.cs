namespace Pixadeck;

public static class BattleEventType
{
    // Turn-based events.
    public const string TurnSetupStarted = "turn_setup_started";
    public const string TurnStarted = "turn_started";
    public const string TurnEnding = "turn_ending";
    public const string StatusExpiry = "status_expiry";
    public const string TurnEnded = "turn_ended";
    // Card-based events.
    public const string CardPlayRequested = "card_play_requested";
    public const string CardPlayed = "card_played";
    public const string CardDrawRequested = "card_draw_requested";
    public const string CardDrawn = "card_drawn";
    public const string CardDiscarded = "card_discarded";
    // Resource facts.
    public const string ManaSpent = "mana_spent";
    public const string ManaGained = "mana_gained";
    public const string DamageRequested = "damage_requested";
    public const string DamageDealt = "damage_dealt";
    public const string ApplyStatusRequested = "apply_status_requested";
    public const string StatusApplied = "status_applied";
    public const string StatusRefreshed = "status_refreshed";
    public const string StatusDurationStacked = "status_duration_stacked";
    public const string StatusTriggerBlocked = "status_trigger_blocked";
    public const string StatusDurationDecremented = "status_duration_decremented";
    public const string StatusExpired = "status_expired";
}
