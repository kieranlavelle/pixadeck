using System.Threading.Tasks;
using Godot;

namespace Pixadeck;

[GlobalClass]
public partial class OnPlayApplyStatusEffect : OnPlayEffect
{
    [Export]
    public CardStatusData? Status { get; set; }

    [Export]
    public TargetSelector? TargetSelector { get; set; }

    public override async Task ResolveAsync(BattleEvent battleEvent, BattleContext context, Card effectCard)
    {
        if (Status is null || TargetSelector is null)
        {
            return;
        }

        foreach (var target in TargetSelector.SelectTargets(battleEvent, context, effectCard))
        {
            if (target is Card card)
            {
                await context.ExecuteAsync(new ApplyStatusCommand(
                    effectCard.OwnerCombatant,
                    card,
                    effectCard,
                    Status,
                    Status.DefaultDuration));
            }
        }
    }
}
