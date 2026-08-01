using System.Threading.Tasks;

namespace Pixadeck;

public sealed class EndTurnCommand : RootCommand
{
    public override async Task<Command> ExecuteAsync(BattleContext context)
    {
        var owner = context.TurnManager.CurrentCombatant;
        if (owner is null)
        {
            Reason = "No active combatant";
            return this;
        }

        // TurnEnding is the last reaction window while the current owner is active.
        await context.EventQueue.ResolveChildAsync(new BattleEvent(BattleEventType.TurnEnding, owner, owner));
        // StatusExpiry is deterministic maintenance, not another reaction window.
        // It keeps statuses active through TurnEnding and expires them before TurnEnded.
        await context.EventQueue.ResolveChildAsync(new BattleEvent(BattleEventType.StatusExpiry, owner, owner));
        await context.EventQueue.ResolveChildAsync(new BattleEvent(BattleEventType.TurnEnded, owner, owner));

        // Effects may react to a turn ending, but cannot prevent it advancing.
        _ = context.AdvanceTurnAsync();
        IsSuccess = true;
        return this;
    }
}
