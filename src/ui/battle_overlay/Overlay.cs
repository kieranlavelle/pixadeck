using System;
using Godot;

namespace Pixadeck;

public partial class Overlay : CanvasLayer
{
    private TextDisplay _textDisplay = null!;
    private SkipTurnButton _endTurnButton = null!;

    public event Action? EndTurnRequested;

    public override void _Ready()
    {
        _textDisplay = GetNode<TextDisplay>("TextDisplay");
        _endTurnButton = GetNode<SkipTurnButton>("EndTurnButton");
        HideEndTurnButton();
        // Re-emit the child's button event as an overlay-level request.
        _endTurnButton.EndTurnRequested += RequestEndTurn;
    }

    public async void OnTurnStartAsync(Combatant player)
    {
        // This battle currently has one local player, so ownership identifies the message.
        _textDisplay.DisplayText(player.IsLocalPlayer ? "Your turn!" : "Opponents turn!");
        _textDisplay.Show();
        // Clear the announcement after it has been visible briefly.
        await ToSignal(GetTree().CreateTimer(1.2), SceneTreeTimer.SignalName.Timeout);
        _textDisplay.FadeAndHide();
    }

    public void ShowEndTurnButton()
    {
        _endTurnButton.Disabled = false;
        _endTurnButton.Show();
    }

    public void HideEndTurnButton()
    {
        _endTurnButton.Disabled = true;
        _endTurnButton.Hide();
    }

    private void RequestEndTurn() => EndTurnRequested?.Invoke();
}
