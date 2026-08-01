using System.Collections.Generic;
using System.Linq;
using Godot;

namespace Pixadeck;

[GlobalClass]
public partial class AllEnemiesTargetSelector : TargetSelector
{
    public override IReadOnlyList<object> SelectTargets(BattleEvent battleEvent, BattleContext context, Card effectCard) =>
        context.Combatants.Where(target => target != effectCard.OwnerCombatant).Cast<object>().ToArray();
}
