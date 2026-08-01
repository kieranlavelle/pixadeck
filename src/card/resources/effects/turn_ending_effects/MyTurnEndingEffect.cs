using Godot;

namespace Pixadeck;

[GlobalClass]
public partial class MyTurnEndingEffect : CardEffect
{
    public override bool CanTrigger(BattleEvent battleEvent, BattleContext context, Card effectCard) =>
        battleEvent.Type == BattleEventType.TurnEnding && battleEvent.Owner == effectCard.OwnerCombatant;
}
