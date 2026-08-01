using Godot;

namespace Pixadeck;

[GlobalClass]
public partial class OnPlayEffect : CardEffect
{
    public override bool CanTrigger(BattleEvent battleEvent, BattleContext context, Card effectCard) =>
        battleEvent.Type == BattleEventType.CardPlayed && effectCard == battleEvent.Card;
}
