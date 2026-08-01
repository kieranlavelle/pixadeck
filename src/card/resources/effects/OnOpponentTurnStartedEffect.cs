using Godot;

namespace Pixadeck;

[GlobalClass]
public partial class OnOpponentTurnStartedEffect : CardEffect
{
    public override bool CanTrigger(BattleEvent battleEvent, BattleContext context, Card effectCard) =>
        battleEvent.Type == BattleEventType.TurnStarted && battleEvent.Owner != effectCard.OwnerCombatant;
}
