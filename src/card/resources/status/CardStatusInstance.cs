namespace Pixadeck;

public sealed class CardStatusInstance(
    CardStatusData definition,
    object? source,
    Card host,
    int remainingTurns)
{
    public CardStatusData Definition { get; } = definition;
    public object? Source { get; set; } = source;
    public Card Host { get; } = host;
    public int RemainingTurns { get; set; } = remainingTurns;

    public bool BlocksTrigger(
        CardEffect trigger,
        Card sourceCard,
        BattleEvent battleEvent,
        BattleContext context) =>
        Definition.BlocksTrigger(trigger, sourceCard, battleEvent, context, this);
}
