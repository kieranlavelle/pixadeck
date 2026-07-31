# Battle Resolution Frames

Battle rules are executed through resolution frames. A frame records the causal relationship between a piece of rules work and any commands or events it produces.

The resolver follows two ordering rules:

1. Independent root frames run in FIFO order.
2. Work produced by a resolving frame runs immediately as a child, depth-first.

This makes battle state deterministic without blocking Godot's main thread. Awaiting resolution suspends only the calling coroutine; input, rendering, animations, and other engine work can continue.

## Root frames

A root frame owns exactly one complete battle command submitted from outside the resolver. Typical root commands include:

- Playing a card in response to player input.
- Ending a turn in response to player or AI input.
- Starting the next turn.
- Starting battle setup.

The root contains the whole command, not merely one of the events emitted by it:

```gdscript
func _on_command_requested(command: Command) -> void:
    var result := await battle_context.resolve_root(command)
    command_completed.emit(result)
```

Root frames are queued. If another producer submits a root while one is active, the new root waits until all earlier roots and their descendants have completed:

```text
ROOT: PlayCard
  ...
ROOT: PlayCard complete

ROOT: EndTurn
  ...
ROOT: EndTurn complete
```

This prevents independent Godot signal handlers from modifying battle state concurrently at coroutine yield points. For example, an end-turn request cannot expire statuses halfway through a card-play command.

Awaiting a root means that the submitted command, every child it creates, and the complete chain of reactions have finished. It does not mean that unrelated engine code or the main thread is blocked.

A root is complete when its command returns. Commands must therefore await every child they create; fire-and-forget battle work would escape the frame and violate the resolution contract.

## Child frames

A child frame is rules work caused by the frame currently resolving. Commands and events can both be children, and one command may open many child resolution windows before it returns.

Child frames resolve immediately rather than joining the root FIFO queue:

```gdscript
func execute(context: BattleContext) -> DealDamageCommand:
    var request := BattleEvent.new(
        BattleEventType.DAMAGE_REQUESTED,
        owner,
        source,
        target,
        source,
        {"amount": amount}
    )

    await context.resolve_child_event(request)

    if request.cancelled:
        reason = request.cancelled_reason
        return self

    context.deal_damage(target, amount)

    await context.resolve_child_event(BattleEvent.new(
        BattleEventType.DAMAGE_DEALT,
        owner,
        source,
        target,
        source,
        {"amount": amount}
    ))

    is_success = true
    return self
```

The request and all reactions to it finish before the command checks cancellation or mutates health. Reactions to the resulting fact finish before the command returns.

Child resolution is depth-first:

```text
ROOT COMMAND: PlayCard
  CHILD EVENT: CARD_PLAY_REQUESTED
    child reactions
  spend mana
  move card to battlefield
  CHILD EVENT: CARD_PLAYED
    Strike effect
      CHILD COMMAND: DealDamage
        CHILD EVENT: DAMAGE_REQUESTED
        reduce health
        CHILD EVENT: DAMAGE_DEALT
ROOT COMMAND: PlayCard complete
```

An unrelated queued root can run before or after this tree, but never inside it.

## Why roots and children use different APIs

Putting every event into one FIFO queue would make nested awaits deadlock:

```text
TURN_STARTED waits for DAMAGE_REQUESTED
DAMAGE_REQUESTED is queued behind TURN_STARTED
```

Resolving every submission immediately would create the opposite problem: two independent UI or AI coroutines could interleave their battle mutations whenever either coroutine yielded.

The APIs therefore express the caller's intent:

```gdscript
# A new action entering battle resolution.
await battle_context.resolve_root(command)

# A command caused by the frame currently resolving.
await battle_context.resolve_child_command(command)

# An event caused by the frame currently resolving.
await battle_context.resolve_child_event(event)
```

`resolve_root()` serializes independent work. The child APIs preserve causality inside that work and require an active frame.

The distinction belongs to the invocation, not the command or event type. A `DealDamageCommand` produced by Strike is a child. The same command submitted directly by a battle debugging tool could be a root.

There is no separate event-group scheduling mechanism. A command is already the logical group for its ordered child commands, events, and mutations. Because the root command remains active until it returns, unrelated roots cannot interleave between consecutive awaited children.

## Usage rules

- UI, AI, turn orchestration, and other battle-boundary producers submit roots.
- Effects, triggers, and commands already inside resolution create children.
- Boundary code does not call `Command.execute()` directly.
- Code inside a frame does not submit another root and await it. The active root could not finish until that queued root ran, causing a deadlock.
- A frame is complete only after all of its descendants are complete.
- Commands must not start fire-and-forget battle work.
- Mutations that have request and fact events follow: resolve request, check cancellation, mutate, resolve fact.

These rules make both the ordering of independent player actions and the causal ordering of card effects explicit during code review.
