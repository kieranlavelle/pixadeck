using System.Collections.Generic;
using System.Threading.Tasks;

namespace Pixadeck;

public sealed class GainManaCommand(Combatant? owner, int amount, object? source = null) : Command
{
    public override async Task<Command> ExecuteAsync(BattleContext context)
    {
        if (owner is null)
        {
            Reason = "No combatant to gain mana";
            return this;
        }

        var gained = context.GainMana(owner, amount);
        if (gained == 0)
        {
            Reason = "Mana amount must be positive and there must be room below the mana cap";
            return this;
        }

        await context.EventQueue.ResolveChildAsync(new BattleEvent(
            BattleEventType.ManaGained,
            owner,
            source ?? owner,
            owner,
            null,
            new Dictionary<string, object> { ["amount"] = gained }));
        IsSuccess = true;
        return this;
    }
}
