using Godot;

namespace Pixadeck;

[GlobalClass]
public partial class CardStatusData : Resource
{
    // A duration of -1 never expires. Definitions are shared Resources; all
    // per-application state belongs on CardStatusInstance. This sentinel means
    // the caller omitted a duration and should use DefaultDuration instead.
    public const int UseDefaultDuration = -2;

    // UniqueRefresh retains one instance and resets its duration.
    // StackDuration retains one instance and adds duration.
    // SeparateInstances appends independently timed instances.
    public enum StatusStackPolicy
    {
        UniqueRefresh,
        StackDuration,
        SeparateInstances,
    }

    [Export]
    public StringName Id { get; set; }

    [Export]
    public string DisplayName { get; set; } = string.Empty;

    [Export]
    public int DefaultDuration { get; set; } = 1;

    [Export]
    public StatusStackPolicy StackPolicy { get; set; } = StatusStackPolicy.UniqueRefresh;

    // Return true only when this status blocks this specific triggered effect.
    public virtual bool BlocksTrigger(
        CardEffect trigger,
        Card sourceCard,
        BattleEvent battleEvent,
        BattleContext context,
        CardStatusInstance instance) => false;
}
