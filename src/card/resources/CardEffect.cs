using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;
using Godot.Collections;

namespace Pixadeck;

[GlobalClass]
public partial class CardEffect : Resource
{
    // Each subclass describes one readable card rule. Mutable state belongs on
    // a runtime card or a status instance, never on this shared Resource.
    [Export]
    public StringName Id { get; set; }

    [Export(PropertyHint.MultilineText)]
    public string DisplayText { get; set; } = string.Empty;

    [Export]
    public Array<KeywordData> TooltipKeywords { get; set; } = [];

    public virtual bool CanTrigger(BattleEvent battleEvent, BattleContext context, Card effectCard) => false;

    public virtual Task ResolveAsync(BattleEvent battleEvent, BattleContext context, Card effectCard) => Task.CompletedTask;

    public IEnumerable<KeywordData> GetTooltipKeywords()
    {
        foreach (var keyword in TooltipKeywords)
        {
            yield return keyword;
        }
    }
}
