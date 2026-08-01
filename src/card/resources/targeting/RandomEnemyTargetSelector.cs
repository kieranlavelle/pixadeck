using System.Collections.Generic;
using System.Linq;
using Godot;

namespace Pixadeck;

[GlobalClass]
public partial class RandomEnemyTargetSelector : TargetSelector
{
    public override IReadOnlyList<object> SelectTargets(BattleEvent battleEvent, BattleContext context, Card effectCard)
    {
        var targets = context.Combatants.Where(target => target != effectCard.OwnerCombatant).Cast<object>().ToArray();
        return targets.Length == 0 ? [] : [targets[(int)GD.RandRange(0, targets.Length - 1)]];
    }
}
