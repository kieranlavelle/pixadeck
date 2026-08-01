using System.Threading.Tasks;

namespace Pixadeck;

public sealed class PlayCardCommand(Combatant owner, Card card) : RootCommand
{
    public override async Task<Command> ExecuteAsync(BattleContext context)
    {
        if (!owner.Hand.HasCard(card))
        {
            Reason = "Does not have card in hand";
            return this;
        }

        // First request a space on the board.
        if (!context.Board.CanAddCard(owner.Seat))
        {
            Reason = "No room on board";
            return this;
        }

        // Then check the mana requirement.
        if (!context.HasManaForCard(owner, card))
        {
            Reason = "Not enough mana";
            return this;
        }

        // CardPlayRequested is the reaction window before the play changes state.
        var request = new BattleEvent(BattleEventType.CardPlayRequested, owner, owner, context.Board, card);
        await context.EventQueue.ResolveChildAsync(request);
        if (request.IsCancelled)
        {
            Reason = request.CancelledReason;
            return this;
        }

        // Recheck after reactions, which may have changed hand, board, or mana.
        if (!owner.Hand.HasCard(card))
        {
            Reason = "Does not have card in hand";
            return this;
        }

        if (!context.Board.CanAddCard(owner.Seat))
        {
            Reason = "No room on board";
            return this;
        }

        if (!context.HasManaForCard(owner, card))
        {
            Reason = "Not enough mana";
            return this;
        }

        if (!context.SpendMana(owner, card.CardData.CardCost))
        {
            Reason = "Mana amount must be positive and affordable";
            return this;
        }

        owner.Hand.PlayCard(card, context.Board);
        await context.EventQueue.ResolveChildAsync(new BattleEvent(BattleEventType.CardPlayed, owner, owner, context.Board, card));

        // One-shot cards resolve on the board, then discard themselves.
        // Their presentation still needs a dedicated discard animation in future.
        if (card.CardData.Lifetime == CardData.CardLifetime.OneShot)
        {
            var discardCommand = new DiscardCardCommand(owner, card, DiscardCardCommand.Zone.Battlefield);
            await context.ExecuteAsync(discardCommand);
            if (!discardCommand.IsSuccess)
            {
                Reason = discardCommand.Reason;
                return this;
            }
        }

        IsSuccess = true;
        return this;
    }
}
