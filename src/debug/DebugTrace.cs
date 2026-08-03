using System.Collections.Generic;
using System.Linq;
using System;
using Godot;
using System.Text;

namespace Pixadeck;

public sealed class DebugTrace
{

    // As these are reference types they can be readonly which stops
    // them being re-assigned outside of the constructor but we can
    // still modify the values inside them
    private readonly List<TraceEvent> traces = [];
    private readonly Stack<TraceEvent> activeTraces = new();

    private enum TraceState
    {
        Started,
        Ended,
    }

    private sealed record TraceEvent(
        RootCommand? Command,
        TraceEvent? Parent,
        BattleEvent? Event,
        TraceState State,
        Int32 Depth
    )
    {
        public string EventToString()
        {
            var cardName = Event?.Card?.CardData.CardName ?? "null";
            return $"{new string(' ', Depth*4)} event> {Event?.Type.ToUpperInvariant() ?? string.Empty} {State.ToString().ToUpperInvariant()} (card: {cardName})";
        }

        private string RootToString() => $"Root: {Command?.GetType().Name} {State.ToString()}";
        public override string ToString() => Command is null ? EventToString() : RootToString();
    }

    public void BeginRoot(RootCommand command)
    {

        if (activeTraces.Count > 0)
        {
            GD.PushWarning("Tried to begin a new root when there is already a Root trace.");
            return;
        }

        TraceEvent @event = new(command, null, null, TraceState.Started, 0);
        traces.Add(@event);
        activeTraces.Push(@event);
    }

    public void EndRoot(RootCommand command)
    {
        if (!activeTraces.TryPeek(out var current) || current.Command != command)
        {
            GD.PushWarning("The battle root ending does not match the active root.");
            return;
        }

        activeTraces.Pop();
        TraceEvent @event = new(command, current.Parent, null, TraceState.Ended, current.Depth);
        traces.Add(@event);
    }

    public void BeginEvent(BattleEvent battleEvent)
    {
        if (!activeTraces.TryPeek(out var parent))
        {
            GD.PushWarning($"Tried to add an event {battleEvent.Type} when there is no active Root.");
            return;
        }

        // 3. GUARANTEES this becomes a child in the current tree
        TraceEvent @event = new(null, parent, battleEvent, TraceState.Started, parent.Depth + 1);

        traces.Add(@event);
        activeTraces.Push(@event);
    }

    public void EndEvent(BattleEvent battleEvent)
    {
        if (!activeTraces.TryPeek(out var current) || current.Event != battleEvent)
        {
            GD.PushWarning($"The battle event ending {battleEvent.Type} does not match the active event.");
            return;
        }

        activeTraces.Pop();

        TraceEvent @event = new(null, current.Parent, battleEvent, TraceState.Ended, current.Depth);
        traces.Add(@event);
    }

    public override string ToString()
    {
        var sb = new StringBuilder();

        foreach (var @event in traces)
        {
            sb.AppendLine(@event.ToString());
        }

        return sb.ToString();
    }

    private IEnumerable<TraceEvent> GetEventsForRoot(RootCommand command)
    {
        bool inRootScope = false;

        foreach (var trace in traces)
        {
            // 1. Found the start! Enter the scope.
            if (trace.Command == command && trace.State == TraceState.Started)
            {
                inRootScope = true;
            }

            // 2. Yield everything inside the scope (including the root boundaries themselves)
            if (inRootScope)
            {
                yield return trace;

                // 3. Found the end! We are done.
                if (trace.Command == command && trace.State == TraceState.Ended)
                {
                    yield break;
                }
            }
        }
    }

    public string GetRootTree(RootCommand command)
    {
        var events = GetEventsForRoot(command);

        var sb = new StringBuilder();
        foreach (var @event in events)
        {
            sb.AppendLine(@event.ToString());
        }

        return sb.ToString();
    }

}
