using System.Threading.Tasks;
using Godot;

namespace Pixadeck;

[GlobalClass]
public partial class OnOpponentTurnStartedDealDamageEffect : OnOpponentTurnStartedEffect
{
    [Export]
    public int Amount { get; set; } = 1;

    [Export]
    public TargetSelector? TargetSelector { get; set; }

    public override async Task ResolveAsync(BattleEvent battleEvent, BattleContext context, Card effectCard)
    {
        if (TargetSelector is null)
        {
            return;
        }

        foreach (var target in TargetSelector.SelectTargets(battleEvent, context, effectCard))
        {
            if (target is Combatant combatant)
            {
                await context.ExecuteAsync(new DealDamageCommand(effectCard.OwnerCombatant, combatant, Amount, effectCard));
            }
        }
    }
}
