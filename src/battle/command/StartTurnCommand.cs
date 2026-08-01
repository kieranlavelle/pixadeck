using System.Threading.Tasks;

namespace Pixadeck;

public sealed class StartTurnCommand(Combatant combatant) : RootCommand
{
    public override async Task<Command> ExecuteAsync(BattleContext context)
    {
        var turnSetupStarted = new BattleEvent(BattleEventType.TurnSetupStarted, combatant, combatant);
        await context.EventQueue.ResolveChildAsync(turnSetupStarted);
        if (turnSetupStarted.IsCancelled)
        {
            Reason = turnSetupStarted.CancelledReason;
            return this;
        }

        // Set up the combatant's turn resources before it can act.
        combatant.Stats.OnNewTurn();
        var drawCommand = new RequestDrawCardCommand(combatant, combatant.Deck, combatant.Hand);
        await context.ExecuteAsync(drawCommand);
        if (!drawCommand.IsSuccess)
        {
            Reason = $"Failed to draw card: [{drawCommand.Reason}]";
            return this;
        }

        // Enable local card interactions only after the setup draw completes.
        combatant.EnablePlayer();
        await context.EventQueue.ResolveChildAsync(new BattleEvent(BattleEventType.TurnStarted, combatant, combatant));
        IsSuccess = true;
        return this;
    }
}
