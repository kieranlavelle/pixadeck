using System;
using Godot;

namespace Pixadeck;

public partial class SkipTurnButton : Button
{
    public event Action? EndTurnRequested;

    public override void _Ready()
    {
        Pressed += OnPressed;
    }

    private void OnPressed() => EndTurnRequested?.Invoke();
}
