using System.Collections.Generic;
using System.Threading.Tasks;

namespace Pixadeck;

public sealed class DiscardCardCommand(Combatant? owner, object card, DiscardCardCommand.Zone zone, object? source = null) : Command
{
    public enum Zone
    {
        Deck,
        Hand,
        Battlefield,
    }

    public override async Task<Command> ExecuteAsync(BattleContext context)
    {
        if (owner is null)
        {
            Reason = "No combatant to discard a card";
            return this;
        }

        var discardedCard = context.DiscardCard(owner, card, zone);
        if (discardedCard is null)
        {
            Reason = "Card is not in the requested source zone";
            return this;
        }

        await context.EventQueue.ResolveChildAsync(new BattleEvent(
            BattleEventType.CardDiscarded,
            owner,
            source ?? owner,
            owner.DiscardPile,
            discardedCard,
            new Dictionary<string, object> { ["zone"] = zone.ToString().ToLowerInvariant() }));
        IsSuccess = true;
        return this;
    }
}
