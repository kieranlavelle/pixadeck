using System;
using System.Linq;
using System.Threading.Tasks;
using Godot;

namespace Pixadeck;

public partial class AIController : Node
{
    private Combatant _combatant = null!;
    private bool _playedCard;

    public event Action? TurnEnded;
    public BattleManager Manager { get; set; } = null!;

    public void Setup(Combatant combatant)
    {
        _combatant = combatant;
    }

    public async Task PlayTurnAsync()
    {
        // Card drawing has just completed. Wait briefly so the AI does not act instantly.
        await ToSignal(GetTree().CreateTimer(1.0), SceneTreeTimer.SignalName.Timeout);
        _playedCard = false;

        // Snapshot the hand because a successful play mutates it during iteration.
        foreach (var card in _combatant.Hand.Cards.ToArray())
        {
            if (_playedCard)
            {
                break;
            }

            var command = new PlayCardCommand(_combatant, card);
            var response = await Manager.ExecuteCommandAsync(command);
            _playedCard = response.IsSuccess;
        }

        // The AI has tried every available card, so it can end its turn.
        TurnEnded?.Invoke();
    }
}
