using System.Collections.Generic;
using Godot;

namespace Pixadeck;

public sealed class BattleEventTrace
{
    private readonly List<RootTrace> _roots = [];
    private RootTrace? _currentRoot;
    private int _currentIndentation;

    public void StartRoot(Command command)
    {
        if (_currentRoot is not null)
        {
            GD.PushWarning("A battle root was started before the previous root completed.");
            return;
        }

        _currentRoot = new RootTrace(command);
        _currentIndentation = 4;
    }

    public void EndRoot(Command command)
    {
        if (_currentRoot is null)
        {
            GD.PushWarning("A battle root was ended while no root was active.");
            return;
        }

        if (_currentRoot.Command != command)
        {
            GD.PushWarning("The battle root ending does not match the active root.");
            return;
        }

        _roots.Add(_currentRoot);
        PrintRoot(_currentRoot);
        _currentRoot = null;
        _currentIndentation = 0;
    }

    public void EventStarted(BattleEvent battleEvent)
    {
        AddEvent(TraceState.Started, battleEvent, _currentIndentation);
        _currentIndentation += 4;
    }

    public void EventEnded(BattleEvent battleEvent)
    {
        _currentIndentation -= 4;
        AddEvent(TraceState.Ended, battleEvent, _currentIndentation);
    }

    private void AddEvent(TraceState state, BattleEvent battleEvent, int indentation)
    {
        _currentRoot?.Events.Add(new EventTraceEntry(state, battleEvent, indentation));
    }

    private static void PrintRoot(RootTrace root)
    {
        GD.Print($"ROOT: {root.Command.GetType().Name} STARTED:");
        foreach (var battleEvent in root.Events)
        {
            GD.Print(battleEvent.ToDisplayString());
        }

        GD.Print($"ROOT: {root.Command.GetType().Name} Ended");
    }

    private sealed class RootTrace(Command command)
    {
        public Command Command { get; } = command;
        public List<EventTraceEntry> Events { get; } = [];
    }

    private sealed record EventTraceEntry(TraceState State, BattleEvent Event, int Indentation)
    {
        public string ToDisplayString()
        {
            var cardName = Event.Card?.CardData.CardName ?? "null";
            return $"{new string(' ', Indentation)}event> {Event.Type.ToUpperInvariant()} {State.ToString().ToUpperInvariant()} (card: {cardName})";
        }
    }

    private enum TraceState
    {
        Started,
        Ended,
    }
}
