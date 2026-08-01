using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;

namespace Pixadeck;

public partial class BattleManager : Control
{
	private TurnManager _turnManager = null!;
	private Overlay _battleOverlay = null!;
	private BoardUI _battlefield = null!;
	private readonly List<Combatant> _combatants = [];
	private BattleEventQueue _eventQueue = null!;
	private Board _board = null!;
	private BattleContext _battleContext = null!;
	private BattlePresentationController _presentationController = null!;

	public override void _Ready()
	{
		_turnManager = GetNode<TurnManager>("TurnManager");
		_battleOverlay = GetNode<Overlay>("BattleOverlay");
		_battlefield = GetNode<BoardUI>("BattleLayout/Battlefield/CardDropZone");

		// Set up the event queue for this battle.
		_eventQueue = new BattleEventQueue();
		AddChild(_eventQueue);
		// Board state is game data, not a scene node.
		_board = new Board();

		// Discover combatants placed in this battle scene.
		foreach (var node in GetTree().GetNodesInGroup("Combatants"))
		{
			if (node is Combatant combatant)
			{
				_combatants.Add(combatant);
			}
		}
		foreach (var combatant in _combatants)
		{
			combatant.CombatantId = combatant.GetInstanceId();
			combatant.ApplyLayout();

			// AI combatants may request that their own turn ends.
			if (combatant.AiController.ProcessMode != ProcessModeEnum.Disabled)
			{
				combatant.AiController.TurnEnded += OnRequestEndTurn;
				combatant.AiController.Manager = this;
			}

			_turnManager.TurnStarted += combatant.OnTurnStarted;
			combatant.CommandRequested += OnCommandRequested;
		}

		// A local player skipping their turn follows the same command path as the AI.
		_battleOverlay.EndTurnRequested += OnRequestEndTurn;
		_turnManager.TurnStarted += OnTurnStartedForUi;
		_turnManager.BeforeTurnStarted += _battleOverlay.OnTurnStartAsync;

		// Give every battle participant one shared command context.
		_battleContext = new BattleContext(_eventQueue, _combatants, this, _board, _turnManager);
		foreach (var combatant in _combatants)
		{
			combatant.BattleContext = _battleContext;
		}

		_eventQueue.Context = _battleContext;
		_turnManager.Context = _battleContext;

		_presentationController = new BattlePresentationController(
			_battlefield,
			_battleOverlay,
			_board,
			_turnManager,
			_combatants);
		_presentationController.Setup();

		_ = _turnManager.StartAsync(_combatants);
	}

	public async Task<Command> ExecuteCommandAsync(Command command)
	{
		return await _battleContext.ExecuteAsync(command);
	}

	private void OnTurnStartedForUi(Combatant combatant)
	{
		if (combatant.IsLocalPlayer)
		{
			_battleOverlay.ShowEndTurnButton();
		}
		else
		{
			_battleOverlay.HideEndTurnButton();
		}
	}

	// Event callbacks cannot await their subscribers, so this owns the
	// fire-and-forget boundary for UI and AI end-turn requests.
	private async void OnRequestEndTurn()
	{
		await _battleContext.ExecuteAsync(new EndTurnCommand());
	}

	// Card UI commands flow through the manager so commands share one executor.
	private async void OnCommandRequested(Command command, Action<Command>? callback)
	{
		var response = await _battleContext.ExecuteAsync(command);
		callback?.Invoke(response);
	}
}
