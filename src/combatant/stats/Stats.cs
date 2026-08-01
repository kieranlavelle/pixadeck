using System;
using Godot;

namespace Pixadeck;

public partial class Stats : VBoxContainer
{
	public const int MaxHealth = 40;
	public const int MaxMana = 9;

	private ProgressBar _healthBar = null!;
	private Label _healthValue = null!;
	private ProgressBar _manaBar = null!;
	private Label _manaValue = null!;

	public event Action<int, int>? ManaChanged;
	public int CurrentHealth { get; private set; } = MaxHealth;
	// CurrentMaxMana is the mana ceiling earned so far, capped at MaxMana.
	public int CurrentMaxMana { get; private set; }
	// CurrentMana is the amount remaining this turn out of CurrentMaxMana.
	public int CurrentMana { get; private set; }

	public override void _Ready()
	{
		_healthBar = GetNode<ProgressBar>("HealthBar");
		_healthValue = GetNode<Label>("HealthBar/HealthValue");
		_manaBar = GetNode<ProgressBar>("ManaBar");
		_manaValue = GetNode<Label>("ManaBar/ManaValue");

		_healthBar.MaxValue = MaxHealth;
		_healthBar.Step = 1;
		_manaBar.MaxValue = MaxMana;
		_manaBar.Step = 1;
		RefreshHealth(CurrentHealth);
		RefreshMana(CurrentMana);
	}

	// Called when this combatant's new turn starts.
	public void OnNewTurn()
	{
		if (CurrentMaxMana < MaxMana)
		{
			CurrentMaxMana++;
		}

		RefreshMana(CurrentMaxMana);
	}

	public bool TrySpendMana(int amount)
	{
		if (amount <= 0 || amount > CurrentMana)
		{
			return false;
		}

		CurrentMana -= amount;
		UpdateManaDisplay();
		ManaChanged?.Invoke(CurrentMana, CurrentMaxMana);
		return true;
	}

	public int TryGainMana(int amount)
	{
		if (amount <= 0)
		{
			return 0;
		}

		var gained = Math.Min(amount, CurrentMaxMana - CurrentMana);
		if (gained <= 0)
		{
			return 0;
		}

		CurrentMana += gained;
		UpdateManaDisplay();
		ManaChanged?.Invoke(CurrentMana, CurrentMaxMana);
		return gained;
	}

	public void RefreshMana(int totalAvailable)
	{
		var oldValue = CurrentMana;
		CurrentMana = Math.Clamp(totalAvailable, 0, CurrentMaxMana);
		if (oldValue != CurrentMana)
		{
			ManaChanged?.Invoke(CurrentMana, CurrentMaxMana);
		}

		UpdateManaDisplay();
	}

	public void RefreshHealth(int totalAvailable)
	{
		CurrentHealth = Math.Clamp(totalAvailable, 0, MaxHealth);
		_healthBar.Value = CurrentHealth;
		_healthValue.Text = $"Health {CurrentHealth}/{MaxHealth}";
	}

	private void UpdateManaDisplay()
	{
		_manaBar.Value = CurrentMana;
		_manaValue.Text = $"Mana {CurrentMana}/{MaxMana}";
	}
}
