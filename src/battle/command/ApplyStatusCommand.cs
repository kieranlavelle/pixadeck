using System.Collections.Generic;
using System.Threading.Tasks;

namespace Pixadeck;

public sealed class ApplyStatusCommand(
    Combatant? owner,
    Card? target,
    object? source,
    CardStatusData? definition,
    int duration = CardStatusData.UseDefaultDuration) : Command
{
    public override async Task<Command> ExecuteAsync(BattleContext context)
    {
        if (target is null)
        {
            Reason = "No target";
            return this;
        }

        if (definition is null)
        {
            Reason = "No status definition provided to apply";
            return this;
        }

        var request = new BattleEvent(
            BattleEventType.ApplyStatusRequested,
            owner,
            source,
            target,
            source as Card,
            new Dictionary<string, object>
            {
                ["definition"] = definition,
                ["duration"] = duration,
            });
        await context.EventQueue.ResolveChildAsync(request);

        if (request.IsCancelled)
        {
            Reason = request.CancelledReason;
            return this;
        }

        await context.ApplyCardStatusAsync(source, target, definition, duration);
        IsSuccess = true;
        return this;
    }
}
