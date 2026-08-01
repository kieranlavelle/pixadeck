using System;
using System.Collections.Generic;

namespace Pixadeck;

public sealed class BattleEvent
{
    public BattleEvent(
        string type,
        Combatant? owner = null,
        object? source = null,
        object? target = null,
        Card? card = null,
        Dictionary<string, object>? payload = null)
    {
        Type = type;
        Owner = owner;
        Source = source;
        Target = target;
        Card = card;
        Payload = payload ?? [];
    }

    public string Type { get; }
    public Combatant? Owner { get; }
    public object? Source { get; }
    public object? Target { get; }
    public Card? Card { get; }
    public Dictionary<string, object> Payload { get; }
    public bool IsCancelled { get; private set; }
    public string CancelledReason { get; private set; } = string.Empty;

    public void Cancel(string reason = "")
    {
        IsCancelled = true;
        CancelledReason = reason;
    }
}
