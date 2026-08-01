using Godot;
using Godot.Collections;

namespace Pixadeck;

[GlobalClass]
public partial class CardData : Resource
{
    public enum CardLifetime
    {
        Persistent,
        OneShot,
    }

    [Export]
    public string Id { get; set; } = "card_id";

    [Export]
    public string CardName { get; set; } = "card_name";

    [Export]
    public int CardCost { get; set; } = 1;

    [Export]
    public CardLifetime Lifetime { get; set; } = CardLifetime.Persistent;

    [Export(PropertyHint.MultilineText)]
    public string Description { get; set; } = "card effect description";

    [Export]
    public Array<CardEffect> Effects { get; set; } = [];

    [ExportCategory("Assets")]
    [Export]
    public Texture2D? BorderAsset { get; set; }

    [Export]
    public Texture2D? InnerBorderAsset { get; set; }

    [Export]
    public Texture2D? ManaAsset { get; set; }

    [Export]
    public Texture2D? FlagAsset { get; set; }

    [Export]
    public Texture2D? BackgroundAsset { get; set; }

    [Export]
    public Texture2D? TitleAsset { get; set; }

    [Export]
    public Texture2D? TypeAsset { get; set; }

    [Export]
    public Texture2D? ImageAsset { get; set; }
}
