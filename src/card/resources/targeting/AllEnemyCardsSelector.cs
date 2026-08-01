using System.Collections.Generic;
using System.Linq;
using Godot;

namespace Pixadeck;

[GlobalClass]
public partial class AllEnemyCardsSelector : TargetSelector
{
    public override IReadOnlyList<object> SelectTargets(BattleEvent battleEvent, BattleContext context, Card effectCard) =>
        context.GetActiveCards().Where(card => card.OwnerCombatant != effectCard.OwnerCombatant).Cast<object>().ToArray();
}
