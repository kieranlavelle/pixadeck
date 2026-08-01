namespace Pixadeck;

public partial class IdleCardState : BaseCardState
{
    public override void OnMouseEntered() => TransitionTo(CardStateId.Hover);
}
