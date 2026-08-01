using System.Collections.Generic;

namespace Pixadeck;

public sealed class DiscardPile
{
    private readonly List<CardData> _cards = [];

    public IReadOnlyList<CardData> Cards => _cards;
    public bool IsHovered { get; set; }

    public void AddCard(CardData cardData)
    {
        _cards.Add((CardData)cardData.Duplicate());
    }
}
