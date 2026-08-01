using Godot;

namespace Pixadeck;

[GlobalClass]
public partial class KeywordData : Resource
{
    [Export]
    public StringName Id { get; set; }

    [Export]
    public string DisplayName { get; set; } = string.Empty;

    [Export(PropertyHint.MultilineText)]
    public string Description { get; set; } = string.Empty;
}
