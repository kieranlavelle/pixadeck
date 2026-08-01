using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;

namespace Pixadeck;

public partial class BattleEventQueue : Node
{
    private readonly Queue<RootCommand> _queue = new();
    private readonly BattleEventTrace _trace = new();
    private bool _isResolving;

    public event Action<BattleEvent>? EventDispatched;
    public event Action<BattleEvent>? EventResolved;
    public BattleContext Context { get; set; } = null!;
    public bool HasActiveRoot => _isResolving;

    public async Task EnqueueRootAsync(RootCommand root)
    {
        _queue.Enqueue(root);
        if (_isResolving)
        {
            // This root is queued behind the active root; wait until the drain
            // reaches it rather than resolving command trees concurrently.
            await root.Completion;
            return;
        }

        await DrainRootsAsync();
    }

    public async Task ResolveChildAsync(BattleEvent battleEvent)
    {
        // Child events are valid only while resolving a root command.
        if (!_isResolving)
        {
            throw new InvalidOperationException("Child events require an active root command.");
        }

        await ResolveEventAsync(battleEvent);
    }

    private async Task ResolveEventAsync(BattleEvent battleEvent)
    {
        _trace.EventStarted(battleEvent);
        EventDispatched?.Invoke(battleEvent);

        // Status expiry is deterministic maintenance, never a reaction window.
        if (battleEvent.Type != BattleEventType.StatusExpiry)
        {
            foreach (var trigger in CollectTriggersSnapshot(battleEvent))
            {
                await ResolveTriggerAsync(trigger, battleEvent);
            }
        }

        await Context.ResolveLifecycleEventAsync(battleEvent);
        EventResolved?.Invoke(battleEvent);
        _trace.EventEnded(battleEvent);
    }

    private async Task DrainRootsAsync()
    {
        _isResolving = true;
        try
        {
            while (_queue.TryDequeue(out var root))
            {
                _trace.StartRoot(root);
                await root.ExecuteAsync(Context);
                root.Finish();
                _trace.EndRoot(root);
            }
        }
        finally
        {
            _isResolving = false;
        }
    }

    private List<CardTriggerPair> CollectTriggersSnapshot(BattleEvent battleEvent)
    {
        var triggers = new List<CardTriggerPair>();
        foreach (var card in Context.GetActiveCards())
        {
            foreach (var effect in card.CardData.Effects)
            {
                // Effect classes own their event and effect-card relation rules.
                if (effect.CanTrigger(battleEvent, Context, card))
                {
                    triggers.Add(new CardTriggerPair(card, effect));
                }
            }
        }

        return triggers;
    }

    private async Task ResolveTriggerAsync(CardTriggerPair pair, BattleEvent battleEvent)
    {
        // Recheck immediately before resolving because earlier effects may have
        // changed the status state. No status means normal resolution proceeds.
        var blockingStatus = pair.Card.CardStatusHolder.BlocksTrigger(pair.Trigger, pair.Card, battleEvent, Context);
        if (blockingStatus is not null)
        {
            await ResolveChildAsync(new BattleEvent(
                BattleEventType.StatusTriggerBlocked,
                pair.Card.OwnerCombatant,
                blockingStatus.Source,
                pair.Card,
                pair.Card,
                new Dictionary<string, object>
                {
                    ["status"] = blockingStatus,
                    ["trigger"] = pair.Trigger,
                }));
            return;
        }

        await pair.Trigger.ResolveAsync(battleEvent, Context, pair.Card);
    }

    private sealed record CardTriggerPair(Card Card, CardEffect Trigger);
}
