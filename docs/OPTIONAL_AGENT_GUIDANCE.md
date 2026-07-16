# Optional Agent Guidance

Danger Gate 0.3.0 injects this policy automatically through `SessionStart` and `SubagentStart`. This optional `AGENTS.md` copy is useful when users want the same rule to remain visible and durable even when the plugin is disabled or unavailable.

The plugin never installs or modifies global or project-level `AGENTS.md` files. Both injected and copied guidance are behavioral safeguards, not enforcement: they cannot create a missing tool event or override filesystem permissions.

```markdown
Before any destructive or irreversible action, state the exact target, scope,
and material effect, then wait for the user's explicit confirmation of that
specific action. A tool or sandbox approval does not count as confirmation. If
the target, scope, or material effect changes, stop and ask again. Do not use an
alternate execution route to avoid this requirement.
```

Use `~/.codex/AGENTS.md` for a personal default across repositories, or a repository `AGENTS.md` for project-specific use. More specific project guidance can take precedence, so do not rely on this text as a security boundary.

The snippet is intentionally short and follows OpenAI's [GPT-5.6 prompting guidance](https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6): keep true safety invariants, define the approval boundary once, and avoid repeated process instructions. See [Custom instructions with AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md) for instruction discovery and scope.
