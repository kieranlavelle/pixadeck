using System.Threading.Tasks;

namespace Pixadeck;

public sealed class RequestDrawCardCommand(Combatant owner, Deck deck, Hand hand) : Command
{
    public override async Task<Command> ExecuteAsync(BattleContext context)
    {
        // Validate the initial deck and hand state before opening a reaction window.
        if (deck.IsDeckEmpty())
        {
            Reason = "No cards in deck";
            return this;
        }

        if (hand.IsHandFull())
        {
            Reason = "No room in hand";
            return this;
        }

        var request = new BattleEvent(BattleEventType.CardDrawRequested, owner, owner, hand);
        await context.EventQueue.ResolveChildAsync(request);
        if (request.IsCancelled)
        {
            Reason = request.CancelledReason;
            return this;
        }

        // Recheck after reactions, which may have changed the deck or hand.
        if (deck.IsDeckEmpty())
        {
            Reason = "No cards in deck";
            return this;
        }

        if (hand.IsHandFull())
        {
            Reason = "No room in hand";
            return this;
        }

        // Drawing updates game state and then awaits the presentation animation.
        var card = await context.DrawAndMoveCardAsync(owner);
        await context.EventQueue.ResolveChildAsync(new BattleEvent(BattleEventType.CardDrawn, owner, deck, hand, card));
        IsSuccess = true;
        return this;
    }
}
