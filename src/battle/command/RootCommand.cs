using System.Threading.Tasks;

namespace Pixadeck;

public abstract class RootCommand : Command
{
    private readonly TaskCompletionSource _completionSource = new(TaskCreationOptions.RunContinuationsAsynchronously);

    public bool IsCompleted { get; private set; }
    public Task Completion => _completionSource.Task;

    public void Finish()
    {
        IsCompleted = true;
        _completionSource.TrySetResult();
    }
}
