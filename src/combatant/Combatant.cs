using System;
using Godot;

namespace Pixadeck;

public partial class Combatant : Control
{
	public enum SeatPosition
	{
		Top,
		Bottom,
	}

	private Deck _deck = null!;
	private Hand _hand = null!;
	private Stats _stats = null!;
	private AIController _aiController = null!;

	[Export]
	public bool IsLocalPlayer { get; set; }

	[Export]
	public SeatPosition Seat { get; set; }

	public event Action<Command, Action<Command>?>? CommandRequested;
	// Set by BattleManager at battle start and used to determine whose turn it is.
	public ulong CombatantId { get; set; }
	public BattleContext BattleContext { get; set; } = null!;
	public DiscardPile DiscardPile { get; private set; } = null!;
	public Deck Deck => _deck;
	public Hand Hand => _hand;
	public Stats Stats => _stats;
	public AIController AiController => _aiController;

	public override void _Ready()
	{
		_deck = GetNode<Deck>("Layout/Deck");
		_hand = GetNode<Hand>("Layout/Hand");
		_stats = GetNode<Stats>("Layout/Stats");
		_aiController = GetNode<AIController>("AIController");

		_hand.CommandRequested += RequestCommand;
		_hand.OwnerCombatant = this;
		// The discard pile has no visual node yet, so it is runtime data only.
		DiscardPile = new DiscardPile();

		if (IsLocalPlayer)
		{
			// Local players do not run the AI controller.
			_aiController.ProcessMode = ProcessModeEnum.Disabled;
		}
		else
		{
			_aiController.Setup(this);
		}
	}

	public void OnTurnStarted(Combatant combatant)
	{
		// If this combatant owns the turn, hand interaction is already enabled by
		// StartTurnCommand. AI combatants then take their turn through the controller.
		if (combatant.CombatantId == CombatantId)
		{
			if (!IsLocalPlayer)
			{
				_ = _aiController.PlayTurnAsync();
			}
		}
		else
		{
			DisablePlayer();
		}
	}

	public void DisablePlayer() => _hand.UpdateCardsForTurn(true);

	public void EnablePlayer() => _hand.UpdateCardsForTurn(false);

	public void ApplyLayout()
	{
		// A future mirrored layout can reorder Layout children. For now, vertical
		// size flags place each combatant's UI at its appropriate edge.
		var verticalFlags = Seat == SeatPosition.Bottom
			? SizeFlags.ShrinkEnd
			: SizeFlags.ShrinkBegin;
		_stats.SizeFlagsVertical = verticalFlags;
		_deck.SizeFlagsVertical = verticalFlags;
		_hand.SizeFlagsVertical = verticalFlags;
	}

	private void RequestCommand(Command command, Action<Command>? callback) => CommandRequested?.Invoke(command, callback);
}
