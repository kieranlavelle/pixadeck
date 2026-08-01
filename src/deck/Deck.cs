using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;
using Godot.Collections;

namespace Pixadeck;

public partial class Deck : TextureRect
{
    private static readonly PackedScene CardScene = GD.Load<PackedScene>("res://src/card/card.tscn");

    private AudioStreamPlayer _audio = null!;
    private ColorRect _emptyTexture = null!;
    private readonly List<CardData> _drawPile = [];

    [Export]
    public AudioStream? DrawSound { get; set; }

    [Export]
    public Array<CardData> StartingDeck { get; set; } = [];

    public event Action<Card>? CardDiscarded;
    public bool IsHovered { get; private set; }

    public override void _Ready()
    {
        _audio = GetNode<AudioStreamPlayer>("AudioStreamPlayer");
        _emptyTexture = GetNode<ColorRect>("EmptyTexture");
        _audio.Stream = DrawSound;
        foreach (var cardData in StartingDeck)
        {
            _drawPile.Add(cardData);
        }
        Shuffle(_drawPile);

        MouseEntered += OnMouseEntered;
        MouseExited += OnMouseExited;
    }

    public bool IsDeckEmpty() => _drawPile.Count == 0;

    public CardData? DrawCard()
    {
        if (IsDeckEmpty())
        {
            return null;
        }

        if (_audio.Stream is not null)
        {
            _audio.Play();
        }

        var lastIndex = _drawPile.Count - 1;
        var drawnCard = _drawPile[lastIndex];
        _drawPile.RemoveAt(lastIndex);
        if (IsDeckEmpty())
        {
            _emptyTexture.Show();
        }

        return drawnCard;
    }

    public Card? DiscardCard(CardData cardData, Combatant owner)
    {
        if (!_drawPile.Remove(cardData))
        {
            return null;
        }

        if (IsDeckEmpty())
        {
            _emptyTexture.Show();
        }

        // Deck entries are data, unlike hand and board entries. Promote the data
        // to a runtime Card while it is still parented here so presentation never
        // observes an orphaned card during the discard transition.
        var runtimeCard = CardScene.Instantiate<Card>();
        runtimeCard.CardData = cardData;
        runtimeCard.OwnerCombatant = owner;
        AddChild(runtimeCard);
        CardDiscarded?.Invoke(runtimeCard);
        return runtimeCard;
    }

    public async Task AnimateCardToHandAsync(Card cardInHand)
    {
        // Start invisible; this presentation concern may eventually belong to Hand/Card.
        cardInHand.Modulate = WithAlpha(cardInHand.Modulate, 0);
        cardInHand.MouseFilter = MouseFilterEnum.Ignore;
        // Wait for layout so the runtime card has a reliable global position.
        await ToSignal(GetTree(), SceneTree.SignalName.ProcessFrame);

        // A temporary flyer represents the movement from deck to hand.
        var flyer = new TextureRect
        {
            Texture = Texture,
            Size = cardInHand.Size,
            GlobalPosition = GlobalPosition,
            TopLevel = true,
            ZIndex = 100,
        };
        // A dedicated animation overlay could own flyers in future.
        GetTree().CurrentScene.AddChild(flyer);

        var tween = CreateTween();
        tween.TweenProperty(flyer, "global_position", cardInHand.GlobalPosition, 0.4)
            .SetTrans(Tween.TransitionType.Cubic)
            .SetEase(Tween.EaseType.Out);
        await ToSignal(tween, Tween.SignalName.Finished);
        flyer.QueueFree();

        cardInHand.Modulate = WithAlpha(cardInHand.Modulate, 1);
        cardInHand.MouseFilter = MouseFilterEnum.Stop;
    }

    private void OnMouseEntered() => IsHovered = true;
    private void OnMouseExited() => IsHovered = false;

    private static void Shuffle<T>(IList<T> items)
    {
        for (var index = items.Count - 1; index > 0; index--)
        {
            var swapIndex = (int)GD.RandRange(0, index);
            (items[index], items[swapIndex]) = (items[swapIndex], items[index]);
        }
    }

    private static Color WithAlpha(Color color, float alpha) =>
        new(color.R, color.G, color.B, alpha);
}
