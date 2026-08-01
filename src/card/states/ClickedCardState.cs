using Godot;

namespace Pixadeck;

public partial class ClickedCardState : BaseCardState
{
    private const int DragThreshold = 20;
    private Vector2 _mousePositionOnEnter;
    private bool _isMouseButtonDown;

    public override void Enter()
    {
        _mousePositionOnEnter = Card.GetGlobalMousePosition();
        _isMouseButtonDown = true;
        Card.ClickedPanel.Show();
        Card.ShowTooltip();
    }

    public override void Exit()
    {
        Card.ClickedPanel.Hide();
        Card.HideTooltip();
    }

    public override void HandleInput(InputEvent @event)
    {
        if (@event.IsActionPressed("left_mouse_button"))
        {
            _isMouseButtonDown = true;
            _mousePositionOnEnter = Card.GetGlobalMousePosition();
            return;
        }

        if (@event is InputEventMouseMotion && _isMouseButtonDown &&
            _mousePositionOnEnter.DistanceTo(Card.GetGlobalMousePosition()) > DragThreshold)
        {
            TransitionTo(CardStateId.Dragging);
            return;
        }

        if (@event.IsActionReleased("left_mouse_button"))
        {
            _isMouseButtonDown = false;
            _mousePositionOnEnter = Vector2.Zero;
        }

        if (@event.IsActionPressed("right_mouse_button"))
        {
            TransitionTo(CardStateId.Idle);
        }
    }

    // Capture held-click motion and release outside the card so the drag threshold
    // is consistent. Keep right-click captured so selection can be cancelled anywhere.
    public override bool WantsCapturedInput(InputEvent @event) =>
        (_isMouseButtonDown && @event is InputEventMouseMotion) ||
        (_isMouseButtonDown && @event.IsActionReleased("left_mouse_button")) ||
        @event.IsActionPressed("right_mouse_button");
}
