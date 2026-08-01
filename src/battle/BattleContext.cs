using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Pixadeck;

public sealed class BattleContext
{
	public BattleContext(
		BattleEventQueue eventQueue,
		IReadOnlyList<Combatant> combatants,
		BattleManager battleManager,
		Board board,
		TurnManager turnManager)
	{
		EventQueue = eventQueue;
		Combatants = combatants;
		BattleManager = battleManager;
		Board = board;
		TurnManager = turnManager;
	}

	public BattleEventQueue EventQueue { get; }
	public IReadOnlyList<Combatant> Combatants { get; }
	public BattleManager BattleManager { get; }
	public Board Board { get; }
	public TurnManager TurnManager { get; }

	public async Task<Command> ExecuteAsync(Command command)
	{
		if (command is RootCommand rootCommand)
		{
			await EventQueue.EnqueueRootAsync(rootCommand);
			return rootCommand;
		}

		if (!EventQueue.HasActiveRoot)
		{
			throw new InvalidOperationException("Commands must execute inside a root command.");
		}

		return await command.ExecuteAsync(this);
	}

	public bool SpendMana(Combatant combatant, int amount) => combatant.Stats.TrySpendMana(amount);

	public int GainMana(Combatant combatant, int amount) => combatant.Stats.TryGainMana(amount);

	public Card? DiscardCard(Combatant combatant, object card, DiscardCardCommand.Zone zone)
	{
		var discardedCard = zone switch
		{
			DiscardCardCommand.Zone.Deck when card is CardData cardData => combatant.Deck.DiscardCard(cardData, combatant),
			DiscardCardCommand.Zone.Hand when card is Card handCard => combatant.Hand.DiscardCard(handCard),
			DiscardCardCommand.Zone.Battlefield when card is Card battlefieldCard => Board.DiscardCard(battlefieldCard, combatant),
			_ => null,
		};

		if (discardedCard is not null)
		{
			combatant.DiscardPile.AddCard(discardedCard.CardData);
		}

		return discardedCard;
	}

	// Advancing the turn emits TurnManager.TurnStarted. Commands should use this
	// rather than reaching into the manager so turn progression has one gateway.
	public Task AdvanceTurnAsync() => TurnManager.AdvanceTurnAsync();

	public void DealDamage(Combatant target, int amount)
	{
		target.Stats.RefreshHealth(target.Stats.CurrentHealth - amount);
	}

	// This checks only mana requirements, not turns or any other play condition.
	public bool HasManaForCard(Combatant combatant, Card card) =>
		combatant.Stats.CurrentMana >= card.CardData.CardCost;

	// Drawing is synchronous; moving the card has an animation coroutine.
	public async Task<Card> DrawAndMoveCardAsync(Combatant combatant)
	{
		var cardData = combatant.Deck.DrawCard();
		if (cardData is null)
		{
			throw new InvalidOperationException("A card draw was requested from an empty deck.");
		}

		var cardInHand = combatant.Hand.AddToHand(cardData);
		if (cardInHand is null)
		{
			throw new InvalidOperationException("A card draw was requested for a full hand.");
		}

		await combatant.Deck.AnimateCardToHandAsync(cardInHand);
		return cardInHand;
	}

	public IReadOnlyList<Card> GetActiveCards() => Board.GetAllCards();

	// All targets means every active card plus every combatant.
	public List<object> GetAllTargets()
	{
		var targets = new List<object>(Board.GetAllCards());
		targets.AddRange(Combatants);
		return targets;
	}

	public async Task<CardStatusInstance> ApplyCardStatusAsync(
		object? source,
		Card targetCard,
		CardStatusData definition,
		int duration = CardStatusData.UseDefaultDuration)
	{
		var appliedDuration = duration == CardStatusData.UseDefaultDuration
			? definition.DefaultDuration
			: duration;
		var current = targetCard.CardStatusHolder.FindUniqueByDefinition(definition);

		if (current is null || definition.StackPolicy == CardStatusData.StatusStackPolicy.SeparateInstances)
		{
			var instance = new CardStatusInstance(definition, source, targetCard, appliedDuration);
			targetCard.AddStatus(instance);
			await EmitStatusFactAsync(BattleEventType.StatusApplied, source, targetCard, instance);
			return instance;
		}

		current.Source = source;
		switch (definition.StackPolicy)
		{
			case CardStatusData.StatusStackPolicy.UniqueRefresh:
				current.RemainingTurns = appliedDuration;
				await EmitStatusFactAsync(BattleEventType.StatusRefreshed, source, targetCard, current);
				break;
			case CardStatusData.StatusStackPolicy.StackDuration:
				if (appliedDuration == -1)
				{
					current.RemainingTurns = -1;
				}
				else if (current.RemainingTurns != -1)
				{
					current.RemainingTurns += appliedDuration;
				}

				await EmitStatusFactAsync(BattleEventType.StatusDurationStacked, source, targetCard, current);
				break;
		}

		return current;
	}

	public async Task ExpireStatusesForOwnerAsync(Combatant owner)
	{
		foreach (var card in Board.GetPlayersCards(owner))
		{
			foreach (var status in new List<CardStatusInstance>(card.CardStatusHolder.Statuses))
			{
				// A duration of -1 means the status lasts forever.
				if (status.RemainingTurns == -1)
				{
					continue;
				}

				status.RemainingTurns--;
				await EmitStatusFactAsync(BattleEventType.StatusDurationDecremented, owner, card, status);
				if (status.RemainingTurns <= 0)
				{
					card.RemoveStatus(status);
					await EmitStatusFactAsync(BattleEventType.StatusExpired, owner, card, status);
				}
			}
		}
	}

	public Task ResolveLifecycleEventAsync(BattleEvent battleEvent) =>
		battleEvent.Type == BattleEventType.StatusExpiry && battleEvent.Owner is not null
			? ExpireStatusesForOwnerAsync(battleEvent.Owner)
			: Task.CompletedTask;

	private Task EmitStatusFactAsync(
		string type,
		object? source,
		Card target,
		CardStatusInstance status) =>
		EventQueue.ResolveChildAsync(new BattleEvent(
			type,
			target.OwnerCombatant,
			source,
			target,
			target,
			new Dictionary<string, object>
			{
				["status"] = status,
				["remaining_turns"] = status.RemainingTurns,
			}));
}
