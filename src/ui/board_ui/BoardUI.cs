using Godot;

namespace Pixadeck;

public partial class BoardUI : Control
{
	private GridContainer _topZone = null!;
	private GridContainer _bottomZone = null!;

	public override void _Ready()
	{
		_topZone = GetNode<GridContainer>("Layout/TopZone");
		_bottomZone = GetNode<GridContainer>("Layout/BottomZone");
	}

	public void OnCardPlaced(Card card, Combatant.SeatPosition seat)
	{
		card.Reparent(seat == Combatant.SeatPosition.Top ? _topZone : _bottomZone);
	}

	public void OnCardRemoved(Card card, Combatant.SeatPosition seat)
	{
		// A battlefield discard has no visible destination yet. Keep the runtime
		// card parented to its board zone until it is queued for deletion.
		card.QueueFree();
	}

	// Returns whether a global position lies inside the board drop zone.
	public bool CanAcceptDropAt(Vector2 position) => GetGlobalRect().HasPoint(position);
}
