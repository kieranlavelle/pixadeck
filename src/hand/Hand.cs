using System;
using System.Collections.Generic;
using Godot;

namespace Pixadeck;

public partial class Hand : HBoxContainer
{
	public const int DefaultMaxHandSize = 5;

	private static readonly PackedScene CardScene = GD.Load<PackedScene>("res://src/card/card.tscn");
	private readonly List<Card> _cards = [];
	private AudioStreamPlayer _audio = null!;

	[Export]
	public AudioStream? CardPlayedSound { get; set; }

	public event Action<Command, Action<Command>?>? CommandRequested;
	public event Action<Card>? CardDiscarded;
	public Func<Vector2, bool>? CanDropAt { get; set; }
	public Combatant OwnerCombatant { get; set; } = null!;
	public IReadOnlyList<Card> Cards => _cards;

	public override void _Ready()
	{
		_audio = GetNode<AudioStreamPlayer>("AudioStreamPlayer");
		_audio.Stream = CardPlayedSound;
	}

	public bool IsHandFull() => _cards.Count >= DefaultMaxHandSize;
	public bool HasCard(Card card) => _cards.Contains(card);

	public Card? AddToHand(CardData cardData)
	{
		if (IsHandFull())
		{
			return null;
		}

		var card = CardScene.Instantiate<Card>();
		card.CardData = cardData;
		card.OwnerCombatant = OwnerCombatant;
		card.CanDropAt = CanDropAt;
		// Forward each runtime card's command request to its combatant.
		card.CommandRequested += RequestCommand;
		AddChild(card);
		_cards.Add(card);
		return card;
	}

	public void UpdateCardsForTurn(bool isOpponentsTurn)
	{
		foreach (var card in _cards)
		{
			card.IsOpponentsTurn = isOpponentsTurn;
			card.IsLocallyOwned = OwnerCombatant.IsLocalPlayer;
		}
	}

	// Called by PlayCardCommand after its validation and spend-mana steps complete.
	public void PlayCard(Card card, Board board)
	{
		if (_audio.Stream is not null)
		{
			_audio.Play();
		}

		board.AddCard(card);
		_cards.Remove(card);
	}

	public Card? DiscardCard(Card card)
	{
		if (!_cards.Remove(card))
		{
			return null;
		}

		CardDiscarded?.Invoke(card);
		return card;
	}

	private void RequestCommand(Command command, Action<Command>? callback) => CommandRequested?.Invoke(command, callback);
}
