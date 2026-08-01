using Godot;

namespace Pixadeck;

[GlobalClass]
public partial class StaggerCardStatus : CardStatusData
{
    // Stagger blocks triggered effects from its host card only; it never blocks
    // unrelated cards or deterministic battle facts.
    public override bool BlocksTrigger(
        CardEffect trigger,
        Card sourceCard,
        BattleEvent battleEvent,
        BattleContext context,
        CardStatusInstance instance) => sourceCard == instance.Host;
}
