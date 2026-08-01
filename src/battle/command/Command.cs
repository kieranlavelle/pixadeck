using System.Threading.Tasks;

namespace Pixadeck;

public abstract class Command
{
    public bool IsSuccess { get; protected set; }
    public string Reason { get; protected set; } = string.Empty;

    public virtual Task<Command> ExecuteAsync(BattleContext context) => Task.FromResult<Command>(this);
}
