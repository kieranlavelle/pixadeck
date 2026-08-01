using System;
using Godot;

namespace Pixadeck;

public abstract partial class BaseCardState : Node
{
    public event Action<Command, Action<Command>?>? CommandRequested;
    protected Card Card { get; private set; } = null!;
    protected CardStateMachine StateMachine { get; private set; } = null!;

    public void Initialize(Card card, CardStateMachine stateMachine)
    {
        Card = card;
        StateMachine = stateMachine;
    }

    public void TransitionTo(CardStateId state) => StateMachine.TransitionTo(state);
    public virtual void Enter() { }
    public virtual void Exit() { }
    public virtual void HandleInput(InputEvent @event) { }
    // Return true only after this state captures an interaction that must keep
    // receiving mouse events outside the card. Normal states use card-local input.
    public virtual bool WantsCapturedInput(InputEvent @event) => false;
    public virtual void OnMouseEntered() { }
    public virtual void OnMouseExited() { }

    protected void RequestCommand(Command command, Action<Command>? callback) => CommandRequested?.Invoke(command, callback);
}
