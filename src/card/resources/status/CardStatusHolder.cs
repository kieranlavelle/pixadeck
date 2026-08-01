using System;
using System.Collections.Generic;

namespace Pixadeck;

public sealed class CardStatusHolder
{
    private readonly List<CardStatusInstance> _statuses = [];

    public Card Host { get; set; } = null!;
    public IReadOnlyList<CardStatusInstance> Statuses => _statuses;

    public void AddStatus(CardStatusInstance status) => _statuses.Add(status);
    public void RemoveStatus(CardStatusInstance status) => _statuses.Remove(status);

    // UniqueRefresh and StackDuration require at most one matching instance.
    // SeparateInstances must not use this lookup because each is timed separately.
    public CardStatusInstance? FindUniqueByDefinition(CardStatusData definition)
    {
        CardStatusInstance? found = null;
        foreach (var status in _statuses)
        {
            if (status.Definition != definition)
            {
                continue;
            }

            if (found is not null)
            {
                throw new InvalidOperationException($"Duplicate instances found for {definition.Id}.");
            }

            found = status;
        }

        return found;
    }

    public CardStatusInstance? BlocksTrigger(
        CardEffect trigger,
        Card sourceCard,
        BattleEvent battleEvent,
        BattleContext context)
    {
        foreach (var status in _statuses)
        {
            if (status.BlocksTrigger(trigger, sourceCard, battleEvent, context))
            {
                return status;
            }
        }

        return null;
    }
}
