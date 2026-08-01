using System.Collections.Generic;

namespace Pixadeck;

public sealed class BattlePresentationController
{
    private readonly BoardUI _boardUi;
    private readonly Board _board;
    private readonly IReadOnlyList<Combatant> _combatants;

    public BattlePresentationController(
        BoardUI boardUi,
        Overlay overlayUi,
        Board board,
        TurnManager turnManager,
        IReadOnlyList<Combatant> combatants)
    {
        _boardUi = boardUi;
        _board = board;
        _combatants = combatants;
    }

    public void Setup()
    {
        // Connect game-state changes to the static scene nodes.
        _board.CardPlaced += _boardUi.OnCardPlaced;
        _board.CardRemoved += _boardUi.OnCardRemoved;

        // Hands pass this drop-zone predicate to every runtime card they create.
        foreach (var combatant in _combatants)
        {
            combatant.Hand.CanDropAt = _boardUi.CanAcceptDropAt;
            combatant.Deck.CardDiscarded += OnCardDiscarded;
            combatant.Hand.CardDiscarded += OnCardDiscarded;
        }
    }

    private static void OnCardDiscarded(Card card)
    {
        // Discards have no visible destination yet. The card stays parented to
        // its source until this presentation transition owns its lifetime.
        card.QueueFree();
    }
}
