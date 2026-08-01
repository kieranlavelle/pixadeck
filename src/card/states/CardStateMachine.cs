using System;
using System.Collections.Generic;
using Godot;

namespace Pixadeck;

public partial class CardStateMachine : Node
{
    private static readonly HashSet<CardStateId> PlayerTurnOnlyStates =
    [
        CardStateId.Dragging,
        CardStateId.Clicked,
        CardStateId.Played,
    ];

    private readonly Dictionary<CardStateId, BaseCardState> _states = [];
    private BaseCardState _currentState = null!;
    private Card _card = null!;

    public event Action<Command, Action<Command>?>? CommandRequested;

    public override void _Ready()
    {
        _card = GetParent<Card>();
        foreach (var child in GetChildren())
        {
            if (child is not BaseCardState state || !Enum.TryParse<CardStateId>(state.Name.ToString(), true, out var stateId))
            {
                continue;
            }

            state.Initialize(_card, this);
            state.CommandRequested += RequestCommand;
            _states.Add(stateId, state);
        }

        // The card scene must always begin in its passive state.
        _currentState = _states[CardStateId.Idle];
    }

    public void TransitionTo(CardStateId stateId)
    {
        // Never move another player's card into an interactive state, and do not
        // move a local card there while it is the opponent's turn.
        if ((!_card.IsLocallyOwned || _card.IsOpponentsTurn) && PlayerTurnOnlyStates.Contains(stateId))
        {
            return;
        }

        if (!_states.TryGetValue(stateId, out var newState))
        {
            GD.PushError($"Card state {stateId} is missing from the card scene.");
            return;
        }

        // Exit before assigning the next state, then enter the new state.
        _currentState.Exit();
        _currentState = newState;
        _currentState.Enter();
    }

    public void HandleInput(InputEvent @event) => _currentState.HandleInput(@event);
    // Card._Input delegates captured input here so drag/cancel/release decisions
    // remain inside the active state instead of being spread across Control callbacks.
    public bool WantsCapturedInput(InputEvent @event) => _currentState.WantsCapturedInput(@event);
    public void OnMouseEntered() => _currentState.OnMouseEntered();
    public void OnMouseExited() => _currentState.OnMouseExited();

    private void RequestCommand(Command command, Action<Command>? callback) => CommandRequested?.Invoke(command, callback);
}
