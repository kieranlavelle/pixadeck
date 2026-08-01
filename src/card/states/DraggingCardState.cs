using Godot;

namespace Pixadeck;

public partial class DraggingCardState : BaseCardState
{
    private Vector2 _dragOffset;
    private Vector2 _originalPosition;

    public override void Enter()
    {
        Card.DraggingPanel.Show();
        _originalPosition = Card.GlobalPosition;
        _dragOffset = Card.GetGlobalMousePosition() - Card.GlobalPosition;
    }

    public override void Exit()
    {
        Card.DraggingPanel.Hide();
        Card.PlayablePanel.Hide();
    }

    public override void HandleInput(InputEvent @event)
    {
        if (@event.IsActionReleased("left_mouse_button"))
        {
            if (Card.IsOverDropTarget())
            {
                RequestCommand(new PlayCardCommand(Card.OwnerCombatant, Card), OnCommandProcessed);
            }
            else
            {
                Card.GlobalPosition = _originalPosition;
                TransitionTo(CardStateId.Idle);
            }
        }

        if (@event is InputEventMouseMotion)
        {
            Card.GlobalPosition = Card.GetGlobalMousePosition() - _dragOffset;
            Card.PlayablePanel.Visible = Card.IsOverDropTarget();
        }
    }

    // Dragging owns motion and release outside the card; otherwise highlights and
    // original-position rollback could be left in stale states.
    public override bool WantsCapturedInput(InputEvent @event) =>
        @event is InputEventMouseMotion || @event.IsActionReleased("left_mouse_button");

    private void OnCommandProcessed(Command command)
    {
        if (command.IsSuccess)
        {
            TransitionTo(CardStateId.Played);
            return;
        }

        Card.GlobalPosition = _originalPosition;
        TransitionTo(CardStateId.Idle);
    }
}
