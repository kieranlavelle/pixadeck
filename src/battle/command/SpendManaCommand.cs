using System.Collections.Generic;
using System.Threading.Tasks;

namespace Pixadeck;

public sealed class SpendManaCommand(Combatant? owner, int amount, object? source = null) : Command
{
    public override async Task<Command> ExecuteAsync(BattleContext context)
    {
        if (owner is null)
        {
            Reason = "No combatant to spend mana";
            return this;
        }

        if (!context.SpendMana(owner, amount))
        {
            Reason = "Mana amount must be positive and affordable";
            return this;
        }

        await context.EventQueue.ResolveChildAsync(new BattleEvent(
            BattleEventType.ManaSpent,
            owner,
            source ?? owner,
            owner,
            null,
            new Dictionary<string, object> { ["amount"] = amount }));
        IsSuccess = true;
        return this;
    }
}
