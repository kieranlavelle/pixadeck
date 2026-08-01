using System.Collections.Generic;
using System.Threading.Tasks;

namespace Pixadeck;

public sealed class DealDamageCommand(Combatant? owner, Combatant? target, int amount, object? source) : Command
{
    public override async Task<Command> ExecuteAsync(BattleContext context)
    {
        if (target is null)
        {
            Reason = "No target";
            return this;
        }

        if (amount <= 0)
        {
            Reason = "Non-positive value for damage amount";
            return this;
        }

        var request = new BattleEvent(
            BattleEventType.DamageRequested,
            owner,
            source,
            target,
            source as Card,
            new Dictionary<string, object> { ["amount"] = amount });
        await context.EventQueue.ResolveChildAsync(request);

        if (request.IsCancelled)
        {
            Reason = request.CancelledReason;
            return this;
        }

        context.DealDamage(target, amount);
        await context.EventQueue.ResolveChildAsync(new BattleEvent(
            BattleEventType.DamageDealt,
            owner,
            source,
            target,
            source as Card,
            new Dictionary<string, object> { ["amount"] = amount }));

        IsSuccess = true;
        return this;
    }
}
