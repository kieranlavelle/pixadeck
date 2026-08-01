using Godot;

namespace Pixadeck;

public partial class HoverCardState : BaseCardState
{
    public override void Enter()
    {
        Card.ShowTooltip();
        if (!Card.IsLocallyOwned || Card.IsOpponentsTurn)
        {
            return;
        }

        Card.HoverPanel.Show();
        Card.ZIndex = 1;
        Card.CreateTween().SetParallel(true)
            .TweenProperty(Card.Assets, "position:y", -20, 0.15);
    }

    public override void Exit()
    {
        Card.HoverPanel.Hide();
        Card.HideTooltip();
        Card.ZIndex = 0;
        Card.CreateTween().SetParallel(true)
            .TweenProperty(Card.Assets, "position:y", 0, 0.15);
    }

    public override void OnMouseExited() => TransitionTo(CardStateId.Idle);

    public override void HandleInput(InputEvent @event)
    {
        if (@event.IsActionPressed("left_mouse_button"))
        {
            TransitionTo(CardStateId.Clicked);
        }
    }
}
