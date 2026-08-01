using Godot;

namespace Pixadeck;

public partial class Tooltip : PanelContainer
{
    private Label _title = null!;
    private Label _cost = null!;
    private RichTextLabel _description = null!;
    private ColorRect _divider = null!;

    public override void _Ready()
    {
        _title = GetNode<Label>("%Title");
        _cost = GetNode<Label>("%Cost");
        _description = GetNode<RichTextLabel>("%Description");
        _divider = GetNode<ColorRect>("%Divider");
    }

    public void Setup(string title, string description, int cost = -1)
    {
        // Effect tooltips have only a title and description; card tooltips also
        // provide a non-negative mana cost and use the larger font setting.
        _title.Text = title;
        _description.Text = description;
        if (cost > -1)
        {
            Theme.DefaultFontSize = 5;
            _cost.Text = cost.ToString();
            _cost.Show();
            _divider.Show();
            return;
        }

        Theme.DefaultFontSize = 4;
        _cost.Hide();
        _divider.Hide();
    }
}
