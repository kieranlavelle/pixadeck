using Godot;

namespace Pixadeck;

public partial class TextDisplay : Label
{
    public override void _Ready()
    {
        Hide();
    }

    public void DisplayText(string textToShow)
    {
        Modulate = new Color(Modulate.R, Modulate.G, Modulate.B, 1);
        Text = textToShow;
    }

    public void ClearText() => Text = string.Empty;

    public async void FadeAndHide()
    {
        var tween = CreateTween().SetParallel(true);
        tween.TweenProperty(this, "modulate:a", 0, 0.4);
        await ToSignal(tween, Tween.SignalName.Finished);
        Hide();
        ClearText();
    }
}
