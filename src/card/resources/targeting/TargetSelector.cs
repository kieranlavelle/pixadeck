using System.Collections.Generic;
using Godot;

namespace Pixadeck;

[GlobalClass]
public partial class TargetSelector : Resource
{
    public virtual IReadOnlyList<object> SelectTargets(BattleEvent battleEvent, BattleContext context, Card effectCard) => [];
}
