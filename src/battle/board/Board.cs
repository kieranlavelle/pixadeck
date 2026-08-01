using System;
using System.Collections.Generic;

namespace Pixadeck;

public sealed class Board
{
    public const int MaxCardsPerZone = 8;

    // Each battlefield zone belongs to one combatant seat.
    private readonly Dictionary<Combatant.SeatPosition, List<Card>> _cardsBySeat = new()
    {
        [Combatant.SeatPosition.Top] = [],
        [Combatant.SeatPosition.Bottom] = [],
    };

    public event Action<Card, Combatant.SeatPosition>? CardPlaced;
    public event Action<Card, Combatant.SeatPosition>? CardRemoved;

    public IReadOnlyList<Card> GetPlayersCards(Combatant owner) => _cardsBySeat[owner.Seat].ToArray();

    public bool AddCard(Card card)
    {
        var owner = card.OwnerCombatant;
        var cards = _cardsBySeat[owner.Seat];
        if (!CanAddCard(owner.Seat) || cards.Contains(card))
        {
            return false;
        }

        cards.Add(card);
        CardPlaced?.Invoke(card, owner.Seat);
        return true;
    }

    public Card? DiscardCard(Card card, Combatant owner)
    {
        if (card.OwnerCombatant != owner)
        {
            return null;
        }

        var cards = _cardsBySeat[owner.Seat];
        if (!cards.Remove(card))
        {
            return null;
        }

        CardRemoved?.Invoke(card, owner.Seat);
        return card;
    }

    public IReadOnlyList<Card> GetAllCards()
    {
        var cards = new List<Card>(_cardsBySeat[Combatant.SeatPosition.Top]);
        cards.AddRange(_cardsBySeat[Combatant.SeatPosition.Bottom]);
        return cards;
    }

    public bool CanAddCard(Combatant.SeatPosition seat) => _cardsBySeat[seat].Count < MaxCardsPerZone;
}
