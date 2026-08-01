using System;
using System.Collections.Generic;
using Godot;

namespace Pixadeck;

public partial class Card : TextureRect
{
	private static readonly PackedScene TooltipScene = GD.Load<PackedScene>("res://src/ui/tooltip/tooltip.tscn");

	private CardStateMachine _cardState = null!;
	private Panel _hoverPanel = null!;
	private Panel _clickedPanel = null!;
	private Panel _draggingPanel = null!;
	private Panel _playablePanel = null!;
	private VBoxContainer _tooltipStack = null!;
	private Control _assets = null!;
	private RichTextLabel _description = null!;
	private TextureRect _imageAsset = null!;
	private TextureRect _innerBorder = null!;
	private TextureRect _cardType = null!;
	private TextureRect _outerBorder = null!;
	private TextureRect _cardFlag = null!;
	private TextureRect _cardManaCost = null!;
	private TextureRect _background = null!;

	[Export]
	public CardData CardData { get; set; } = null!;

	public event Action<Command, Action<Command>?>? CommandRequested;
	// These flags block interactions with cards that are not locally playable.
	public bool IsOpponentsTurn { get; set; } = true;
	public bool IsLocallyOwned { get; set; }
	public Combatant OwnerCombatant { get; set; } = null!;
	public CardStatusHolder CardStatusHolder { get; } = new();
	// Receives a global position and reports whether the card can be released there.
	public Func<Vector2, bool>? CanDropAt { get; set; }
	public float TooltipOffsetY { get; set; }
	public Panel HoverPanel => _hoverPanel;
	public Panel ClickedPanel => _clickedPanel;
	public Panel DraggingPanel => _draggingPanel;
	public Panel PlayablePanel => _playablePanel;
	public Control Assets => _assets;

	public override void _Ready()
	{
		_cardState = GetNode<CardStateMachine>("CardStateMachine");
		_hoverPanel = GetNode<Panel>("Assets/HoverPanel");
		_clickedPanel = GetNode<Panel>("Assets/ClickedPanel");
		_draggingPanel = GetNode<Panel>("Assets/DraggingPanel");
		_playablePanel = GetNode<Panel>("Assets/PlayablePanel");
		_tooltipStack = GetNode<VBoxContainer>("TooltipStack");
		_assets = GetNode<Control>("Assets");
		_description = GetNode<RichTextLabel>("Assets/Description");
		_imageAsset = GetNode<TextureRect>("Assets/ImageAsset");
		_innerBorder = GetNode<TextureRect>("Assets/InnerBorder");
		_cardType = GetNode<TextureRect>("Assets/Type");
		_outerBorder = GetNode<TextureRect>("Assets/OuterBorder");
		_cardFlag = GetNode<TextureRect>("Assets/Flag");
		_cardManaCost = GetNode<TextureRect>("Assets/Mana");
		_background = GetNode<TextureRect>("Assets/Background");

		if (CardData is null)
		{
			GD.PushError("Card data was null.");
			return;
		}

		// Forward state-machine commands to the hand and battle manager.
		_cardState.CommandRequested += RequestCommand;
		// This holder treats the runtime card as its status host.
		CardStatusHolder.Host = this;
		_description.Text = CardData.Description;
		_innerBorder.Texture = CardData.InnerBorderAsset;
		_outerBorder.Texture = CardData.BorderAsset;
		_cardType.Texture = CardData.TypeAsset;
		_cardFlag.Texture = CardData.FlagAsset;
		_cardManaCost.Texture = CardData.ManaAsset;
		_background.Texture = CardData.BackgroundAsset;
		_imageAsset.Texture = CardData.ImageAsset;

		MouseEntered += _cardState.OnMouseEntered;
		MouseExited += _cardState.OnMouseExited;
	}

	public override void _Process(double delta)
	{
		// Tooltip placement is recalculated while visible so it follows layout changes.
		if (_tooltipStack.Visible)
		{
			UpdateTooltipPosition();
		}
	}

	public override void _Input(InputEvent @event)
	{
		// _Input sees events anywhere in the viewport. Only captured states use
		// it, so drag motion and release still work after leaving the card rect.
		if (_cardState.WantsCapturedInput(@event))
		{
			_cardState.HandleInput(@event);
			GetViewport().SetInputAsHandled();
		}
	}

	public override void _GuiInput(InputEvent @event)
	{
		// _GuiInput starts card-local interaction; ongoing click/drag handling
		// moves to _Input through WantsCapturedInput.
		_cardState.HandleInput(@event);
	}

	public async void ShowTooltip()
	{
		// Clear tooltips from a previous hover first.
		foreach (var child in _tooltipStack.GetChildren())
		{
			child.QueueFree();
		}

		// The main tooltip describes the card itself.
		var mainTooltip = TooltipScene.Instantiate<Tooltip>();
		_tooltipStack.AddChild(mainTooltip);
		mainTooltip.Setup(CardData.CardName, CardData.Description, CardData.CardCost);

		// Gather each keyword once across all effects.
		var keywords = new List<KeywordData>();
		foreach (var effect in CardData.Effects)
		{
			foreach (var keyword in effect.GetTooltipKeywords())
			{
				if (!keywords.Contains(keyword))
				{
					keywords.Add(keyword);
				}
			}
		}

		foreach (var keyword in keywords)
		{
			var tooltip = TooltipScene.Instantiate<Tooltip>();
			_tooltipStack.AddChild(tooltip);
			tooltip.Setup(keyword.DisplayName, keyword.Description);
		}

		// Start invisible, then wait a frame for text measurement before placing it.
		_tooltipStack.Modulate = WithAlpha(_tooltipStack.Modulate, 0);
		_tooltipStack.Show();
		_tooltipStack.ResetSize();
		await ToSignal(GetTree(), SceneTree.SignalName.ProcessFrame);
		if (!_tooltipStack.Visible)
		{
			return;
		}

		_tooltipStack.ResetSize();
		// Begin slightly below the final position and animate into place.
		TooltipOffsetY = 6;
		UpdateTooltipPosition();

		var tween = CreateTween().SetParallel(true);
		tween.TweenProperty(_tooltipStack, "modulate:a", 1, 0.15)
			.SetTrans(Tween.TransitionType.Cubic)
			.SetEase(Tween.EaseType.Out);
		tween.TweenMethod(Callable.From<float>(SetTooltipOffsetY), TooltipOffsetY, 0, 0.15)
			.SetTrans(Tween.TransitionType.Cubic)
			.SetEase(Tween.EaseType.Out);
	}

	public void HideTooltip() => _tooltipStack.Hide();
	public void AddStatus(CardStatusInstance status) => CardStatusHolder.AddStatus(status);
	public void RemoveStatus(CardStatusInstance status) => CardStatusHolder.RemoveStatus(status);
	public bool IsOverDropTarget() => CanDropAt?.Invoke(GetGlobalMousePosition()) ?? false;

	private void UpdateTooltipPosition()
	{
		const int gap = 8;
		const int margin = 8;
		var viewport = GetViewportRect();
		// Prefer the right side of the card.
		var x = GlobalPosition.X + Size.X + gap;
		// Move left when the tooltip would cross the viewport's right edge.
		if (x + _tooltipStack.Size.X > viewport.Size.X - margin)
		{
			x = GlobalPosition.X - _tooltipStack.Size.X - gap;
		}

		// Position above the card visual to avoid overlapping adjacent hand cards.
		var y = _assets.GlobalPosition.Y - _tooltipStack.Size.Y - gap;
		// Keep the tooltip within the viewport vertically.
		y = Math.Clamp(y, margin, viewport.Size.Y - _tooltipStack.Size.Y - margin);
		_tooltipStack.GlobalPosition = new Vector2(x, y + TooltipOffsetY);
	}

	private void RequestCommand(Command command, Action<Command>? callback) => CommandRequested?.Invoke(command, callback);

	private void SetTooltipOffsetY(float value) => TooltipOffsetY = value;

	private static Color WithAlpha(Color color, float alpha) =>
		new(color.R, color.G, color.B, alpha);
}
