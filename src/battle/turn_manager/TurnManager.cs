using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;

namespace Pixadeck;

public partial class TurnManager : Node
{
    // StartTurnCommand must complete before TurnStarted, because TurnStarted
    // causes combatants to act. BeforeTurnStarted gives the overlay a moment
    // to present the turn text before setup draws begin.
    private readonly List<Combatant> _combatants = [];

    public event Action<Combatant>? BeforeTurnStarted;
    public event Action<Combatant>? TurnStarted;
    public Combatant? CurrentCombatant { get; private set; }
    public BattleContext Context { get; set; } = null!;

    public async Task StartAsync(IEnumerable<Combatant> combatants)
    {
        _combatants.Clear();
        _combatants.AddRange(combatants);
        if (_combatants.Count == 0)
        {
            GD.PushError("Cannot start a battle without combatants.");
            return;
        }

        // Flip a coin (or choose randomly for larger battles) to decide who starts.
        CurrentCombatant = _combatants[(int)GD.RandRange(0, _combatants.Count - 1)];
        await BeginCurrentTurnAsync();
    }

    public async Task AdvanceTurnAsync()
    {
        if (CurrentCombatant is null)
        {
            GD.PushError("Cannot advance a battle before it starts.");
            return;
        }

        var index = _combatants.IndexOf(CurrentCombatant) + 1;
        CurrentCombatant = _combatants[index % _combatants.Count];
        await BeginCurrentTurnAsync();
    }

    private async Task BeginCurrentTurnAsync()
    {
        var combatant = CurrentCombatant!;
        BeforeTurnStarted?.Invoke(combatant);
        await ToSignal(GetTree().CreateTimer(1.0), SceneTreeTimer.SignalName.Timeout);
        await ProcessTurnStartedCommandAsync();
        TurnStarted?.Invoke(combatant);
    }

    private Task ProcessTurnStartedCommandAsync() =>
        Context.EventQueue.EnqueueRootAsync(new StartTurnCommand(CurrentCombatant!));
}
