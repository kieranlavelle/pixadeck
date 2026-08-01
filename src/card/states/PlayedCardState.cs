namespace Pixadeck;

public partial class PlayedCardState : BaseCardState
{
    // Played cards are passive battlefield controls. Hover stays on Control's
    // enter/exit signal path so a tooltip cannot remain visible after exit.
    public override void OnMouseEntered() => Card.ShowTooltip();
    public override void OnMouseExited() => Card.HideTooltip();
    public override void Exit() => Card.HideTooltip();
}
